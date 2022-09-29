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
Returns pod spec
*/}}
{{- define "prometheus-pushgateway.podSpec" -}}
      serviceAccountName: {{ template "prometheus-pushgateway.serviceAccountName" . }}
      {{- if .Values.priorityClassName }}
      priorityClassName: {{ .Values.priorityClassName | quote }}
      {{- end }}
    {{- if .Values.imagePullSecrets }}
      imagePullSecrets:
{{ toYaml .Values.imagePullSecrets | indent 8 }}
    {{- end }}
      {{- if .Values.extraInitContainers }}
      initContainers:
        {{ toYaml .Values.extraInitContainers | nindent 8 }}      
      {{- end }}
      containers:
        {{- if .Values.extraContainers }}
{{ toYaml .Values.extraContainers | indent 8 }}
        {{- end }}
        - name: pushgateway
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
        {{- if .Values.extraVars }}
          env:
{{ toYaml .Values.extraVars | indent 12 }}
        {{- end }}
        {{- if .Values.extraArgs }}
          args:
{{ toYaml .Values.extraArgs | indent 12 }}
        {{- end }}
          ports:
            - name: metrics
              containerPort: 9091
              protocol: TCP
{{- if .Values.liveness.enabled }}
          livenessProbe:
{{ toYaml .Values.liveness.probe | indent 12 }}
        {{- end }}
{{- if .Values.readiness.enabled }}
          readinessProbe:
{{ toYaml .Values.readiness.probe | indent 12 }}
        {{- end }}
          resources:
{{ toYaml .Values.resources | indent 12 }}
        {{- if .Values.containerSecurityContext }}
          securityContext:
{{ toYaml .Values.containerSecurityContext | indent 12 }}
        {{- end }}
          volumeMounts:
            - name: storage-volume
              mountPath: "{{ .Values.persistentVolume.mountPath }}"
              subPath: "{{ .Values.persistentVolume.subPath }}"
          {{- if .Values.extraVolumeMounts }}
{{ toYaml .Values.extraVolumeMounts | indent 12 }}
          {{- end }}
    {{- if .Values.nodeSelector }}
      nodeSelector:
{{ toYaml .Values.nodeSelector | indent 8 }}
    {{- end }}
    {{- if .Values.tolerations }}
      tolerations:
{{ toYaml .Values.tolerations | indent 8 }}
    {{- end }}
    {{- if .Values.affinity }}
      affinity:
{{ toYaml .Values.affinity | indent 8 }}
    {{- end }}
    {{- if .Values.topologySpreadConstraints }}
      topologySpreadConstraints:
{{ toYaml .Values.topologySpreadConstraints | indent 8 }}
    {{- end }}
    {{- if .Values.securityContext }}
      securityContext:
{{ toYaml .Values.securityContext | indent 8 }}
    {{- end }}
      volumes:
      {{- $storageVolumeAsPVCTemplate := and .Values.runAsStatefulSet .Values.persistentVolume.enabled -}}
      {{- if not $storageVolumeAsPVCTemplate }}
        - name: storage-volume
        {{- if .Values.persistentVolume.enabled }}
          persistentVolumeClaim:
            claimName: {{ if .Values.persistentVolume.existingClaim }}{{ .Values.persistentVolume.existingClaim }}{{- else }}{{ template "prometheus-pushgateway.fullname" . }}{{- end }}
        {{- else }}
          emptyDir: {}
        {{- end -}}
      {{- end -}}
      {{- if .Values.extraVolumes }}
{{ toYaml .Values.extraVolumes | indent 8 }}
      {{- else if $storageVolumeAsPVCTemplate }}
        []
      {{- end }}

{{- end }}
