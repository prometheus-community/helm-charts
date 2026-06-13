{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "prometheus-pushgateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Namespace to set on the resources
*/}}
{{- define "prometheus-pushgateway.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "prometheus-pushgateway.fullname" -}}
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
{{- define "prometheus-pushgateway.chart" -}}
{{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "prometheus-pushgateway.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "prometheus-pushgateway.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create default labels
*/}}
{{- define "prometheus-pushgateway.defaultLabels" -}}
helm.sh/chart: {{ include "prometheus-pushgateway.chart" . }}
{{ include "prometheus-pushgateway.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.podLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "prometheus-pushgateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "prometheus-pushgateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Define webConfiguration
*/}}
{{- define "prometheus-pushgateway.webConfiguration" -}}
basic_auth_users:
{{- range $k, $v := .Values.webConfiguration.basicAuthUsers }}
  {{ $k }}: {{ htpasswd "" $v | trimPrefix ":"}}
{{- end }}
{{- end }}

{{/*
Return web configuration secret name
*/}}
{{- define "prometheus-pushgateway.webConfigurationSecretName" -}}
{{- $webConfiguration := .Values.webConfiguration | default dict -}}
{{- $existingSecret := get $webConfiguration "existingSecret" | default dict -}}
{{- $existingSecretName := get $existingSecret "name" | default "" -}}
{{- if $existingSecretName -}}
{{- $existingSecretName -}}
{{- else -}}
{{- include "prometheus-pushgateway.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Define Authorization
*/}}
{{- define "prometheus-pushgateway.Authorization" -}}
{{- $users := keys .Values.webConfiguration.basicAuthUsers }}
{{- $user := first $users }}
{{- $password := index .Values.webConfiguration.basicAuthUsers $user }}
{{- $user }}:{{ $password }}
{{- end }}

{{/*
Define basicAuth
*/}}
{{- define "prometheus-pushgateway.basicAuth" -}}
{{- $users := keys .Values.webConfiguration.basicAuthUsers }}
{{- $user := first $users }}
{{- $password := index .Values.webConfiguration.basicAuthUsers $user -}}
user: {{ $user | b64enc | quote }}
password: {{ $password | b64enc | quote }}
{{- end }}

{{/*
Set the image with or without the registry
*/}}
{{- define "prometheus-pushgateway.image" -}}
{{- $registry := default .Values.image.registry (.Values.global).imageRegistry }}
{{- $repository := .Values.image.repository }}
{{- $tag := default .Chart.AppVersion .Values.image.tag }}
{{- if $registry }}
    {{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- else -}}
    {{- printf "%s:%s"  $repository $tag -}}
{{- end -}}
{{- end -}}

{{/*
Returns pod spec
*/}}
{{- define "prometheus-pushgateway.podSpec" -}}
serviceAccountName: {{ include "prometheus-pushgateway.serviceAccountName" . }}
automountServiceAccountToken: {{ .Values.automountServiceAccountToken }}
{{- with .Values.priorityClassName }}
priorityClassName: {{ . | quote }}
{{- end }}
{{- with .Values.hostAliases }}
hostAliases:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- with (.Values.global).imagePullSecrets | default .Values.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.extraInitContainers }}
initContainers:
  {{- toYaml . | nindent 2 }}
{{- end }}
containers:
  {{- with .Values.extraContainers }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
  - name: pushgateway
    image: {{ include "prometheus-pushgateway.image" . }}
    imagePullPolicy: {{ .Values.image.pullPolicy }}
    {{- with .Values.extraVars }}
    env:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- if or .Values.extraArgs .Values.webConfiguration }}
    args:
    {{- with .Values.extraArgs }}
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- if .Values.webConfiguration }}
      - --web.config.file=/etc/config/web-config.yaml
    {{- end }}
    {{- end }}
    ports:
      - name: metrics
        containerPort: 9091
        protocol: TCP
    {{- if .Values.liveness.enabled }}
    {{- $livenessCommon := omit .Values.liveness.probe "httpGet" }}
    livenessProbe:
    {{- with .Values.liveness.probe }}
      httpGet:
        path: {{ .httpGet.path }}
        port: {{ .httpGet.port }}
        scheme: {{ .httpGet.scheme }}
        {{- if or .httpGet.httpHeaders $.Values.webConfiguration.basicAuthUsers }}
        httpHeaders:
        {{- if $.Values.webConfiguration.basicAuthUsers }}
          - name: Authorization
            value: Basic {{ include "prometheus-pushgateway.Authorization" $ | b64enc }}
        {{- end }}
        {{- with .httpGet.httpHeaders }}
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- end }}
        {{- toYaml $livenessCommon | nindent 6 }}
      {{- end }}
    {{- end }}
    {{- if .Values.readiness.enabled }}
    {{- $readinessCommon := omit .Values.readiness.probe "httpGet" }}
    readinessProbe:
    {{- with .Values.readiness.probe }}
      httpGet:
        path: {{ .httpGet.path }}
        port: {{ .httpGet.port }}
        scheme: {{ .httpGet.scheme }}
        {{- if or .httpGet.httpHeaders $.Values.webConfiguration.basicAuthUsers }}
        httpHeaders:
        {{- if $.Values.webConfiguration.basicAuthUsers }}
          - name: Authorization
            value: Basic {{ include "prometheus-pushgateway.Authorization" $ | b64enc }}
        {{- end }}
        {{- with .httpGet.httpHeaders }}
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- end }}
        {{- toYaml $readinessCommon | nindent 6 }}
      {{- end }}
    {{- end }}
    {{- with .Values.resources }}
    resources:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .Values.containerSecurityContext }}
    securityContext:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .Values.lifecycle }}
    lifecycle: {{ toYaml . | nindent 6 }}
    {{- end }}
    volumeMounts:
      - name: storage-volume
        mountPath: "{{ .Values.persistentVolume.mountPath }}"
        subPath: "{{ .Values.persistentVolume.subPath }}"
      {{- if .Values.webConfiguration }}
      - name: web-config
        mountPath: "/etc/config"
      {{- end }}
      {{- with .Values.extraVolumeMounts }}
      {{- toYaml . | nindent 6 }}
      {{- end }}
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- if or .Values.podAntiAffinity .Values.affinity }}
affinity:
{{- end }}
  {{- with .Values.affinity }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- if eq .Values.podAntiAffinity "hard" }}
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - topologyKey: {{ .Values.podAntiAffinityTopologyKey }}
        labelSelector:
          matchExpressions:
            - {key: app.kubernetes.io/name, operator: In, values: [{{ include "prometheus-pushgateway.name" . }}]}
  {{- else if eq .Values.podAntiAffinity "soft" }}
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          topologyKey: {{ .Values.podAntiAffinityTopologyKey }}
          labelSelector:
            matchExpressions:
              - {key: app.kubernetes.io/name, operator: In, values: [{{ include "prometheus-pushgateway.name" . }}]}
  {{- end }}
{{- with .Values.topologySpreadConstraints }}
topologySpreadConstraints:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.securityContext }}
securityContext:
  {{- toYaml . | nindent 2 }}
{{- end }}
volumes:
  {{- $storageVolumeAsPVCTemplate := and .Values.runAsStatefulSet .Values.persistentVolume.enabled -}}
  {{- if not $storageVolumeAsPVCTemplate }}
  - name: storage-volume
  {{- if .Values.persistentVolume.enabled }}
    persistentVolumeClaim:
      claimName: {{ if .Values.persistentVolume.existingClaim }}{{ .Values.persistentVolume.existingClaim }}{{- else }}{{ include "prometheus-pushgateway.fullname" . }}{{- end }}
  {{- else }}
    emptyDir: {}
  {{- end }}
  {{- if .Values.webConfiguration }}
  - name: web-config
    secret:
      secretName: {{ include "prometheus-pushgateway.webConfigurationSecretName" . }}
  {{- end }}
  {{- end }}
  {{- if .Values.extraVolumes }}
  {{- toYaml .Values.extraVolumes  | nindent 2 }}
  {{- else if $storageVolumeAsPVCTemplate }}
  {{- if .Values.webConfiguration }}
  - name: web-config
    secret:
      secretName: {{ include "prometheus-pushgateway.webConfigurationSecretName" . }}
  {{- else }}
  []
  {{- end }}
  {{- end }}
{{- end }}
