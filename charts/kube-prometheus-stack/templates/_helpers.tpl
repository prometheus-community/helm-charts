{{/* vim: set filetype=mustache: */}}
{{/* Expand the name of the chart. This is suffixed with -alertmanager, which means subtract 13 from longest 63 available */}}
{{- define "kube-prometheus-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 50 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
The components in this chart create additional resources that expand the longest created name strings.
The longest name that gets created adds and extra 37 characters, so truncation should be 63-35=26.
*/}}
{{- define "kube-prometheus-stack.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 26 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 26 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 26 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Fullname suffixed with -operator */}}
{{/* Adding 9 to 26 truncation of kube-prometheus-stack.fullname */}}
{{- define "kube-prometheus-stack.operator.fullname" -}}
{{- if .Values.prometheusOperator.fullnameOverride -}}
{{- .Values.prometheusOperator.fullnameOverride | trunc 35 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-operator" (include "kube-prometheus-stack.fullname" .) -}}
{{- end }}
{{- end }}

{{/* Prometheus custom resource instance name */}}
{{- define "kube-prometheus-stack.prometheus.crname" -}}
{{- if .Values.cleanPrometheusOperatorObjectNames }}
{{- include "kube-prometheus-stack.fullname" . }}
{{- else }}
{{- print (include "kube-prometheus-stack.fullname" .) "-prometheus" }}
{{- end }}
{{- end }}

{{/* Alertmanager custom resource instance name */}}
{{- define "kube-prometheus-stack.alertmanager.crname" -}}
{{- if .Values.cleanPrometheusOperatorObjectNames }}
{{- include "kube-prometheus-stack.fullname" . }}
{{- else }}
{{- print (include "kube-prometheus-stack.fullname" .) "-alertmanager" -}}
{{- end }}
{{- end }}

{{/* ThanosRuler custom resource instance name */}}
{{/* Subtracting 1 from 26 truncation of kube-prometheus-stack.fullname */}}
{{- define "kube-prometheus-stack.thanosRuler.crname" -}}
{{- if .Values.cleanPrometheusOperatorObjectNames }}
{{- include "kube-prometheus-stack.fullname" . }}
{{- else }}
{{- print (include "kube-prometheus-stack.fullname" . | trunc 25 | trimSuffix "-") "-thanos-ruler" -}}
{{- end }}
{{- end }}

{{/* Shortened name suffixed with thanos-ruler */}}
{{- define "kube-prometheus-stack.thanosRuler.name" -}}
{{- default (printf "%s-thanos-ruler" (include "kube-prometheus-stack.name" .)) .Values.thanosRuler.name -}}
{{- end }}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "kube-prometheus-stack.chartref" -}}
{{- replace "+" "_" .Chart.Version | printf "%s-%s" .Chart.Name -}}
{{- end }}

{{/* Generate basic labels */}}
{{- define "kube-prometheus-stack.labels" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: "{{ replace "+" "_" .Chart.Version }}"
app.kubernetes.io/part-of: {{ template "kube-prometheus-stack.name" . }}
chart: {{ template "kube-prometheus-stack.chartref" . }}
release: {{ $.Release.Name | quote }}
heritage: {{ $.Release.Service | quote }}
{{- if .Values.commonLabels}}
{{ toYaml .Values.commonLabels }}
{{- end }}
{{- end }}

{{/* Create the name of kube-prometheus-stack service account to use */}}
{{- define "kube-prometheus-stack.operator.serviceAccountName" -}}
{{- if .Values.prometheusOperator.serviceAccount.create -}}
    {{ default (include "kube-prometheus-stack.operator.fullname" .) .Values.prometheusOperator.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.prometheusOperator.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Create the name of kube-prometheus-stack service account to use */}}
{{- define "kube-prometheus-stack.operator.admissionWebhooks.serviceAccountName" -}}
{{- if .Values.prometheusOperator.serviceAccount.create -}}
    {{ default (printf "%s-webhook" (include "kube-prometheus-stack.operator.fullname" .)) .Values.prometheusOperator.admissionWebhooks.deployment.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.prometheusOperator.admissionWebhooks.deployment.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Create the name of prometheus service account to use */}}
{{- define "kube-prometheus-stack.prometheus.serviceAccountName" -}}
{{- if .Values.prometheus.serviceAccount.create -}}
    {{ default (print (include "kube-prometheus-stack.fullname" .) "-prometheus") .Values.prometheus.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.prometheus.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Create the name of alertmanager service account to use */}}
{{- define "kube-prometheus-stack.alertmanager.serviceAccountName" -}}
{{- if .Values.alertmanager.serviceAccount.create -}}
    {{ default (print (include "kube-prometheus-stack.fullname" .) "-alertmanager") .Values.alertmanager.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.alertmanager.serviceAccount.name }}
{{- end -}}

{{- end -}}

{{/* Create the name of thanosRuler service account to use */}}
{{- define "kube-prometheus-stack.thanosRuler.serviceAccountName" -}}
{{- if .Values.thanosRuler.serviceAccount.create -}}
    {{ default (include "kube-prometheus-stack.thanosRuler.name" .) .Values.thanosRuler.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.thanosRuler.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "kube-prometheus-stack.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
Use the grafana namespace override for multi-namespace deployments in combined charts
*/}}
{{- define "kube-prometheus-stack-grafana.namespace" -}}
  {{- if .Values.grafana.namespaceOverride -}}
    {{- .Values.grafana.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
Use the Alertmanager namespace override for multi-namespace deployments in combined charts
*/}}
{{- define "kube-prometheus-stack-alertmanager.namespace" -}}
  {{- if .Values.alertmanager.namespaceOverride -}}
    {{- .Values.alertmanager.namespaceOverride -}}
  {{- else -}}
    {{- include "kube-prometheus-stack.namespace" . -}}
  {{- end -}}
{{- end -}}

{{/*
Allow kubelet job name to be overridden
*/}}
{{- define "kube-prometheus-stack-kubelet.name" -}}
  {{- if index .Values "kubelet" "jobNameOverride" -}}
    {{- index .Values "kubelet" "jobNameOverride" -}}
  {{- else -}}
    {{- print "kubelet" -}}
  {{- end -}}
{{- end -}}


{{/*
Allow kube-controller-manager job name to be overridden
*/}}
{{- define "kube-prometheus-stack-kube-controller-manager.name" -}}
  {{- if index .Values "kubeControllerManager" "jobNameOverride" -}}
    {{- index .Values "kubeControllerManager" "jobNameOverride" -}}
  {{- else -}}
    {{- print "kube-controller-manager" -}}
  {{- end -}}
{{- end -}}


{{/*
Allow kube-scheduler job name to be overridden
*/}}
{{- define "kube-prometheus-stack-kube-scheduler.name" -}}
  {{- if index .Values "kubeScheduler" "jobNameOverride" -}}
    {{- index .Values "kubeScheduler" "jobNameOverride" -}}
  {{- else -}}
    {{- print "kube-scheduler" -}}
  {{- end -}}
{{- end -}}


{{/*
Allow kube-proxy job name to be overridden
*/}}
{{- define "kube-prometheus-stack-kube-proxy.name" -}}
  {{- if index .Values "kubeProxy" "jobNameOverride" -}}
    {{- index .Values "kubeProxy" "jobNameOverride" -}}
  {{- else -}}
    {{- print "kube-proxy" -}}
  {{- end -}}
{{- end -}}

{{/*
Allow kube-state-metrics job name to be overridden
*/}}
{{- define "kube-prometheus-stack-kube-state-metrics.name" -}}
  {{- if index .Values "kube-state-metrics" "nameOverride" -}}
    {{- index .Values "kube-state-metrics" "nameOverride" -}}
  {{- else -}}
    {{- print "kube-state-metrics" -}}
  {{- end -}}
{{- end -}}

{{/*
Use the kube-state-metrics namespace override for multi-namespace deployments in combined charts
*/}}
{{- define "kube-prometheus-stack-kube-state-metrics.namespace" -}}
  {{- if index .Values "kube-state-metrics" "namespaceOverride" -}}
    {{- index .Values "kube-state-metrics" "namespaceOverride" -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
Use the prometheus-node-exporter namespace override for multi-namespace deployments in combined charts
*/}}
{{- define "kube-prometheus-stack-prometheus-node-exporter.namespace" -}}
  {{- if index .Values "prometheus-node-exporter" "namespaceOverride" -}}
    {{- index .Values "prometheus-node-exporter" "namespaceOverride" -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/* Allow KubeVersion to be overridden. */}}
{{- define "kube-prometheus-stack.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version .Values.kubeVersionOverride -}}
{{- end -}}

{{/* Get value based on current Kubernetes version */}}
{{- define "kube-prometheus-stack.kubeVersionDefaultValue" -}}
  {{- $values := index . 0 -}}
  {{- $kubeVersion := index . 1 -}}
  {{- $old := index . 2 -}}
  {{- $new := index . 3 -}}
  {{- $default := index . 4 -}}
  {{- if kindIs "invalid" $default -}}
    {{- if semverCompare $kubeVersion (include "kube-prometheus-stack.kubeVersion" $values) -}}
      {{- print $new -}}
    {{- else -}}
      {{- print $old -}}
    {{- end -}}
  {{- else -}}
    {{- print $default }}
  {{- end -}}
{{- end -}}

{{/* Get value for kube-controller-manager depending on insecure scraping availability */}}
{{- define "kube-prometheus-stack.kubeControllerManager.insecureScrape" -}}
  {{- $values := index . 0 -}}
  {{- $insecure := index . 1 -}}
  {{- $secure := index . 2 -}}
  {{- $userValue := index . 3 -}}
  {{- include "kube-prometheus-stack.kubeVersionDefaultValue" (list $values ">= 1.22-0" $insecure $secure $userValue) -}}
{{- end -}}

{{/* Get value for kube-scheduler depending on insecure scraping availability */}}
{{- define "kube-prometheus-stack.kubeScheduler.insecureScrape" -}}
  {{- $values := index . 0 -}}
  {{- $insecure := index . 1 -}}
  {{- $secure := index . 2 -}}
  {{- $userValue := index . 3 -}}
  {{- include "kube-prometheus-stack.kubeVersionDefaultValue" (list $values ">= 1.23-0" $insecure $secure $userValue) -}}
{{- end -}}

{{/* Sets default scrape limits for servicemonitor */}}
{{- define "servicemonitor.scrapeLimits" -}}
{{- with .sampleLimit }}
sampleLimit: {{ . }}
{{- end }}
{{- with .targetLimit }}
targetLimit: {{ . }}
{{- end }}
{{- with .labelLimit }}
labelLimit: {{ . }}
{{- end }}
{{- with .labelNameLengthLimit }}
labelNameLengthLimit: {{ . }}
{{- end }}
{{- with .labelValueLengthLimit }}
labelValueLengthLimit: {{ . }}
{{- end }}
{{- end -}}

{{/*
To help compatibility with other charts which use global.imagePullSecrets.
Allow either an array of {name: pullSecret} maps (k8s-style), or an array of strings (more common helm-style).
global:
  imagePullSecrets:
  - name: pullSecret1
  - name: pullSecret2

or

global:
  imagePullSecrets:
  - pullSecret1
  - pullSecret2
*/}}
{{- define "kube-prometheus-stack.imagePullSecrets" -}}
{{- range .Values.global.imagePullSecrets }}
  {{- if eq (typeOf .) "map[string]interface {}" }}
- {{ toYaml . | trim }}
  {{- else }}
- name: {{ . }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "kube-prometheus-stack.operator.admission-webhook.dnsNames" }}
{{- $fullname := include "kube-prometheus-stack.operator.fullname" . }}
{{- $namespace := include "kube-prometheus-stack.namespace" . }}
{{- $fullname }}
{{ $fullname }}.{{ $namespace }}.svc
{{- if .Values.prometheusOperator.admissionWebhooks.deployment.enabled }}
{{ $fullname }}-webhook
{{ $fullname }}-webhook.{{ $namespace }}.svc
{{- end }}
{{- end }}

{{/* To help configure the kubelet servicemonitor for http or https. */}}
{{- define "kube-prometheus-stack.kubelet.scheme" }}
{{- if .Values.kubelet.serviceMonitor.https }}https{{ else }}http{{ end }}
{{- end }}
{{- define "kube-prometheus-stack.kubelet.authConfig" }}
{{- if .Values.kubelet.serviceMonitor.https }}
tlsConfig:
  caFile: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  insecureSkipVerify: {{ .Values.kubelet.serviceMonitor.insecureSkipVerify }}
bearerTokenFile: /var/run/secrets/kubernetes.io/serviceaccount/token
{{- end }}
{{- end }}


{{/* To help configure anti-affinity rules for Prometheus pods */}}
{{- define "kube-prometheus-stack.prometheus.pod-anti-affinity.matchExpressions" }}
{{- if .Values.prometheus.agentMode }}
- {key: app.kubernetes.io/name, operator: In, values: [prometheus-agent]}
- {key: app.kubernetes.io/instance, operator: In, values: [{{ template "kube-prometheus-stack.prometheus.crname" . }}]}
{{- else }}
- {key: app.kubernetes.io/name, operator: In, values: [prometheus]}
- {key: app.kubernetes.io/instance, operator: In, values: [{{ template "kube-prometheus-stack.prometheus.crname" . }}]}
{{- end }}
{{- end }}

{{/* To help configure Grafana operator folder settings (folder, folderUID, or folderRef) */}}
{{- define "kube-prometheus-stack.grafana.operator.folder" }}
{{- $folder := .Values.grafana.operator.folder }}
{{- $folderUID := .Values.grafana.operator.folderUID }}
{{- $folderRef := .Values.grafana.operator.folderRef }}
{{- if not (or
  (and $folder (not $folderUID) (not $folderRef))
  (and (not $folder) $folderUID (not $folderRef))
  (and (not $folder) (not $folderUID) $folderRef)
)}}
{{- fail "grafana.operator: only one of folder, folderUID, or folderRef must be set" }}
{{- end }}
{{- if $folder }}
folder: {{ $folder | quote }}
{{- else if $folderUID }}
folderUID: {{ $folderUID | quote }}
{{- else if $folderRef }}
folderRef: {{ $folderRef | quote }}
{{- end }}
{{- end }}
