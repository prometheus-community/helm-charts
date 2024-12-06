{{/*
Expand the name of the chart.
*/}}
{{- define "opencti.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "opencti.fullname" -}}
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
{{- define "opencti.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "opencti.labels" -}}
helm.sh/chart: {{ include "opencti.chart" . }}
{{ include "opencti.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "opencti.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opencti.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "opencti.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "opencti.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
#######################
SERVER SECTION
#######################
*/}}

{{/*
Default server component
*/}}
{{- define "opencti.serverComponentLabel" -}}
opencti.component: server
{{- end -}}

{{/*
Generate labels for server component
*/}}
{{- define "opencti.serverLabels" -}}
{{- toYaml (merge ((include "opencti.labels" .) | fromYaml) ((include "opencti.serverComponentLabel" .) | fromYaml)) }}
{{- end }}

{{/*
Generate selectorLabels for server component
*/}}
{{- define "opencti.selectorServerLabels" -}}
{{- toYaml (merge ((include "opencti.selectorLabels" .) | fromYaml) ((include "opencti.serverComponentLabel" .) | fromYaml)) }}
{{- end }}

{{/*
Ref: https://github.com/aws/karpenter-provider-aws/blob/main/charts/karpenter/templates/_helpers.tpl
Patch the label selector on an object
This template will add a labelSelector using matchLabels to the object referenced at _target if there is no labelSelector specified.
The matchLabels are created with the selectorLabels template.
This works because Helm treats dictionaries as mutable objects and allows passing them by reference.
*/}}
{{- define "opencti.patchSelectorServerLabels" -}}
{{- if not (hasKey ._target "labelSelector") }}
{{- $selectorLabels := (include "opencti.selectorServerLabels" .) | fromYaml }}
{{- $_ := set ._target "labelSelector" (dict "matchLabels" $selectorLabels) }}
{{- end }}
{{- end }}

{{/*
Ref: https://github.com/aws/karpenter-provider-aws/blob/main/charts/karpenter/templates/_helpers.tpl
Patch topology spread constraints
This template uses the opencti.selectorLabels template to add a labelSelector to topologySpreadConstraints if one isn't specified.
This works because Helm treats dictionaries as mutable objects and allows passing them by reference.
*/}}
{{- define "opencti.patchTopologySpreadConstraintsServer" -}}
{{- range $constraint := .Values.topologySpreadConstraints }}
{{- include "opencti.patchSelectorServerLabels" (merge (dict "_target" $constraint (include "opencti.selectorServerLabels" $)) $) }}
{{- end }}
{{- end }}

{{/*
#######################
WORKER SECTION
#######################
*/}}

{{/*
Default worker component
*/}}
{{- define "opencti.workerComponentLabel" -}}
opencti.component: worker
{{- end -}}

{{/*
Generate labels for worker component
*/}}
{{- define "opencti.workerLabels" -}}
{{- toYaml (merge ((include "opencti.labels" .) | fromYaml) ((include "opencti.workerComponentLabel" .) | fromYaml)) }}
{{- end }}

{{/*
Generate selectorLabels for worker component
*/}}
{{- define "opencti.selectorWorkerLabels" -}}
{{- toYaml (merge ((include "opencti.selectorLabels" .) | fromYaml) ((include "opencti.workerComponentLabel" .) | fromYaml)) }}
{{- end }}

{{/*
Ref: https://github.com/aws/karpenter-provider-aws/blob/main/charts/karpenter/templates/_helpers.tpl
Patch the label selector on an object
This template will add a labelSelector using matchLabels to the object referenced at _target if there is no labelSelector specified.
The matchLabels are created with the selectorLabels template.
This works because Helm treats dictionaries as mutable objects and allows passing them by reference.
*/}}
{{- define "opencti.patchSelectorWorkerLabels" -}}
{{- if not (hasKey ._target "labelSelector") }}
{{- $selectorLabels := (include "opencti.selectorWorkerLabels" .) | fromYaml }}
{{- $_ := set ._target "labelSelector" (dict "matchLabels" $selectorLabels) }}
{{- end }}
{{- end }}

{{/*
Ref: https://github.com/aws/karpenter-provider-aws/blob/main/charts/karpenter/templates/_helpers.tpl
Patch topology spread constraints
This template uses the opencti.selectorLabels template to add a labelSelector to topologySpreadConstraints if one isn't specified.
This works because Helm treats dictionaries as mutable objects and allows passing them by reference.
*/}}
{{- define "opencti.patchTopologySpreadConstraintsWorker" -}}
{{- range $constraint := .Values.worker.topologySpreadConstraints }}
{{- include "opencti.patchSelectorWorkerLabels" (merge (dict "_target" $constraint (include "opencti.selectorWorkerLabels" $)) $) }}
{{- end }}
{{- end }}
