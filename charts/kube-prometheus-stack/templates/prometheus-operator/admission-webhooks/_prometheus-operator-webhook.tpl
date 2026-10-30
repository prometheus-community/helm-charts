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

{{/* Returns "true" if the admission secret stores its certificates under the kubernetes.io/tls keys (ca.crt, tls.crt, tls.key) instead of ca, cert, key */}}
{{- define "kube-prometheus-stack.prometheus-operator-webhook.tlsSecretKeys" -}}
{{- $admissionWebhooks := .Values.prometheusOperator.admissionWebhooks -}}
{{- if or $admissionWebhooks.certManager.enabled (and $admissionWebhooks.enabled $admissionWebhooks.patch.enabled (eq $admissionWebhooks.patch.secretType "kubernetes.io/tls")) -}}
true
{{- end -}}
{{- end }}
