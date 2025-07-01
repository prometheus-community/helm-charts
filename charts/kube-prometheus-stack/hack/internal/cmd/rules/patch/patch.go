package patch

import (
	"fmt"
	"regexp"
	"strings"
	"unicode"

	"main/internal/cmd/rules/consts"
	"main/internal/cmd/rules/types"
	"main/internal/util"
)

func AddCustomLabels(rules string, group types.AlertGroup) string {
	condition := consts.RulesConditionMap[group.Name]
	ruleGroupLabels := getRuleGroupCondition(condition, "additionalRuleGroupLabels")

	baseLabelIndent := strings.Repeat(" ", consts.Indent+consts.LabelIndent)

	additionalRuleLabels := prepareAdditonalRuleLabels(ruleGroupLabels)
	additonalRuleLabelsConditionStart := "\n" + baseLabelIndent + fmt.Sprintf("{{- if or .Values.defaultRules.additionalRuleLabels %s }}", ruleGroupLabels)
	additonalRuleLabelsConditionEnd := "\n" + baseLabelIndent + "{{- end }}"

	// labels: cannot be null, if a rule does not have any labels by default, the labels block
	// should only be added if there are .Values defaultRules.additionalRuleLabels defined
	ruleSeperator := "\n" + strings.Repeat(" ", consts.Indent) + "-.*"
	labelSeperator := "\n" + strings.Repeat(" ", consts.Indent) + "  labels:"
	sectionSeperator := "\n" + strings.Repeat(" ", consts.Indent) + "  \\S"
	sectionSeperatorLen := len(sectionSeperator) - 1
	rulesPositions := util.FindIter(ruleSeperator, rules)

	// fetch breakpoint between each set of rules
	var ruleStartingLine [][]int
	for _, pos := range rulesPositions {
		ruleStartingLine = append(ruleStartingLine, pos)
	}
	var head string
	if len(ruleStartingLine) > 0 {
		head = rules[:ruleStartingLine[0][0]]
	} else {
		head = rules // If no rule separator is found
	}

	// construct array of rules so they can be handled individually
	updatedRules := make([]string, 0)
	var prevRule []int
	for _, r := range ruleStartingLine {
		if prevRule != nil {
			updatedRules = append(updatedRules, rules[prevRule[0]:r[0]])
		}
		prevRule = r
	}
	updatedRules = append(updatedRules, rules[prevRule[0]:len(rules)-1])

	for i, rule := range updatedRules {
		labelRegex := regexp.MustCompile(labelSeperator)
		currentLabel := labelRegex.FindStringIndex(rule)
		if len(currentLabel) > 0 {
			sectionRegex := regexp.MustCompile(sectionSeperator)
			ruleSearch := rule[currentLabel[1]:]
			entries := sectionRegex.FindStringIndex(ruleSearch)
			if len(entries) > 0 {
				entriesStart := currentLabel[1]
				entriesEnd := entries[1] + entriesStart - sectionSeperatorLen
				updatedRules[i] = rule[:entriesEnd] + additonalRuleLabelsConditionStart +
					additionalRuleLabels + additonalRuleLabelsConditionEnd +
					rule[entriesEnd:]
			} else {
				updatedRules[i] += additonalRuleLabelsConditionStart +
					additionalRuleLabels +
					additonalRuleLabelsConditionEnd
			}
		} else {
			updatedRules[i] += additonalRuleLabelsConditionStart + "\n" +
				strings.Repeat(" ", consts.Indent) + "  labels:" +
				additionalRuleLabels +
				additonalRuleLabelsConditionEnd
		}
	}

	return head + strings.Join(updatedRules, "") + "\n"
}

func getRuleGroupCondition(groupName string, valueKey string) string {
	if groupName == "" {
		return ""
	}

	valCount := strings.Count(groupName, ".Values")
	if valCount > 1 {
		parts := strings.Split(groupName, " ")
		groupName = parts[len(parts)-1]
	}

	return strings.TrimSpace(strings.ReplaceAll(
		groupName,
		"Values.defaultRules.rules",
		fmt.Sprintf("Values.defaultRules.%s", valueKey),
	))
}

func prepareAdditonalRuleLabels(ruleGroupLabels string) string {
	const additonalRuleLabelsTemplate = `
{{- with .Values.defaultRules.additionalRuleLabels }}
  {{- toYaml . | nindent 8 }}
{{- end }}
{{- with %s }}
  {{- toYaml . | nindent 8 }}
{{- end }}`

	return util.Indent(
		fmt.Sprintf(additonalRuleLabelsTemplate, ruleGroupLabels),
		strings.Repeat(" ", consts.Indent+consts.LabelIndent*2),
	)
}

func AddCustomAnnotations(rules string, group types.AlertGroup) string {
	ruleCondition := "{{- if .Values.defaultRules.additionalRuleAnnotations }}\n{{ toYaml .Values.defaultRules.additionalRuleAnnotations | indent 8 }}\n{{- end }}"
	groupCondition := consts.RulesConditionMap[group.Name]
	ruleGroupAnnotations := getRuleGroupCondition(groupCondition, "additionalRuleGroupAnnotations")
	ruleGroupCondition := fmt.Sprintf(
		"\n{{- if %s }}\n{{ toYaml %s | indent 8 }}\n{{- end }}",
		ruleGroupAnnotations,
		ruleGroupAnnotations,
	)
	annotations := "      annotations:"
	annotationsLen := len(annotations) + 1
	ruleConditionLen := len(ruleCondition) + 1
	ruleGroupConditionLen := len(ruleGroupCondition)

	separator := strings.Repeat(" ", consts.Indent) + "- alert:.*"
	alertsPositions := util.FindIter(separator, rules)
	alert := 0

	for _, alertPosition := range alertsPositions {
		index := alertPosition[1] + annotationsLen + (ruleConditionLen+ruleGroupConditionLen)*alert
		rules = rules[:index] + "\n" + ruleCondition + ruleGroupCondition + rules[index:]
		alert += 1
	}

	return rules
}

