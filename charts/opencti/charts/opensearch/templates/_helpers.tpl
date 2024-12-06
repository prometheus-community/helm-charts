{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "opensearch.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "opensearch.fullname" -}}
{{- if contains .Chart.Name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "opensearch.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "opensearch.labels" -}}
helm.sh/chart: {{ include "opensearch.chart" . }}
{{ include "opensearch.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: {{ include "opensearch.uname" . }}
{{- with .Values.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "opensearch.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opensearch.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "opensearch.uname" -}}
{{- if empty .Values.fullnameOverride -}}
{{- if empty .Values.nameOverride -}}
{{ .Values.clusterName }}-{{ .Values.nodeGroup }}
{{- else -}}
{{ .Values.nameOverride }}-{{ .Values.nodeGroup }}
{{- end -}}
{{- else -}}
{{ .Values.fullnameOverride }}
{{- end -}}
{{- end -}}

{{- define "opensearch.masterService" -}}
{{- if empty .Values.masterService -}}
{{- if empty .Values.fullnameOverride -}}
{{- if empty .Values.nameOverride -}}
{{ .Values.clusterName }}-master
{{- else -}}
{{ .Values.nameOverride }}-master
{{- end -}}
{{- else -}}
{{ .Values.fullnameOverride }}
{{- end -}}
{{- else -}}
{{ .Values.masterService }}
{{- end -}}
{{- end -}}

{{- define "opensearch.serviceName" -}}
{{- if eq .Values.nodeGroup "master" }}
{{- include "opensearch.masterService" . }}
{{- else }}
{{- include "opensearch.uname" . }}
{{- end }}
{{- end -}}

{{- define "opensearch.endpoints" -}}
{{- $replicas := int (toString (.Values.replicas)) }}
{{- $uname := (include "opensearch.uname" .) }}
  {{- range $i, $e := untilStep 0 $replicas 1 -}}
{{ $uname }}-{{ $i }},
  {{- end -}}
{{- end -}}

{{- define "opensearch.majorVersion" -}}
{{- if .Values.majorVersion }}
  {{- .Values.majorVersion }}
{{- else }}
  {{- $version := semver (coalesce .Values.image.tag .Chart.AppVersion "1") }}
  {{- $version.Major }}
{{- end }}
{{- end }}

{{- define "opensearch.dockerRegistry" -}}
{{- if eq .Values.global.dockerRegistry "" -}}
  {{- .Values.global.dockerRegistry -}}
{{- else -}}
  {{- .Values.global.dockerRegistry | trimSuffix "/" | printf "%s/" -}}
{{- end -}}
{{- end -}}

{{- define "opensearch.roles" -}}
{{- range $.Values.roles -}}
{{ . }},
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "opensearch.ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19-0" .Capabilities.KubeVersion.Version) -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if ingress is stable.
*/}}
{{- define "opensearch.ingress.isStable" -}}
  {{- eq (include "opensearch.ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}
{{/*
Return if ingress supports ingressClassName.
*/}}
{{- define "opensearch.ingress.supportsIngressClassName" -}}
  {{- or (eq (include "opensearch.ingress.isStable" .) "true") (and (eq (include "opensearch.ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18-0" .Capabilities.KubeVersion.Version)) -}}
{{- end -}}
