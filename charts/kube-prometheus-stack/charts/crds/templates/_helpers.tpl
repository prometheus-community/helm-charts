{{/* Shortened name suffixed with upgrade-crd */}}
{{- define "kube-prometheus-stack.upgradeCRD.name" -}}
{{- print (include "kube-prometheus-stack.fullname" .) "-upgrade" -}}
{{- end -}}

{{- define "kube-prometheus-stack.upgradeCRD.labels" -}}
{{- include "kube-prometheus-stack.labels" . }}
app: {{ template "kube-prometheus-stack.name" . }}-operator
app.kubernetes.io/name: {{ template "kube-prometheus-stack.name" . }}-prometheus-operator
app.kubernetes.io/component: crds-upgrade
{{- end -}}

{{/* Create the name of upgradeCRD service account to use */}}
{{- define "kube-prometheus-stack.upgradeCRD.serviceAccountName" -}}
{{- if .Values.upgradeJob.serviceAccount.create -}}
    {{ default (include "kube-prometheus-stack.upgradeCRD.name" .) .Values.upgradeJob.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.upgradeJob.serviceAccount.name }}
{{- end -}}
{{- end -}}
