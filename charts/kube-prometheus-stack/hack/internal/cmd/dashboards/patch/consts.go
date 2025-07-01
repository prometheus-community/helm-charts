package patch

import (
	"bytes"
	"encoding/json"
	"main/internal/types"
	"reflect"
)

var ReplacementMap = []types.DashboardReplacementRule{
	{
		"var-namespace=$__cell_1",
		"var-namespace=`}}{{ if .Values.grafana.sidecar.dashboards.enableNewTablePanelSyntax }}${__data.fields.namespace}{{ else }}$__cell_1{{ end }}{{`",
	},
	{
		"var-type=$__cell_2",
		"var-type=`}}{{ if .Values.grafana.sidecar.dashboards.enableNewTablePanelSyntax }}${__data.fields.workload_type}{{ else }}$__cell_2{{ end }}{{`",
	},
	{
		"=$__cell",
		"=`}}{{ if .Values.grafana.sidecar.dashboards.enableNewTablePanelSyntax }}${__value.text}{{ else }}$__cell{{ end }}{{`",
	},
	{
		`job=\"prometheus-k8s\",namespace=\"monitoring\"`,
		"",
	},
}

const (
	timezoneReplacement = `"timezone": "` + "`" + `}}{{ .Values.grafana.defaultDashboardsTimezone }}{{` + "`" + `"`
	editableReplacement = `"editable":` + "`" + `}}{{ .Values.grafana.defaultDashboardsEditable }}{{` + "`"
	intervalReplacement = `"interval":"` + "`" + `}}{{ .Values.grafana.defaultDashboardsInterval }}{{` + "`" + `"`
)

func customJsonEncoder(b *bytes.Buffer) *json.Encoder {
	// Use a custom Encoder to disable HTML escaping
	enc := json.NewEncoder(b)
	enc.SetEscapeHTML(false) // Disable HTML escaping
	return enc
}

func replaceNestedKey(data interface{}, key string, value interface{}, replace interface{}) interface{} {
	switch v := data.(type) {
	case map[string]interface{}:
		newMap := make(map[string]interface{})
		for k, val := range v {
			if k == key && reflect.DeepEqual(val, value) {
				newMap[k] = replace
			} else {
				newMap[k] = replaceNestedKey(val, key, value, replace)
			}
		}
		return newMap
	case []interface{}:
		newList := make([]interface{}, len(v))
		for i, item := range v {
			newList[i] = replaceNestedKey(item, key, value, replace)
		}
		return newList
	default:
		return data
	}
}
