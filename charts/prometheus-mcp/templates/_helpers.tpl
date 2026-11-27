{{/*
Chart name.
*/}}
{{- define "prometheus-mcp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "prometheus-mcp.fullname" -}}
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
{{- define "prometheus-mcp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "prometheus-mcp.labels" -}}
helm.sh/chart: {{ include "prometheus-mcp.chart" . }}
{{ include "prometheus-mcp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "prometheus-mcp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "prometheus-mcp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use.
*/}}
{{- define "prometheus-mcp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "prometheus-mcp.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Test container security context.
*/}}
{{- define "prometheus-mcp.testContainerSecurityContext" -}}
{{- with .Values.test.containerSecurityContext -}}
securityContext:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Name of the Secret mounted as the --http.config file: the user's existing
Secret, or the one secret.yaml renders. Shared by deployment.yaml and
secret.yaml so the two cannot drift.
*/}}
{{- define "prometheus-mcp.httpConfigSecretName" -}}
{{- .Values.httpConfig.existingSecret | default (printf "%s-http-config" (include "prometheus-mcp.fullname" .) | trunc 63 | trimSuffix "-") -}}
{{- end -}}

{{/*
Included by deployment.yaml and secret.yaml. Upstream exits at startup when
the --http.config file is missing or invalid, and never sees config the chart
drops (both sources set, or enabled=false), so all of these fail at render
time.
*/}}
{{- define "prometheus-mcp.validateHTTPConfig" -}}
{{- $c := .Values.httpConfig -}}
{{- if $c.enabled -}}
{{- if not (or $c.existingSecret $c.config) -}}
{{- fail "httpConfig.enabled is true but neither httpConfig.existingSecret nor httpConfig.config is set" -}}
{{- end -}}
{{- if and $c.existingSecret $c.config -}}
{{- fail "httpConfig.existingSecret and httpConfig.config are mutually exclusive: the chart would mount the existing Secret and silently ignore the inline config" -}}
{{- end -}}
{{- if not $c.secretKey -}}
{{- fail "httpConfig.secretKey must not be empty: it names the Secret data key mounted as the --http.config file" -}}
{{- end -}}
{{- /* A key the API server rejects never reaches the Secret; for an existing
Secret the mount would simply lack the file and the server would exit at
startup. */ -}}
{{- if or (not (regexMatch "^[-._a-zA-Z0-9]+$" $c.secretKey)) (has $c.secretKey (list "." "..")) -}}
{{- fail (printf "httpConfig.secretKey %q must be a valid Secret data key: alphanumerics, -, _ and ." $c.secretKey) -}}
{{- end -}}
{{- else if or $c.existingSecret $c.config -}}
{{- fail "httpConfig.config or httpConfig.existingSecret is set but httpConfig.enabled is false; the config would be ignored and the server would talk to Prometheus unauthenticated. Set httpConfig.enabled=true or remove the config" -}}
{{- end -}}
{{- end -}}

{{/*
Render-time validation of the remaining values the server would otherwise
mishandle silently or crash on at startup. Included by deployment.yaml.
*/}}
{{- define "prometheus-mcp.validateValues" -}}
{{- if or (not (kindIs "slice" .Values.mcp.tools)) (empty .Values.mcp.tools) -}}
{{- fail (printf "mcp.tools must be a non-empty list (got: %v). With --set, use e.g. --set mcp.tools[0]=core" .Values.mcp.tools) -}}
{{- end -}}
{{- /* Upstream matches tool names exactly and warn-skips unknown ones, so a
stray space or capital letter silently drops the tool. */ -}}
{{- range .Values.mcp.tools -}}
{{- if ne (toString .) (toString . | trim | lower) -}}
{{- fail (printf "mcp.tools entry %q must be a lowercase tool name with no surrounding whitespace" (toString .)) -}}
{{- end -}}
{{- end -}}
{{- /* Upstream honors "all" only when it is the sole entry; combined with
tool names it is warn-skipped and the server loads core plus the named tools. */ -}}
{{- if and (gt (len .Values.mcp.tools) 1) (has "all" .Values.mcp.tools) -}}
{{- fail (printf "mcp.tools must not combine \"all\" with other entries (got: %v)" .Values.mcp.tools) -}}
{{- end -}}
{{- $validLogLevels := list "debug" "info" "warn" "error" -}}
{{- if not (has (lower (toString .Values.log.level)) $validLogLevels) -}}
{{- fail (printf "log.level must be one of: %s (got: %s)" (join ", " $validLogLevels) .Values.log.level) -}}
{{- end -}}
{{- if .Values.log.format -}}
{{- $validLogFormats := list "logfmt" "json" -}}
{{- if not (has (toString .Values.log.format) $validLogFormats) -}}
{{- fail (printf "log.format must be one of: %s (got: %s)" (join ", " $validLogFormats) .Values.log.format) -}}
{{- end -}}
{{- end -}}
{{- if and .Values.prometheus.timeout (not (kindIs "string" .Values.prometheus.timeout)) -}}
{{- fail (printf "prometheus.timeout must be a duration string such as \"30s\" (got: %v)" .Values.prometheus.timeout) -}}
{{- end -}}
{{- if not .Values.prometheus.url -}}
{{- fail "prometheus.url must not be empty" -}}
{{- end -}}
{{- if not (hasPrefix "/" (toString .Values.telemetryPath)) -}}
{{- fail (printf "telemetryPath must start with / (got: %q)" (toString .Values.telemetryPath)) -}}
{{- end -}}
{{- /* Paths the server registers on its shared ServeMux; registering the
metrics handler on one of them panics at startup. "/" is allowed: upstream
skips its landing page when the telemetry path is "/". */ -}}
{{- $reservedPaths := list "/mcp" "/-/healthy" "/-/ready" "/docs/" -}}
{{- if or (has .Values.telemetryPath $reservedPaths) (hasPrefix "/debug/pprof" .Values.telemetryPath) -}}
{{- fail (printf "telemetryPath %q collides with a path the server already serves (%s, /debug/pprof/*)" .Values.telemetryPath (join ", " $reservedPaths)) -}}
{{- end -}}
{{- /* Flags the chart sets from values: a repeat via extraArgs is merged
(--mcp.tools) or refused at startup, never an override. --web.listen-address
is deliberately absent: exporter-toolkit declares it repeatable, so an extra
listener via extraArgs is legitimate. */ -}}
{{- $chartFlags := list "prometheus.url" "prometheus.backend" "prometheus.timeout" "prometheus.truncation-limit" "mcp.transport" "mcp.tools" "mcp.enable-toon-output" "mcp.enable-client-logging" "docs.auto-update" "dangerous.enable-tsdb-admin-tools" "http.config" "web.telemetry-path" "log.level" "log.format" "log.file" -}}
{{- range .Values.extraArgs -}}
{{- /* trim "no-" so a negated boolean (--no-docs.auto-update) is caught too */ -}}
{{- $flag := toString . | trimPrefix "--" | trimPrefix "no-" | splitList "=" | first -}}
{{- if has $flag $chartFlags -}}
{{- fail (printf "extraArgs entry %q repeats --%s, which the chart sets from values; use the corresponding value instead" (toString .) $flag) -}}
{{- end -}}
{{- end -}}
{{- end -}}
