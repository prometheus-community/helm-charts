{{- define "resource-state-metrics.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "-" }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "resource-state-metrics.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "resource-state-metrics.fullname" -}}
{{ include "resource-state-metrics.name" . }}
{{- end -}}

{{- define "resource-state-metrics.name" -}}
{{ .Chart.Name }}
{{- end -}}