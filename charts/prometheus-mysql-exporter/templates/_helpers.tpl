{{/*
Expand the name of the chart.
*/}}
{{- define "prometheus-mysql-exporter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "prometheus-mysql-exporter.fullname" -}}
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
{{- define "prometheus-mysql-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "prometheus-mysql-exporter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "prometheus-mysql-exporter.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "prometheus-mysql-exporter.labels" -}}
helm.sh/chart: {{ include "prometheus-mysql-exporter.chart" . }}
{{ include "prometheus-mysql-exporter.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "prometheus-mysql-exporter.selectorLabels" -}}
app.kubernetes.io/name: {{ include "prometheus-mysql-exporter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Secret name for cloudsql credentials
*/}}
{{- define "prometheus-mysql-exporter.cloudsqlsecret" -}}
{{ template "prometheus-mysql-exporter.fullname" . }}-cloudsqlsecret
{{- end -}}

{{/*
Secret name for config
*/}}
{{- define "prometheus-mysql-exporter.secretName" -}}
    {{- if .Values.mysql.existingConfigSecret.name -}}
        {{- printf "%s" .Values.mysql.existingConfigSecret.name -}}
    {{- else -}}
        {{ template "prometheus-mysql-exporter.fullname" . }}-config
    {{- end -}}
{{- end -}}
*/}}

Secret key for config
*/}}
{{- define "prometheus-mysql-exporter.secretKey" -}}
    {{- if .Values.mysql.existingConfigSecret.key -}}
        {{- printf "%s" .Values.mysql.existingConfigSecret.key -}}
    {{- else -}}
        my.cnf
    {{- end -}}
{{- end -}}
*/}}

{{/*
CloudSqlProxy Workload Identity Service Account Annotation
*/}}
{{- define "prometheus-mysql-exporter.workloadIdentityAnnotation" -}}
    {{- if .Values.cloudsqlproxy.workloadIdentity.enabled -}}
         {{- printf "%s: %s" "iam.gke.io/gcp-service-account" .Values.cloudsqlproxy.workloadIdentity.serviceAccountEmail -}}
    {{- end -}}
{{- end -}}
