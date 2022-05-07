{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "prometheus-pushgateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "prometheus-pushgateway.fullname" -}}
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
{{- define "prometheus-pushgateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Create the name of the service account to use
*/}}
{{- define "prometheus-pushgateway.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "prometheus-pushgateway.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create default labels
*/}}
{{- define "prometheus-pushgateway.defaultLabels" -}}
{{- $labelChart := include "prometheus-pushgateway.chart" $ -}}
{{- $labelApp := include "prometheus-pushgateway.name" $ -}}
{{- $labels := dict "app" $labelApp "chart" $labelChart "release" .Release.Name "heritage" .Release.Service -}}
{{- $indent := .indent | default 4 -}}
{{ merge .extraLabels $labels | toYaml | indent $indent }}
{{- end -}}

{{/*
Return the appropriate apiVersion for networkpolicy.
*/}}
{{- define "prometheus-pushgateway.networkPolicy.apiVersion" -}}
{{- if semverCompare ">=1.4-0, <1.7-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else if semverCompare "^1.7-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Returns the Deployment only spec fields
*/}}
{{- define "prometheus-pushgateway.deploymentOnlySpec" -}}
{{- if .Values.strategy }}
  strategy:
{{ toYaml .Values.strategy | indent 4 }}
  volumes:
  - name: storage-volume
{{- if .Values.persistentVolume.enabled }}
    persistentVolumeClaim:
    claimName: {{ if .Values.persistentVolume.existingClaim }}{{ .Values.persistentVolume.existingClaim }}{{- else }}{{ template "prometheus-pushgateway.fullname" . }}{{- end }}
{{- else}}
    emptyDir: {}
    {{- if .Values.extraVolumes }}
{{ toYaml .Values.extraVolumes | indent 2 }}
    {{- end }}
{{- end -}}
{{- end }}
{{- end -}}
{{- if .Values.extraVolumes }}
  volumes:
{{ toYaml .Values.extraVolumes | indent 2 }}
{{- end }}

{{/*
Returns the StatefulSet only spec fields
*/}}
{{- define "prometheus-pushgateway.statefulsetOnlySpec" }}
  serviceName: {{ template "prometheus-pushgateway.fullname" . }}
  {{- if .Values.persistentVolume.enabled }}
  volumeClaimTemplates:
    - metadata:
        {{- if .Values.persistentVolume.annotations }}
        annotations:
      {{ toYaml .Values.persistentVolume.annotations | indent 10 }}
        {{- end }}
        labels:
{{ template "prometheus-pushgateway.defaultLabels" merge (dict "extraLabels" .Values.persistentVolumeLabels "indent" 10) . }}
        name: storage-volume
      spec:
        accessModes:
          {{ toYaml .Values.persistentVolume.accessModes }}
      {{- if .Values.persistentVolume.storageClass }}
      {{- if (eq "-" .Values.persistentVolume.storageClass) }}
        storageClassName: ""
      {{- else }}
        storageClassName: "{{ .Values.persistentVolume.storageClass }}"
      {{- end }}
      {{- end }}
        resources:
          requests:
            storage: "{{ .Values.persistentVolume.size }}"
  {{- end }}
{{- end }}
