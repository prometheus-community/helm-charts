{{/* Shortened name suffixed with upgrade-crd */}}
{{- define "kube-prometheus-stack.crd.upgradeJob.name" -}}
{{- print (include "kube-prometheus-stack.fullname" .) "-upgrade" -}}
{{- end -}}

{{- define "kube-prometheus-stack.crd.upgradeJob.labels" -}}
{{- include "kube-prometheus-stack.labels" . }}
app: {{ template "kube-prometheus-stack.name" . }}-operator
app.kubernetes.io/name: {{ template "kube-prometheus-stack.name" . }}-prometheus-operator
app.kubernetes.io/component: crds-upgrade
{{- end -}}

{{/* Create the name of crd.upgradeJob service account to use */}}
{{- define "kube-prometheus-stack.crd.upgradeJob.serviceAccountName" -}}
{{- if .Values.upgradeJob.serviceAccount.create -}}
    {{ default (include "kube-prometheus-stack.crd.upgradeJob.name" .) .Values.upgradeJob.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.upgradeJob.serviceAccount.name }}
{{- end -}}
{{- end -}}
