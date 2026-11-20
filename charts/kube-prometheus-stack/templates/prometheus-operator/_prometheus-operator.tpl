{{/* Generate basic labels for prometheus-operator */}}
{{- define "kube-prometheus-stack.prometheus-operator.labels" }}
{{- include "kube-prometheus-stack.labels" . }}
app: {{ template "kube-prometheus-stack.name" . }}-operator
app.kubernetes.io/name: {{ template "kube-prometheus-stack.name" . }}-prometheus-operator
app.kubernetes.io/component: prometheus-operator
{{- end }}

{{/*
Pod labels for prometheus-operator: the common labels without the two that carry the chart
version. In this chart app.kubernetes.io/version is .Chart.Version, not .Chart.AppVersion, and
chart is name-version, so both change on every chart release. Including them in the pod template
restarts the operator on every helm upgrade even when nothing about the workload changed.
*/}}
{{- define "kube-prometheus-stack.prometheus-operator.podLabels" }}
{{- $podLabels := (include "kube-prometheus-stack.prometheus-operator.labels" . | fromYaml) }}
{{- omit $podLabels "chart" "app.kubernetes.io/version" | toYaml }}
{{- end }}

{{/*
Returns "true" if the secret the operator itself mounts stores its certificates under the
kubernetes.io/tls keys (ca.crt, tls.crt, tls.key) instead of ca, cert, key.

A secret named by prometheusOperator.tls.secretName is always read as kubernetes.io/tls, so a
secret you manage yourself is read the same way whatever the admission webhook settings are.
Without that value the operator mounts the admission secret, whose layout depends on how it was
created, so the webhook helper decides.
*/}}
{{- define "kube-prometheus-stack.prometheus-operator.tlsSecretKeys" -}}
{{- if .Values.prometheusOperator.tls.secretName -}}
true
{{- else -}}
{{- include "kube-prometheus-stack.prometheus-operator-webhook.tlsSecretKeys" . -}}
{{- end -}}
{{- end }}
