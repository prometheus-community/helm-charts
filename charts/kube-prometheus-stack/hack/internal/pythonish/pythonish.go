package pythonish

import (
	"strings"
	"text/template"

	"gopkg.in/yaml.v3"
)

func NewRenderer() *template.Template {
	return template.New("pythonish").Delims("%(", ")s")
}

func YamlStrRepr(v interface{}, indent int, escape bool) (string, error) {
	var b strings.Builder
	encoder := yaml.NewEncoder(&b)
	encoder.SetIndent(indent)
	err := encoder.Encode(v)
	if err != nil {
		return "", err
	}

	yamlStr := b.String()
	if escape {
		yamlStr = escapeHelm(yamlStr)
	}

	return yamlStr, nil
}

func escapeHelm(s string) string {
	s = strings.ReplaceAll(s, "{{", "{{`{{")
	s = strings.ReplaceAll(s, "}}", "}}`}}")
	s = strings.ReplaceAll(s, "{{`{{", "{{`{{`}}")
	s = strings.ReplaceAll(s, "}}`}}", "{{`}}`}}")
	return s
}
