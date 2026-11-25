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

{{- define "prometheus-blackbox-exporter.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
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
The image to use
*/}}
{{- define "prometheus-blackbox-exporter.config-reloader.image" -}}
{{- with (.Values.global.imageRegistry | default .Values.configReloader.image.registry) -}}{{ . }}/{{- end }}
{{- .Values.configReloader.image.repository -}}:{{- .Values.configReloader.image.tag -}}
{{- with .Values.configReloader.image.digest -}}@{{ .}}{{- end -}}
{{- end -}}

{{/*
Define pod spec to be reused by highlevel resources (deployment, daemonset)
*/}}
{{- define "prometheus-blackbox-exporter.podSpec" -}}
{{- if and .Values.configReloader.enabled .Values.configAutoReload.enabled }}
{{- fail "configReloader.enabled and configAutoReload.enabled are mutually exclusive: enable only one way of reloading the configuration" }}
{{- end }}
{{- if .Values.configAutoReload.enabled }}
{{- $interval := .Values.configAutoReload.interval }}
{{- $isNumber := or (kindIs "int" $interval) (kindIs "int64" $interval) (kindIs "float64" $interval) }}
{{- if or (not $isNumber) (ne (float64 $interval) (floor $interval)) (lt (float64 $interval) 1.0) }}
{{- fail "configAutoReload.interval must be a whole number of seconds greater than 0" }}
{{- end }}
{{- end -}}
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
{{- if not (kindIs "invalid" .Values.terminationGracePeriodSeconds) }}
terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds }}
{{- end }}
{{- with .Values.priorityClassName }}
priorityClassName: "{{ . }}"
{{- end }}
{{- with .Values.podSecurityContext }}
securityContext:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .Values.extraInitContainers }}
initContainers:
{{- if kindIs "string" . }}
  {{- tpl . $ | nindent 2 }}
{{- else }}
  {{-  toYaml . | nindent 2 }}
{{- end -}}
{{- end }}

containers:
{{ with .Values.extraContainers }}
{{- if kindIs "string" . }}
  {{- tpl . $ }}
{{- else }}
  {{-  toYaml . }}
{{- end -}}
{{- end }}

