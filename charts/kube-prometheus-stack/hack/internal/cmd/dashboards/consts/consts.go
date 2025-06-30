package consts

import (
	"bytes"
	"fmt"

	"main/internal/config"
	"main/internal/pythonish"
	"main/internal/types"
)

func DashboardsSourceCharts() types.DashboardsConfig {
	return types.DashboardsConfig{
		&types.DashboardFileSource{
			Source: "/files/dashboards/k8s-coredns.json",
			DashboardSourceBase: types.DashboardSourceBase{
				Destination:     "/templates/grafana/dashboards-1.14",
				Type:            types.DashboardJson,
				MinKubernetes:   "1.14.0-0",
				MulticlusterKey: ".Values.grafana.sidecar.dashboards.multicluster.global.enabled",
			},
		},
		&types.DashboardURLSource{
			Source: fmt.Sprintf("https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/%s/manifests/grafana-dashboardDefinitions.yaml", config.Repos["kube-prometheus"].HeadSha),
			DashboardSourceBase: types.DashboardSourceBase{
				Destination:     "/templates/grafana/dashboards-1.14",
				Type:            types.DashboardKubernetesYaml,
				MinKubernetes:   "1.14.0-0",
				MulticlusterKey: ".Values.grafana.sidecar.dashboards.multicluster.global.enabled",
			},
		},
		&types.DashboardGitSource{
			Repository: config.Repos["kubernetes-mixin"],
			Content:    "(import 'dashboards/windows.libsonnet') + (import 'config.libsonnet') + { _config+:: { windowsExporterSelector: 'job=\"windows-exporter\"', }}",
			Cwd:        ".",
			DashboardSourceBase: types.DashboardSourceBase{
				Destination:     "/templates/grafana/dashboards-1.14",
				MinKubernetes:   "1.14.0-0",
				Type:            types.DashboardJsonnetMixin,
				MulticlusterKey: ".Values.grafana.sidecar.dashboards.multicluster.global.enabled",
			},
			MixinVars: map[string]interface{}{},
		},
		&types.DashboardGitSource{
			Repository: config.Repos["etcd"],
			Source:     "mixin.libsonnet",
			Cwd:        "contrib/mixin",
			DashboardSourceBase: types.DashboardSourceBase{
				Destination:     "/templates/grafana/dashboards-1.14",
				MinKubernetes:   "1.14.0-0",
				Type:            types.DashboardJsonnetMixin,
				MulticlusterKey: "(or .Values.grafana.sidecar.dashboards.multicluster.global.enabled .Values.grafana.sidecar.dashboards.multicluster.etcd.enabled)",
			},
			MixinVars: map[string]interface{}{
				"_config+": map[string]interface{}{},
			},
		},
	}
}

var DashboardsConditionMap = map[string]string{
	"alertmanager-overview":           " (or .Values.alertmanager.enabled .Values.alertmanager.forceDeployDashboards)",
	"grafana-coredns-k8s":             " .Values.coreDns.enabled",
	"etcd":                            " .Values.kubeEtcd.enabled",
	"apiserver":                       " .Values.kubeApiServer.enabled",
	"controller-manager":              " .Values.kubeControllerManager.enabled",
	"kubelet":                         " .Values.kubelet.enabled",
	"proxy":                           " .Values.kubeProxy.enabled",
	"scheduler":                       " .Values.kubeScheduler.enabled",
	"node-rsrc-use":                   " (or .Values.nodeExporter.enabled .Values.nodeExporter.forceDeployDashboards)",
	"node-cluster-rsrc-use":           " (or .Values.nodeExporter.enabled .Values.nodeExporter.forceDeployDashboards)",
	"nodes":                           " (and (or .Values.nodeExporter.enabled .Values.nodeExporter.forceDeployDashboards) .Values.nodeExporter.operatingSystems.linux.enabled)",
	"nodes-aix":                       " (and (or .Values.nodeExporter.enabled .Values.nodeExporter.forceDeployDashboards) .Values.nodeExporter.operatingSystems.aix.enabled)",
	"nodes-darwin":                    " (and (or .Values.nodeExporter.enabled .Values.nodeExporter.forceDeployDashboards) .Values.nodeExporter.operatingSystems.darwin.enabled)",
	"prometheus-remote-write":         " .Values.prometheus.prometheusSpec.remoteWriteDashboards",
	"k8s-coredns":                     " .Values.coreDns.enabled",
	"k8s-windows-cluster-rsrc-use":    " .Values.windowsMonitoring.enabled",
	"k8s-windows-node-rsrc-use":       " .Values.windowsMonitoring.enabled",
	"k8s-resources-windows-cluster":   " .Values.windowsMonitoring.enabled",
	"k8s-resources-windows-namespace": " .Values.windowsMonitoring.enabled",
	"k8s-resources-windows-pod":       " .Values.windowsMonitoring.enabled",
}

