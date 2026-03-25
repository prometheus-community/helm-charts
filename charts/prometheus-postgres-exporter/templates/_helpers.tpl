{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "prometheus-postgres-exporter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "prometheus-postgres-exporter.fullname" -}}
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
{{- define "prometheus-postgres-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "prometheus-postgres-exporter.labels" -}}
helm.sh/chart: {{ include "prometheus-postgres-exporter.chart" . }}
{{ include "prometheus-postgres-exporter.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- if .Values.commonLabels}}
{{ toYaml .Values.commonLabels }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "prometheus-postgres-exporter.selectorLabels" -}}
app.kubernetes.io/name: {{ include "prometheus-postgres-exporter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "prometheus-postgres-exporter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "prometheus-postgres-exporter.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Define the prometheus-postgres-exporter.namespace template if set with namespaceOverride or .Release.Namespace is set
*/}}
{{- define "prometheus-postgres-exporter.namespace" -}}
  {{- default .Release.Namespace .Values.namespaceOverride -}}
{{- end }}

{{/*
Set DATA_SOURCE_URI environment variable
*/}}
{{- define "prometheus-postgres-exporter.data_source_uri" -}}
{{ printf "%s:%d/%s?sslmode=%s&%s" (tpl .Values.config.datasource.host .) (tpl .Values.config.datasource.port . | int) (tpl .Values.config.datasource.database .) (tpl .Values.config.datasource.sslmode .) (tpl .Values.config.datasource.extraParams .) | trimSuffix "&" | quote }}
{{- end }}
