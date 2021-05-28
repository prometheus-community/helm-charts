{{- /*
Generated file. Do not change in-place! In order to change this file first read following link:
https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack/hack
*/ -}}
{{- define "rules.names" }}
rules:
  - "alertmanager.rules"
  - "general.rules"
  - "k8s.rules"
  - "kube-apiserver.rules"
  - "kube-apiserver-availability.rules"
  - "kube-apiserver-error"
  - "kube-apiserver-slos"
  - "kube-prometheus-general.rules"
  - "kube-prometheus-node-alerting.rules"
  - "kube-prometheus-node-recording.rules"
  - "kube-scheduler.rules"
  - "kube-state-metrics"
  - "kubelet.rules"
  - "kubernetes-absent"
  - "kubernetes-resources"
  - "kubernetes-storage"
  - "kubernetes-system"
  - "kubernetes-system-apiserver"
  - "kubernetes-system-kubelet"
  - "kubernetes-system-controller-manager"
  - "kubernetes-system-scheduler"
  - "node-exporter.rules"
  - "node-exporter"
  - "node.rules"
  - "node-network"
  - "node-time"
  - "prometheus-operator"
  - "prometheus.rules"
  - "prometheus"
  - "kubernetes-apps"
  - "etcd"
{{- end }}