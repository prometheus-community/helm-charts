{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "prometheus-fastly-exporter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "prometheus-fastly-exporter.fullname" -}}
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
{{- define "prometheus-fastly-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "prometheus-fastly-exporter.labels" -}}
helm.sh/chart: {{ include "prometheus-fastly-exporter.chart" . }}
{{ include "prometheus-fastly-exporter.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "prometheus-fastly-exporter.selectorLabels" -}}
app.kubernetes.io/name: {{ include "prometheus-fastly-exporter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "prometheus-fastly-exporter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "prometheus-fastly-exporter.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
{{- default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Determine secret name, can either be the self-created of an existing one
*/}}
{{- define "prometheus-fastly-exporter.secretName" -}}
{{- if .Values.existingSecret.name -}}
    {{- .Values.existingSecret.name -}}
{{- else -}}
    {{ include "prometheus-fastly-exporter.fullname" . }}
{{- end -}}
{{- end -}}
