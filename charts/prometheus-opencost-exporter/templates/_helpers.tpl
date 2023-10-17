{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "prometheus-opencost-exporter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "prometheus-opencost-exporter.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "prometheus-opencost-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "prometheus-opencost-exporter.labels" -}}
helm.sh/chart: {{ include "prometheus-opencost-exporter.chart" . }}
{{ include "prometheus-opencost-exporter.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "prometheus-opencost-exporter.selectorLabels" -}}
app.kubernetes.io/name: {{ include "prometheus-opencost-exporter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "prometheus-opencost-exporter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "prometheus-opencost-exporter.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus-opencost-exporter.prometheus.secretname" -}}
  {{- if .Values.opencost.prometheus.secret_name -}}
    {{- .Values.opencost.prometheus.secret_name -}}
  {{- else -}}
    {{- include "prometheus-opencost-exporter.fullname" . -}}
  {{- end -}}
{{- end -}}

{{/*
Create the name of the controller service account to use
*/}}
{{- define "prometheus-opencost-exporter.prometheusServerEndpoint" -}}
  {{- if .Values.opencost.prometheus.external.enabled -}}
    {{ tpl .Values.opencost.prometheus.external.url . }}
  {{- else -}}
    {{- $host := tpl .Values.opencost.prometheus.internal.serviceName . }}
    {{- $ns := tpl .Values.opencost.prometheus.internal.namespaceName . }}
    {{- $port := .Values.opencost.prometheus.internal.port | int }}
    {{- printf "http://%s.%s.svc:%d" $host $ns $port -}}
  {{- end -}}
{{- end -}}


{{/*
Check that either prometheus external or internal is defined
*/}}
{{- define "isPrometheusConfigValid" -}}
  {{- if and .Values.opencost.prometheus.external.enabled .Values.opencost.prometheus.internal.enabled -}}
    {{- fail "Only use one of the prometheus setups, internal or external" -}}
  {{- end -}}
{{- end -}}
