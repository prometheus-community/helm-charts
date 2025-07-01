package patch

import (
	"bytes"
	"encoding/json"
	"fmt"
	"regexp"
	"strings"
)

func DashboardJson(inputContent string, key string) string {
	content := strings.TrimSpace(inputContent)

	var data map[string]interface{}
	err := json.Unmarshal([]byte(content), &data)
	if err != nil {
		return "{{`" + content + "`}}"
	}

	// multicluster
	templating, templatingOk := data["templating"].(map[string]interface{})
	if !templatingOk {
		return "{{`" + content + "`}}"
	}
	list, listOk := templating["list"].([]interface{})
	if !listOk {
		return "{{`" + content + "`}}"
	}

	overwriteList := make([]interface{}, 0)
	for _, item := range list {
		if variable, ok := item.(map[string]interface{}); ok {
			if name, ok := variable["name"].(string); ok && name == "cluster" {
				variable["allValue"] = ".*"
				variable["hide"] = ":multicluster:"
			}
			overwriteList = append(overwriteList, variable)
		} else {
			return "{{`" + content + "`}}"
		}
	}
	templating["list"] = overwriteList
	data["templating"] = templating

	updated := replaceNestedKey(data, "decimals", -1, nil)

	var b bytes.Buffer
	encErr := customJsonEncoder(&b).Encode(updated)
	if encErr != nil {
		return "{{`" + content + "`}}"
	}
	content = b.String()
	replacementString := fmt.Sprintf("`}}{{ if %s }}0{{ else }}2{{ end }}{{`", key)
	content = strings.Replace(content, `":multicluster:"`, replacementString, -1) // this changes things to escaped utf8

	for _, rule := range ReplacementMap {
		content = strings.Replace(content, rule.Match, rule.Replacement, -1)
	}

	content = strings.TrimSpace(content)

	return "{{`" + content + "`}}"
}

func DashboardJsonSetTimezoneAsVariable(content string) string {
	timezoneRegexp := regexp.MustCompile(`"timezone"\s*:\s*"(?:\\.|[^\"])*"`)
	content = timezoneRegexp.ReplaceAllString(content, timezoneReplacement)
	return content
}

func DashboardJsonSetEditableAsVariable(content string) string {
	editableRegexp := regexp.MustCompile(`"editable"\s*:\s*(?:true|false)`)
	content = editableRegexp.ReplaceAllString(content, editableReplacement)
	return content
}

func DashboardJsonSetIntervalAsVariable(content string) string {
	intervalRegexp := regexp.MustCompile(`"interval"\s*:\s*"(?:\\.|[^\"])*"`)
	content = intervalRegexp.ReplaceAllString(content, intervalReplacement)
	return content
}