const DashboardHeader = `{{- /*
Generated from '%(.Name)s' from %(.URL)s%(.ByLine)s
Do not change in-place! In order to change this file first read following link:
https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack/hack
*/ -}}
{{- $kubeTargetVersion := default .Capabilities.KubeVersion.GitVersion .Values.kubeTargetVersionOverride }}
{{- if and (or .Values.grafana.enabled .Values.grafana.forceDeployDashboards) (semverCompare ">=%(.MinKubeVersion)s" $kubeTargetVersion) (semverCompare "<%(.MaxKubeVersion)s" $kubeTargetVersion) .Values.grafana.defaultDashboardsEnabled%(.Condition)s }}
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: {{ template "kube-prometheus-stack-grafana.namespace" . }}
  name: {{ printf "%s-%s" (include "kube-prometheus-stack.fullname" $) "%(.Name)s" | trunc 63 | trimSuffix "-" }}
  annotations:
{{ toYaml .Values.grafana.sidecar.dashboards.annotations | indent 4 }}
  labels:
    {{- if $.Values.grafana.sidecar.dashboards.label }}
    {{ $.Values.grafana.sidecar.dashboards.label }}: {{ ternary $.Values.grafana.sidecar.dashboards.labelValue "1" (not (empty $.Values.grafana.sidecar.dashboards.labelValue)) | quote }}
    {{- end }}
    app: {{ template "kube-prometheus-stack.name" $ }}-grafana
{{ include "kube-prometheus-stack.labels" $ | indent 4 }}
data:
`

func NewDashboardHeader(headerData types.HeaderData) (string, error) {
	if config.GetContext().DebugMode {
		headerData.ByLine = ` with debug mode enabled`
	}

	templateRenderer := pythonish.NewRenderer()
	tmpl, err := templateRenderer.Parse(DashboardHeader)
	if err != nil {
		return "ERROR", err
	}

	var buffer bytes.Buffer
	err = tmpl.Execute(&buffer, headerData)
	return buffer.String(), err
}

const GrafanaDashboardOperator = `
---
{{- if and .Values.grafana.operator.dashboardsConfigMapRefEnabled (or .Values.grafana.enabled .Values.grafana.forceDeployDashboards) (semverCompare ">=%(.MinKubeVersion)s" $kubeTargetVersion) (semverCompare "<%(.MaxKubeVersion)s" $kubeTargetVersion) .Values.grafana.defaultDashboardsEnabled%(.Condition)s }}
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: {{ printf "%s-%s" (include "kube-prometheus-stack.fullname" $) "%(.Name)s" | trunc 63 | trimSuffix "-" }}
  namespace: {{ template "kube-prometheus-stack-grafana.namespace" . }}
  {{ with .Values.grafana.operator.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{ end }}
  labels:
    app: {{ template "kube-prometheus-stack.name" $ }}-grafana
spec:
  allowCrossNamespaceImport: true
  resyncPeriod: {{ .Values.grafana.operator.resyncPeriod | quote | default "10m" }}
  folder: {{ .Values.grafana.operator.folder | quote }}
  instanceSelector:
    matchLabels:
    {{- if .Values.grafana.operator.matchLabels }}
      {{- toYaml .Values.grafana.operator.matchLabels | nindent 6 }}
    {{- else }}
      {{- fail "grafana.operator.matchLabels must be specified when grafana.operator.dashboardsConfigMapRefEnabled is true" }}
    {{- end }}
  configMapRef:
    name: {{ printf "%s-%s" (include "kube-prometheus-stack.fullname" $) "%(.Name)s" | trunc 63 | trimSuffix "-" }}
    key: %(.Name)s.json
{{- end }}
`

func NewGrafanaOperator(headerData types.HeaderData) (string, error) {
	if config.GetContext().DebugMode {
		headerData.ByLine = ` with debug mode enabled`
	}

	templateRenderer := pythonish.NewRenderer()
	tmpl, err := templateRenderer.Parse(GrafanaDashboardOperator)
	if err != nil {
		return "ERROR", err
	}

	var buffer bytes.Buffer
	err = tmpl.Execute(&buffer, headerData)
	return buffer.String(), err
}
