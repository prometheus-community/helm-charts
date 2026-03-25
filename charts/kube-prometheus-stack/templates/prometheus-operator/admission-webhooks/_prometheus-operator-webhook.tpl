{{/* Generate basic labels for prometheus-operator-webhook */}}
{{- define "kube-prometheus-stack.prometheus-operator-webhook.labels" }}
{{- include "kube-prometheus-stack.labels" . }}
app.kubernetes.io/name: {{ template "kube-prometheus-stack.name" . }}-prometheus-operator
app.kubernetes.io/component: prometheus-operator-webhook
{{- end }}

{{- define "kube-prometheus-stack.prometheus-operator-webhook.annotations" }}
{{- if .Values.prometheusOperator.admissionWebhooks.certManager.enabled }}
certmanager.k8s.io/inject-ca-from: {{ printf "%s/%s-admission" (include "kube-prometheus-stack.namespace" .) (include "kube-prometheus-stack.fullname" .) | quote }}
cert-manager.io/inject-ca-from: {{ printf "%s/%s-admission" (include "kube-prometheus-stack.namespace" .) (include "kube-prometheus-stack.fullname" .) | quote }}
{{- end }}
{{- end }}