func AddCustomKeepFiringFor(rules string) string {
	indentSpaces := strings.Repeat(" ", consts.Indent) + "  "
	keepFiringFor := indentSpaces + "{{- with .Values.defaultRules.keepFiringFor }}\n" +
		indentSpaces + "keep_firing_for: \"{{ . }}\"\n" +
		indentSpaces + "{{- end }}"
	keepFiringForLen := len(keepFiringFor) + 1

	separator := strings.Repeat(" ", consts.Indent) + "  for:.*"
	alertsPositions := util.FindIter(separator, rules)
	alert := 0

	for _, alertPosition := range alertsPositions {
		index := alertPosition[1] + keepFiringForLen*alert
		rules = rules[:index] + "\n" + keepFiringFor + rules[index:]
		alert += 1
	}

	return rules
}

func AddCustomFor(rules string) string {
	replaceField := "for:"
	return addCustomAlertRules(rules, replaceField)
}

func AddCustomSeverity(rules string) string {
	replaceField := "severity:"
	return addCustomAlertRules(rules, replaceField)
}

func addCustomAlertRules(rules, keyToReplace string) string {
	indentedKey := strings.Repeat(" ", consts.Indent) + keyToReplace
	alertPrefix := "- alert:"
	var (
		builder      strings.Builder
		alertName    string
		inAlertBlock bool
	)

	for i := 0; i < len(rules); {
		minPrefixLength := i + len(alertPrefix)
		if len(rules) >= minPrefixLength && rules[i:minPrefixLength] == alertPrefix {
			inAlertBlock = true
			start := i + len(alertPrefix) + 1
			end := start
			for end < len(rules) && isAlnum(rules[end]) {
				end++
			}

			alertName = rules[start:end]
		}

		if inAlertBlock {
			minKeyLength := i + len(indentedKey)
			if len(rules) >= minKeyLength && rules[i:minKeyLength] == indentedKey {
				inAlertBlock = false

				start := i + len(indentedKey) + 1
				end := start
				for end < len(rules) && isAlnum(rules[end]) {
					end++
				}

				wordAfterReplace := rules[start:end]
				newKey := indentedKey + " {{ dig \"" + alertName +
					`" "` + keyToReplace[:len(keyToReplace)-1] + `" "` +
					wordAfterReplace + `" .Values.customRules }}`
				builder.WriteString(newKey)
				i = end
			}
		}

		builder.WriteByte(rules[i])
		i++
	}

	return builder.String()
}

func isAlnum(b byte) bool {
	r := rune(b)
	return unicode.IsLetter(r) || unicode.IsDigit(r)
}

func AddRulesConditionsFromConditionMap(rules string) string {
	return addRulesConditions(rules, consts.AlertConditionMap)
}

func addRulesConditions(rules string, conditionMap map[string]string) string {
	ruleCondition := "{{- if %s }}\n"
	lineStart := strings.Repeat(" ", consts.Indent) + "- alert: "

	for alertName, condition := range conditionMap {
		fullLine := lineStart + alertName
		if !strings.Contains(rules, fullLine) {
			continue
		}

		ruleText := fmt.Sprintf(ruleCondition, condition)
		start := 0

		for {
			index := strings.Index(rules[start:], fullLine)
			if index == -1 {
				break
			}
			// add if condition
			index += start
			start = index + len(ruleText) + 1
			rules = rules[:index] + ruleText + rules[index:]
			// add end of if

			nextIndex := strings.Index(rules[start:], lineStart)
			if nextIndex == -1 {
				// we found the last alert in file if there are no alerts after it
				nextIndex = len(rules)
			} else {
				nextIndex += start
			}

			foundBlockEnd := false
			lastLineIndex := nextIndex

			for !foundBlockEnd {
				lastLineIndex = strings.LastIndex(rules[index:lastLineIndex-1], "\n")
				if lastLineIndex == -1 {
					break
				}
				lastLineIndex += index

				lastLine := rules[lastLineIndex+1 : nextIndex]
				if strings.HasPrefix(lastLine, "{{- if") {
					nextIndex = lastLineIndex + 1
					continue
				}
				foundBlockEnd = true
			}

			rules = rules[:nextIndex] + "{{- end }}\n" + rules[nextIndex:]
		}
	}

	return rules
}

func AddRulesPerRuleConditions(rules string, group types.AlertGroup) string {
	rulesConditionMap := map[string]string{}
	for _, rule := range group.Rules {
		if rule.Alert != "" {
			rulesConditionMap[rule.Alert] = fmt.Sprintf("not (.Values.defaultRules.disabled.%s | default false)", rule.Alert)
		}
	}

	rules = addRulesConditions(rules, rulesConditionMap)

	return rules
}

func FixGroupsIndent(content string) string {
	lines := strings.Split(content, "\n")
	if len(lines) == 0 {
		return ""
	}

	prefixCountReg := regexp.MustCompile(`(\s*\- )\w+:`)
	prefixLen := len(prefixCountReg.FindStringSubmatch(content)[1])
	prefixSpaces := strings.Repeat(" ", prefixLen)
	lines[0] = "  " + lines[0]
	regex := "^" + prefixSpaces + `\w+`
	levelMatchReg := regexp.MustCompile(regex)
	for i, line := range lines {
		if i == 0 {
			continue
		}
		if levelMatchReg.MatchString(line) {
			lines[i] = prefixSpaces + line
		}
	}

	return strings.Join(lines, "\n")
}
