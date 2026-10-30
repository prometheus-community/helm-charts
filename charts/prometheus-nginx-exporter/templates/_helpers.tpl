{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "prometheus-nginx-exporter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "prometheus-nginx-exporter.fullname" -}}
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
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "prometheus-nginx-exporter.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "prometheus-nginx-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "prometheus-nginx-exporter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "prometheus-nginx-exporter.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "prometheus-nginx-exporter.labels" }}
helm.sh/chart: {{ include "prometheus-nginx-exporter.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: metrics
app.kubernetes.io/part-of: {{ template "prometheus-nginx-exporter.name" . }}
{{- include "prometheus-nginx-exporter.selectorLabels" . }}
app.kubernetes.io/version: {{ default .Chart.AppVersion .Values.image.tag | quote }}
{{- if .Values.additionalLabels }}
{{ toYaml .Values.additionalLabels }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "prometheus-nginx-exporter.selectorLabels" }}
app.kubernetes.io/name: {{ include "prometheus-nginx-exporter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Deployment annotations
*/}}
{{- define "prometheus-nginx-exporter.deploymentAnnotations" }}
{{- if .Values.additionalAnnotations }}
{{ toYaml .Values.additionalAnnotations }}
{{- end }}
{{- if .Values.deployment.annotations }}
{{ toYaml .Values.deployment.annotations }}
{{- end }}
{{- end }}

{{/*
Pod annotations
*/}}
{{- define "prometheus-nginx-exporter.podAnnotations" }}
{{- if .Values.additionalAnnotations }}
{{ toYaml .Values.additionalAnnotations }}
{{- end }}
{{- if .Values.podAnnotations }}
{{ toYaml .Values.podAnnotations }}
{{- end }}
{{- end }}

{{/*
Service annotations
*/}}
{{- define "prometheus-nginx-exporter.serviceAnnotations" }}
{{- if .Values.additionalAnnotations }}
{{ toYaml .Values.additionalAnnotations }}
{{- end }}
{{- if .Values.service.annotations }}
{{ toYaml .Values.service.annotations }}
{{- end }}
{{- end }}
