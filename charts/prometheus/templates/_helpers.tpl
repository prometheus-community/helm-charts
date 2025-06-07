{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "prometheus.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "prometheus.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create labels for prometheus
*/}}
{{- define "prometheus.common.matchLabels" -}}
app.kubernetes.io/name: {{ include "prometheus.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create unified labels for prometheus components
*/}}
{{- define "prometheus.common.metaLabels" -}}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
helm.sh/chart: {{ include "prometheus.chart" . }}
app.kubernetes.io/part-of: {{ include "prometheus.name" . }}
{{- with .Values.commonMetaLabels}}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "prometheus.server.labels" -}}
{{ include "prometheus.server.matchLabels" . }}
{{ include "prometheus.common.metaLabels" . }}
{{- end -}}

{{- define "prometheus.server.matchLabels" -}}
app.kubernetes.io/component: {{ .Values.server.name }}
{{ include "prometheus.common.matchLabels" . }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.fullname" -}}
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
Create a fully qualified ClusterRole name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.clusterRoleName" -}}
{{- if .Values.server.clusterRoleNameOverride -}}
{{ .Values.server.clusterRoleNameOverride | trunc 63 | trimSuffix "-" }}
{{- else -}}
{{ include "prometheus.server.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified alertmanager name for communicating and check to ensure that `alertmanager` exists before trying to use it with the user via NOTES.txt
*/}}
{{- define "prometheus.alertmanager.fullname" -}}
{{- if .Subcharts.alertmanager -}}
{{- template "alertmanager.fullname" .Subcharts.alertmanager -}}
{{- else -}}
{{- "alertmanager not found" -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified Prometheus server name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.server.fullname" -}}
{{- if .Values.server.fullnameOverride -}}
{{- .Values.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.server.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.server.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Get KubeVersion removing pre-release information.
*/}}
{{- define "prometheus.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version (regexFind "v[0-9]+\\.[0-9]+\\.[0-9]+" .Capabilities.KubeVersion.Version) -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "prometheus.deployment.apiVersion" -}}
{{- print "apps/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for networkpolicy.
*/}}
{{- define "prometheus.networkPolicy.apiVersion" -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Create the name of the service account to use for the server component
*/}}
{{- define "prometheus.serviceAccountName.server" -}}
{{- if .Values.serviceAccounts.server.create -}}
    {{ default (include "prometheus.server.fullname" .) .Values.serviceAccounts.server.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccounts.server.name }}
{{- end -}}
{{- end -}}

{{/*
Define the prometheus.namespace template if set with forceNamespace or .Release.Namespace is set
*/}}
{{- define "prometheus.namespace" -}}
  {{- default .Release.Namespace .Values.forceNamespace -}}
{{- end }}

{{/*
Define template prometheus.namespaces producing a list of namespaces to monitor
*/}}
{{- define "prometheus.namespaces" -}}
{{- $namespaces := list }}
{{- if and .Values.rbac.create .Values.server.useExistingClusterRoleName }}
  {{- if .Values.server.namespaces -}}
    {{- range $ns := join "," .Values.server.namespaces | split "," }}
      {{- $namespaces = append $namespaces (tpl $ns $) }}
    {{- end -}}
  {{- end -}}
  {{- if .Values.server.releaseNamespace -}}
    {{- $namespaces = append $namespaces (include "prometheus.namespace" .) }}
  {{- end -}}
{{- end -}}
{{ mustToJson $namespaces }}
{{- end -}}

{{/*
Define prometheus.server.remoteWrite producing a list of remoteWrite configurations with URL templating
*/}}
{{- define "prometheus.server.remoteWrite" -}}
{{- $remoteWrites := list }}
{{- range $remoteWrite := .Values.server.remoteWrite }}
  {{- $remoteWrites = tpl $remoteWrite.url $ | set $remoteWrite "url" | append $remoteWrites }}
{{- end -}}
{{ toYaml $remoteWrites }}
{{- end -}}

{{/*
Define prometheus.server.remoteRead producing a list of remoteRead configurations with URL templating
*/}}
{{- define "prometheus.server.remoteRead" -}}
{{- $remoteReads := list }}
{{- range $remoteRead := .Values.server.remoteRead }}
  {{- $remoteReads = tpl $remoteRead.url $ | set $remoteRead "url" | append $remoteReads }}
{{- end -}}
{{ toYaml $remoteReads }}
{{- end -}}

