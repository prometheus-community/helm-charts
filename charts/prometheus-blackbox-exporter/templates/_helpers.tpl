{{/*
Expand the name of the chart.
*/}}
{{- define "prometheus-blackbox-exporter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "prometheus-blackbox-exporter.fullname" -}}
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
{{- define "prometheus-blackbox-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "prometheus-blackbox-exporter.labels" -}}
helm.sh/chart: {{ include "prometheus-blackbox-exporter.chart" . }}
{{ include "prometheus-blackbox-exporter.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.releaseLabel }}
release: {{ .Release.Name }}
{{- end }}
{{- if .Values.commonLabels }}
{{ toYaml .Values.commonLabels }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "prometheus-blackbox-exporter.selectorLabels" -}}
app.kubernetes.io/name: {{ include "prometheus-blackbox-exporter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "prometheus-blackbox-exporter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "prometheus-blackbox-exporter.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the appropriate apiVersion for rbac.
*/}}
{{- define "rbac.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "rbac.authorization.k8s.io/v1" }}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- else -}}
{{- print "rbac.authorization.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}


{{- define "prometheus-blackbox-exporter.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/* Enable overriding Kubernetes version for some use cases */}}
{{- define "prometheus-blackbox-exporter.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version .Values.kubeVersionOverride -}}
{{- end -}}


{{/*
The image to use
*/}}
{{- define "prometheus-blackbox-exporter.image" -}}
{{- with (.Values.global.imageRegistry | default .Values.image.registry) -}}{{ . }}/{{- end }}
{{- .Values.image.repository -}}:{{- .Values.image.tag | default .Chart.AppVersion -}}
{{- with .Values.image.digest -}}@{{ .}}{{- end -}}
{{- end -}}

{{/*
Define pod spec to be reused by highlevel resources (deployment, daemonset)
*/}}
{{- define "prometheus-blackbox-exporter.podSpec" -}}
automountServiceAccountToken: {{ .Values.automountServiceAccountToken }}
serviceAccountName: {{ template "prometheus-blackbox-exporter.serviceAccountName" . }}
{{- with .Values.topologySpreadConstraints }}
topologySpreadConstraints:
{{ toYaml . }}
{{- end }}
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
{{ toYaml . }}
{{- end }}
{{- if .Values.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.image.pullSecrets }}
- name: {{ . }}
{{- end }}
{{- end }}
{{- if .Values.hostAliases }}
hostAliases:
{{- range .Values.hostAliases }}
- ip: {{ .ip }}
  hostnames:
  {{- range .hostNames }}
  - {{ . }}
  {{- end }}
{{- end }}
{{- end }}
restartPolicy: {{ .Values.restartPolicy }}
{{- with .Values.priorityClassName }}
priorityClassName: "{{ . }}"
{{- end }}
{{- with .Values.podSecurityContext }}
securityContext:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.extraInitContainers }}
initContainers:
{{ toYaml . }}
{{- end }}
containers:
{{ with .Values.extraContainers }}
  {{- toYaml . }}
{{- end }}
- name: blackbox-exporter
  image: {{ include "prometheus-blackbox-exporter.image" . }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  {{- with .Values.securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  env:
  {{- range $key, $value := .Values.extraEnv }}
  - name: {{ $key }}
    value: {{ $value | quote }}
  {{- end }}
  args:
  {{- if .Values.config }}
  {{- if .Values.configPath }}
  - "--config.file={{ .Values.configPath }}"
  {{- else }}
  - "--config.file=/config/blackbox.yaml"
  {{- end }}
  {{- else }}
  - "--config.file=/etc/blackbox_exporter/config.yml"
  {{- end }}
  {{- with .Values.extraArgs }}
{{ tpl (toYaml .) $ | indent 2 }}
  {{- end }}
  {{- with .Values.resources }}
  resources:
{{ toYaml . | indent 4 }}
  {{- end }}
  ports:
  - containerPort: {{ .Values.containerPort }}
    name: http
  livenessProbe:
  {{- toYaml .Values.livenessProbe | trim | nindent 4 }}
  readinessProbe:
  {{- toYaml .Values.readinessProbe | trim | nindent 4 }}
  volumeMounts:
  - mountPath: /config
    name: config
  {{- range .Values.extraConfigmapMounts }}
  - name: {{ .name }}
    mountPath: {{ .mountPath }}
    subPath: {{ .subPath | default "" }}
    readOnly: {{ .readOnly }}
  {{- end }}
  {{- range .Values.extraSecretMounts }}
  - name: {{ .name }}
    mountPath: {{ .mountPath }}
    subPath: {{ .subPath }}
    readOnly: {{ .readOnly }}
  {{- end }}
  {{- if .Values.extraVolumeMounts }}
{{ toYaml .Values.extraVolumeMounts | indent 2 }}
  {{- end }}
  {{- if .Values.dnsPolicy }}
dnsPolicy: {{ .Values.dnsPolicy | toString }}
{{- end }}
hostNetwork: {{ .Values.hostNetwork }}
{{- with .Values.dnsConfig }}
dnsConfig:
  {{- toYaml . | nindent 2 }}
{{- end }}
volumes:
{{- if .Values.extraVolumes }}
{{ toYaml .Values.extraVolumes }}
{{- end }}
- name: config
{{- if .Values.secretConfig }}
  secret:
    secretName: {{ template "prometheus-blackbox-exporter.fullname" . }}
{{- else if .Values.configExistingSecretName }}
  secret:
    secretName: {{ .Values.configExistingSecretName }}
{{- else }}
  configMap:
    name: {{ template "prometheus-blackbox-exporter.fullname" . }}
{{- end }}
{{- range .Values.extraConfigmapMounts }}
- name: {{ .name }}
  configMap:
    name: {{ .configMap }}
    defaultMode: {{ .defaultMode }}
{{- end }}
{{- range .Values.extraSecretMounts }}
- name: {{ .name }}
  secret:
    secretName: {{ .secretName }}
    defaultMode: {{ .defaultMode }}
{{- end }}
{{- end -}}
