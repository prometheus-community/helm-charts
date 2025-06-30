package rules

import (
	"fmt"
	"main/internal/util"
	"os"
	"regexp"
	"slices"
	"strings"

	"github.com/sirupsen/logrus"
	"main/internal/cmd/rules/consts"
	"main/internal/cmd/rules/patch"
	"main/internal/cmd/rules/types"
	"main/internal/pythonish"
	mainTypes "main/internal/types"
)

func writeOutput(currentState types.ChartState, chart *mainTypes.RulesGitSource) error {

	groups := currentState.Alerts.Groups
	for _, group := range groups {
		FixExpr(&group)
		groupName := group.Name

		rulesGroups := []types.AlertGroup{group}
		rules, yamlErr := pythonish.YamlStrRepr(rulesGroups, 4, true)
		if yamlErr != nil {
			return yamlErr
		}

		initLine := ""
		for _, replaceRule := range consts.ReplacementMap {
			limitGroup := replaceRule.LimitGroup
			if limitGroup == nil || len(limitGroup) == 0 {
				limitGroup = []string{
					groupName,
				}
			}

			if slices.Contains(limitGroup, groupName) && strings.Contains(rules, replaceRule.Match) {
				rules = strings.ReplaceAll(rules, replaceRule.Match, replaceRule.Replacement)
				if replaceRule.Init != "" {
					initLine += "\n" + replaceRule.Init
				}
			}
		}
		// Now append per-alert rules
		rules = patch.AddCustomLabels(rules, group)             // rules = add_custom_labels(rules, group)
		rules = patch.AddCustomAnnotations(rules, group)        // rules = add_custom_annotations(rules, group)
		rules = patch.AddCustomKeepFiringFor(rules)             // rules = add_custom_keep_firing_for(rules)
		rules = patch.AddCustomFor(rules)                       // rules = add_custom_for(rules)
		rules = patch.AddCustomSeverity(rules)                  // rules = add_custom_severity(rules)
		rules = patch.AddRulesConditionsFromConditionMap(rules) // rules = add_rules_conditions_from_condition_map(rules)
		rules = patch.AddRulesPerRuleConditions(rules, group)   // rules = add_rules_per_rule_conditions(rules, group)
		writeGroupToFile(groupName, rules, currentState.Url, chart.GetDestination(), initLine, chart.GetMinKubernetes(), chart.GetMaxKubernetes())
	}

	return nil
}

// FixExpr removes trailing whitespace and line breaks, which happen to creep in
// due to yaml import specifics; convert multiline expressions to literal style |-
func FixExpr(group *types.AlertGroup) {
	for key, groupRule := range group.Rules {
		groupRule.Expr = strings.TrimRight(groupRule.Expr, " \n\r\t")
		group.Rules[key] = groupRule
	}
}

// writeGroupToFile will either write the group to a file or panic on any error
func writeGroupToFile(
	resourceName string,
	content string,
	url string,
	destination string,
	initLine string,
	minKubernetesVersion string,
	maxKubernetesVersion string,
) {
	condition, _ := consts.RulesConditionMap[resourceName]
	headerData := mainTypes.HeaderData{
		Name:           strings.ToLower(strings.ReplaceAll(resourceName, "_", "-")),
		URL:            url,
		Condition:      condition,
		InitLine:       initLine,
		MinKubeVersion: minKubernetesVersion,
		MaxKubeVersion: maxKubernetesVersion,
	}

	preparedContent := util.Must(consts.NewRuleHeader(headerData))

	content = patch.FixGroupsIndent(content)

	// Adjust rules
	re := regexp.MustCompile(`\s(?i)(by|on) ?\(`)
	replacement := ` ${1} ({{ range $.Values.defaultRules.additionalAggregationLabels }}{{ . }},{{ end }}`
	preparedContent += re.ReplaceAllString(content, replacement)

	preparedContent += "{{- end }}"

	filename := resourceName + ".yaml"
	newFilename := fmt.Sprintf("%s/%s", destination, filename)

	// make sure directories to store the file exist
	util.CheckErr(os.MkdirAll(destination, os.ModePerm))

	// Recreate the file
	util.CheckErr(os.WriteFile(newFilename, []byte(preparedContent), 0644))

	logrus.Infof("Generated %s", newFilename)
}
