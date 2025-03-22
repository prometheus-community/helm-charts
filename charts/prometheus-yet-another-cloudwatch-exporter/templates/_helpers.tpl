{{/*
Expand the name of the chart.
*/}}
{{- define "yet-another-cloudwatch-exporter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "yet-another-cloudwatch-exporter.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "yet-another-cloudwatch-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "yet-another-cloudwatch-exporter.labels" -}}
helm.sh/chart: {{ include "yet-another-cloudwatch-exporter.chart" . }}
{{ include "yet-another-cloudwatch-exporter.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "yet-another-cloudwatch-exporter.selectorLabels" -}}
app.kubernetes.io/name: {{ include "yet-another-cloudwatch-exporter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "yet-another-cloudwatch-exporter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "yet-another-cloudwatch-exporter.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the correct image registry.
*/}}
{{- define "yet-another-cloudwatch-exporter.image.repository" -}}
  {{- $registry := .Values.image.registry -}}
  {{- if $registry -}}
    {{- printf "%s/%s" $registry .Values.image.repository -}}
  {{- else -}}
    {{- printf "%s" .Values.image.repository -}}
  {{- end }}
{{- end -}}
