{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "prometheus-kafka-exporter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "prometheus-kafka-exporter.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "prometheus-kafka-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "prometheus-kafka-exporter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "prometheus-kafka-exporter.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

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

{{/*
Create the name of the SASL SCRAM secret to use
*/}}
{{- define "prometheus-kafka-exporter.saslScramSecretName" -}}
{{- if .Values.sasl.scram.secretName -}}
    {{ .Values.sasl.scram.secretName }}
{{- else -}}
    {{ include "prometheus-kafka-exporter.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Name of the secret holding the OAuthBearer client credentials
*/}}
{{- define "prometheus-kafka-exporter.saslOAuthBearerSecretName" -}}
{{- if .Values.sasl.oauthbearer.secretName -}}
    {{ .Values.sasl.oauthbearer.secretName }}
{{- else -}}
    {{ include "prometheus-kafka-exporter.fullname" . }}-oauthbearer
{{- end -}}
{{- end -}}

{{/*
OAuthBearer token mode: "file", "url" or "" when OAuthBearer is off
*/}}
{{- define "prometheus-kafka-exporter.oauthbearerMode" -}}
{{- $o := .Values.sasl.oauthbearer -}}
{{- if and .Values.sasl.enabled $o.enabled -}}
  {{- if or $o.tokenFile $o.serviceAccountToken.enabled -}}
    file
  {{- else if $o.tokenUrl -}}
    {{- if not (or $o.clientId $o.secretName) -}}
      {{- fail "sasl.oauthbearer.tokenUrl needs sasl.oauthbearer.clientId or sasl.oauthbearer.secretName" -}}
    {{- end -}}
    url
  {{- else -}}
    {{- fail "sasl.oauthbearer needs serviceAccountToken.enabled, tokenFile or tokenUrl" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Path the exporter reads the OAuthBearer token from
*/}}
{{- define "prometheus-kafka-exporter.oauthbearerTokenFile" -}}
{{- .Values.sasl.oauthbearer.tokenFile | default "/var/run/secrets/kafka-oauthbearer/token" -}}
{{- end -}}

{{/*
Formats imagePullSecrets. Input is (dict "Values" .Values "imagePullSecrets" .{specific imagePullSecrets})
*/}}
{{- define "prometheus-kafka-exporter.imagePullSecrets" -}}
{{- range (concat .Values.global.imagePullSecrets .imagePullSecrets) }}
  {{- if eq (typeOf .) "map[string]interface {}" }}
- {{ toYaml . | trim }}
  {{- else }}
- name: {{ . }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Adds kafka cluster server label to prometheus metrics
*/}}
{{- define "prometheus-kafka-exporter.kafkaLabels" -}}
{{- if .Values.kafkaLabels }}
  {{- $kafkaLabelsList := list }}
  {{- range $key, $value := .Values.kafkaLabels }}
    {{- $kafkaLabelsList = append $kafkaLabelsList (printf "%s=%s" $key $value) }}
  {{- end }}
  {{- $kafkaLabelsArgs := join "," $kafkaLabelsList }}
  {{- $kafkaLabelsArgs -}}
{{- end -}}
{{- end -}}