{{- if .Values.configReloader.enabled }}
{{- $webConfigurationMode := include "prometheus-blackbox-exporter.webConfigurationMode" . }}
{{- if include "prometheus-blackbox-exporter.webConfigurationExistingSecretName" . }}
{{- fail "configReloader.enabled cannot be combined with webConfiguration.existingSecret: the chart cannot tell whether the reload endpoint needs TLS or credentials. Use webConfiguration.config, or disable the config reloader and set configAutoReload.enabled instead." }}
{{- else if eq $webConfigurationMode "auth" }}
{{- fail "configReloader.enabled cannot be combined with basic_auth_users or a required client certificate in webConfiguration.config: the config reloader cannot authenticate to /-/reload without putting credentials into the pod spec. Disable the config reloader and set configAutoReload.enabled instead." }}
{{- end }}
- name: config-reloader
  image: {{ include "prometheus-blackbox-exporter.config-reloader.image" . }}
  imagePullPolicy: {{ .Values.configReloader.image.pullPolicy }}
  args:
    - --config-file={{ .Values.configPath | default "/config/blackbox.yaml" }}
    - --watch-interval={{ .Values.configReloader.config.watchInterval }}
    - --reload-url={{ if eq $webConfigurationMode "https" }}https{{ else }}http{{ end }}://127.0.0.1:{{ .Values.containerPort }}/-/reload
    - --listen-address=:{{ .Values.configReloader.containerPort }}
    - --log-format={{ .Values.configReloader.config.logFormat }}
    - --log-level={{ .Values.configReloader.config.logLevel }}
  {{- with .Values.configReloader.resources }}
  resources:
{{- toYaml . | nindent 4 }}
  {{- end }}
  ports:
    - name: reloader-web
      containerPort: {{ .Values.configReloader.containerPort }}
      protocol: TCP
  livenessProbe:
    {{- toYaml .Values.configReloader.livenessProbe | nindent 4 }}
  readinessProbe:
    {{- toYaml .Values.configReloader.readinessProbe | nindent 4 }}
  volumeMounts:
    - mountPath: /config
      name: config
  {{- with .Values.configReloader.securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
- name: blackbox-exporter
  image: {{ include "prometheus-blackbox-exporter.image" . }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  {{- with .Values.securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.extraEnv }}
  env:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.extraEnvFrom }}
  envFrom:
    {{- toYaml . | nindent 4 }}
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
  {{- if .Values.configAutoReload.enabled }}
  - "--config.enable-auto-reload"
  - "--config.auto-reload-interval={{ .Values.configAutoReload.interval | int }}"
  {{- end }}
  {{- if include "prometheus-blackbox-exporter.webConfigurationEnabled" . }}
  - "--web.config.file=/etc/blackbox-exporter/web-config/web-config.yaml"
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
    {{- if .Values.hostPort }}
    hostPort: {{ .Values.hostPort }}
    {{- end }}
  livenessProbe:
  {{- include "prometheus-blackbox-exporter.probe" (dict "probe" .Values.livenessProbe "context" .) | trim | nindent 4 }}
  readinessProbe:
  {{- include "prometheus-blackbox-exporter.probe" (dict "probe" .Values.readinessProbe "context" .) | trim | nindent 4 }}
  {{- with .Values.startupProbe }}
  startupProbe:
  {{- include "prometheus-blackbox-exporter.probe" (dict "probe" . "context" $) | trim | nindent 4 }}
  {{- end }}
  {{- with .Values.lifecycle }}
  lifecycle:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  volumeMounts:
  - mountPath: /config
    name: config
  {{- if include "prometheus-blackbox-exporter.webConfigurationEnabled" . }}
  - mountPath: /etc/blackbox-exporter/web-config
    name: web-config
    readOnly: true
  {{- end }}
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
{{- if include "prometheus-blackbox-exporter.webConfigurationEnabled" . }}
- name: web-config
  secret:
    secretName: {{ include "prometheus-blackbox-exporter.webConfigurationSecretName" . }}
    items:
      - key: web-config.yaml
        path: web-config.yaml
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

{{/*
Pod labels: the common labels without helm.sh/chart. That label carries the chart version, so
including it in the pod template changes the pod-template hash on every chart release, rolling
the workload even when neither the image nor the configuration changed.
*/}}
{{- define "prometheus-blackbox-exporter.podLabels" -}}
{{- $labels := omit (include "prometheus-blackbox-exporter.labels" . | fromYaml) "helm.sh/chart" -}}
{{- merge (deepCopy (.Values.pod.labels | default dict)) $labels | toYaml -}}
{{- end }}

{{/*
Return the name of an existing Secret holding the web configuration, or "" if none is set.
*/}}
{{- define "prometheus-blackbox-exporter.webConfigurationExistingSecretName" -}}
{{- $webConfiguration := .Values.webConfiguration | default dict -}}
{{- $existingSecret := get $webConfiguration "existingSecret" | default dict -}}
{{- get $existingSecret "name" | default "" -}}
{{- end -}}

{{/*
Return "true" if a web configuration (inline or existing Secret) is set, or "" otherwise.
*/}}
{{- define "prometheus-blackbox-exporter.webConfigurationEnabled" -}}
{{- $webConfiguration := .Values.webConfiguration | default dict -}}
{{- if or (get $webConfiguration "config") (include "prometheus-blackbox-exporter.webConfigurationExistingSecretName" .) -}}
true
{{- end -}}
{{- end -}}

{{/*
Return the Secret name to mount as the web configuration: the user-provided
existing Secret when set, otherwise the chart-managed Secret.
*/}}
{{- define "prometheus-blackbox-exporter.webConfigurationSecretName" -}}
{{- $existingSecretName := include "prometheus-blackbox-exporter.webConfigurationExistingSecretName" . -}}
{{- if $existingSecretName -}}
{{- $existingSecretName -}}
{{- else -}}
{{- printf "%s-web-config" (include "prometheus-blackbox-exporter.fullname" . | trunc 52 | trimSuffix "-") -}}
{{- end -}}
{{- end -}}

{{/*
How the web configuration affects in-pod HTTP clients (kubelet probes, config reloader):
  ""      no web configuration, or one that neither enables TLS nor requires authentication
  "https" TLS without client authentication: plain HTTPS requests still succeed
  "auth"  basic auth or required client certificates, or an existing Secret whose
          content the chart cannot inspect: unauthenticated HTTP(S) requests fail
*/}}
{{- define "prometheus-blackbox-exporter.webConfigurationMode" -}}
{{- if include "prometheus-blackbox-exporter.webConfigurationExistingSecretName" . -}}
auth
{{- else -}}
{{- $config := (.Values.webConfiguration | default dict).config | default dict -}}
{{- $tls := get $config "tls_server_config" | default dict -}}
{{- if or (get $config "basic_auth_users") (has (get $tls "client_auth_type") (list "RequireAnyClientCert" "RequireClientCert" "RequireAndVerifyClientCert")) -}}
auth
{{- else if $tls -}}
https
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Render a liveness or readiness probe, adapting an httpGet handler to the web configuration:
switch it to HTTPS when TLS is enabled, or to a tcpSocket check on the same port when
requests need credentials. Credentials are never written into the pod spec.
Usage: include "prometheus-blackbox-exporter.probe" (dict "probe" .Values.livenessProbe "context" $)
*/}}
{{- define "prometheus-blackbox-exporter.probe" -}}
{{- $probe := .probe -}}
{{- $mode := include "prometheus-blackbox-exporter.webConfigurationMode" .context -}}
{{- if and $mode (kindIs "map" $probe) (hasKey $probe "httpGet") -}}
{{- $probe = deepCopy $probe -}}
{{- if eq $mode "auth" -}}
{{- $port := $probe.httpGet.port -}}
{{- $probe = omit $probe "httpGet" -}}
{{- $_ := set $probe "tcpSocket" (dict "port" $port) -}}
{{- else -}}
{{- $_ := set $probe.httpGet "scheme" "HTTPS" -}}
{{- end -}}
{{- end -}}
{{- toYaml $probe -}}
{{- end -}}

{{/*
Return a checksum of the inline web configuration rendered into the chart-managed Secret, or ""
when there is none. The exporter decides between HTTP and HTTPS when it starts listening, so a
change to the web configuration must restart the pods; an existing Secret is managed outside the
chart and cannot be tracked here.
*/}}
{{- define "prometheus-blackbox-exporter.webConfigurationChecksum" -}}
{{- if and (.Values.webConfiguration).config (not (include "prometheus-blackbox-exporter.webConfigurationExistingSecretName" .)) -}}
{{- toYaml .Values.webConfiguration.config | sha256sum -}}
{{- end -}}
{{- end -}}
