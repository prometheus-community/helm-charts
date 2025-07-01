package consts

import (
	"bytes"
	"main/internal/config"
	"main/internal/pythonish"
	"main/internal/types"
)

func RulesSourceCharts() types.RulesConfigs {
	return types.RulesConfigs{
		&types.RulesGitSource{
			Repository:    config.Repos["kube-prometheus"],
			Source:        "main.libsonnet",
			Cwd:           "",
			Destination:   "/templates/prometheus/rules-1.14",
			MinKubernetes: "1.14.0-0",
			Mixin: `local kp =
(import 'jsonnet/kube-prometheus/main.libsonnet') + {
values+:: {
  nodeExporter+: {
	mixin+: {
	  _config+: {
		fsSelector: '$.Values.defaultRules.node.fsSelector',
	  },
	},
  },
  common+: {
	namespace: 'monitoring',
  },
  kubernetesControlPlane+: {
	kubeProxy: true,
  },
},
grafana: {},
};

{
groups: std.flattenArrays([
kp[component][resource].spec.groups
for component in std.objectFields(kp)
for resource in std.filter(
  function(resource)
	kp[component][resource].kind == 'PrometheusRule',
  std.objectFields(kp[component])
)
]),
}
`,
		},
		&types.RulesGitSource{
			Repository:    config.Repos["kubernetes-mixin"],
			Source:        "windows.libsonnet",
			Cwd:           "rules",
			Destination:   "/templates/prometheus/rules-1.14",
			MinKubernetes: "1.14.0-0",
			Mixin: `local kp =
	{ prometheusAlerts+:: {}, prometheusRules+:: {}} +
	(import "windows.libsonnet") +
	{'_config': {
		'clusterLabel': 'cluster',
		'windowsExporterSelector': 'job="windows-exporter"',
		'kubeStateMetricsSelector': 'job="kube-state-metrics"',
	}};

kp.prometheusAlerts + kp.prometheusRules`,
		},
		&types.RulesGitSource{
			Repository:    config.Repos["etcd"],
			Source:        "mixin.libsonnet",
			Cwd:           "contrib/mixin",
			Destination:   "/templates/prometheus/rules-1.14",
			MinKubernetes: "1.14.0-0",
			// Override the default etcd_instance_labels to get proper aggregation for etcd instances in k8s clusters (#2720)
			// see https://github.com/etcd-io/etcd/blob/1c22e7b36bc5d8543f1646212f2960f9fe503b8c/contrib/mixin/config.libsonnet#L13
			Mixin: `local kp =
	{ prometheusAlerts+:: {}, prometheusRules+:: {}} +
	(import "mixin.libsonnet") +
	{'_config': {
		'etcd_selector': 'job=~".*etcd.*"',
		'etcd_instance_labels': 'instance, pod',
		'scrape_interval_seconds': 30,
		'clusterLabel': 'job',
	}};

kp.prometheusAlerts + kp.prometheusRules`,
		},
	}
}

var RulesConditionMap = map[string]string{
	"alertmanager.rules":                           " .Values.defaultRules.rules.alertmanager",
	"config-reloaders":                             " .Values.defaultRules.rules.configReloaders",
	"etcd":                                         " .Values.kubeEtcd.enabled .Values.defaultRules.rules.etcd",
	"general.rules":                                " .Values.defaultRules.rules.general",
	"k8s.rules.container_cpu_limits":               " .Values.defaultRules.rules.k8sContainerCpuLimits",
	"k8s.rules.container_cpu_requests":             " .Values.defaultRules.rules.k8sContainerCpuRequests",
	"k8s.rules.container_cpu_usage_seconds_total":  " .Values.defaultRules.rules.k8sContainerCpuUsageSecondsTotal",
	"k8s.rules.container_memory_cache":             " .Values.defaultRules.rules.k8sContainerMemoryCache",
	"k8s.rules.container_memory_limits":            " .Values.defaultRules.rules.k8sContainerMemoryLimits",
	"k8s.rules.container_memory_requests":          " .Values.defaultRules.rules.k8sContainerMemoryRequests",
	"k8s.rules.container_memory_rss":               " .Values.defaultRules.rules.k8sContainerMemoryRss",
	"k8s.rules.container_memory_swap":              " .Values.defaultRules.rules.k8sContainerMemorySwap",
	"k8s.rules.container_memory_working_set_bytes": " .Values.defaultRules.rules.k8sContainerMemoryWorkingSetBytes",
	"k8s.rules.container_resource":                 " .Values.defaultRules.rules.k8sContainerResource",
	"k8s.rules.pod_owner":                          " .Values.defaultRules.rules.k8sPodOwner",
	"kube-apiserver-availability.rules":            " .Values.kubeApiServer.enabled .Values.defaultRules.rules.kubeApiserverAvailability",
	"kube-apiserver-burnrate.rules":                " .Values.kubeApiServer.enabled .Values.defaultRules.rules.kubeApiserverBurnrate",
	"kube-apiserver-histogram.rules":               " .Values.kubeApiServer.enabled .Values.defaultRules.rules.kubeApiserverHistogram",
	"kube-apiserver-slos":                          " .Values.kubeApiServer.enabled .Values.defaultRules.rules.kubeApiserverSlos",
	"kube-prometheus-general.rules":                " .Values.defaultRules.rules.kubePrometheusGeneral",
	"kube-prometheus-node-recording.rules":         " .Values.defaultRules.rules.kubePrometheusNodeRecording",
	"kube-scheduler.rules":                         " .Values.kubeScheduler.enabled .Values.defaultRules.rules.kubeSchedulerRecording",
	"kube-state-metrics":                           " .Values.defaultRules.rules.kubeStateMetrics",
	"kubelet.rules":                                " .Values.kubelet.enabled .Values.defaultRules.rules.kubelet",
	"kubernetes-apps":                              " .Values.defaultRules.rules.kubernetesApps",
	"kubernetes-resources":                         " .Values.defaultRules.rules.kubernetesResources",
	"kubernetes-storage":                           " .Values.defaultRules.rules.kubernetesStorage",
	"kubernetes-system":                            " .Values.defaultRules.rules.kubernetesSystem",
	"kubernetes-system-kube-proxy":                 " .Values.kubeProxy.enabled .Values.defaultRules.rules.kubeProxy",
	"kubernetes-system-apiserver":                  " .Values.defaultRules.rules.kubernetesSystem",
	"kubernetes-system-kubelet":                    " .Values.defaultRules.rules.kubernetesSystem",
	"kubernetes-system-controller-manager":         " .Values.kubeControllerManager.enabled .Values.defaultRules.rules.kubeControllerManager",
	"kubernetes-system-scheduler":                  " .Values.kubeScheduler.enabled .Values.defaultRules.rules.kubeSchedulerAlerting",
	"node-exporter.rules":                          " .Values.defaultRules.rules.nodeExporterRecording",
	"node-exporter":                                " .Values.defaultRules.rules.nodeExporterAlerting",
	"node.rules":                                   " .Values.defaultRules.rules.node",
	"node-network":                                 " .Values.defaultRules.rules.network",
	"prometheus-operator":                          " .Values.defaultRules.rules.prometheusOperator",
	"prometheus":                                   " .Values.defaultRules.rules.prometheus",
	"windows.node.rules":                           " .Values.windowsMonitoring.enabled .Values.defaultRules.rules.windows",
	"windows.pod.rules":                            " .Values.windowsMonitoring.enabled .Values.defaultRules.rules.windows",
}

var AlertConditionMap = map[string]string{
	"AggregatedAPIDown":         `semverCompare ">=1.18.0-0" $kubeTargetVersion`,
	"AlertmanagerDown":          ".Values.alertmanager.enabled",
	"CoreDNSDown":               ".Values.kubeDns.enabled",
	"KubeAPIDown":               ".Values.kubeApiServer.enabled",
	"KubeControllerManagerDown": ".Values.kubeControllerManager.enabled",
	"KubeletDown":               ".Values.prometheusOperator.kubeletService.enabled",
	"KubeSchedulerDown":         ".Values.kubeScheduler.enabled",
	"KubeStateMetricsDown":      ".Values.kubeStateMetrics.enabled",
	"NodeExporterDown":          ".Values.nodeExporter.enabled",
	"PrometheusOperatorDown":    ".Values.prometheusOperator.enabled",
}

const RuleHeader = `{{- /*
Generated from '%(.Name)s' group from %(.URL)s%(.ByLine)s
Do not change in-place! In order to change this file first read following link:
https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack/hack
*/ -}}
{{- $kubeTargetVersion := default .Capabilities.KubeVersion.GitVersion .Values.kubeTargetVersionOverride }}
{{- if and (semverCompare ">=%(.MinKubeVersion)s" $kubeTargetVersion) (semverCompare "<%(.MaxKubeVersion)s" $kubeTargetVersion) .Values.defaultRules.create%(.Condition)s }}%(.InitLine)s
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: {{ printf "%s-%s" (include "kube-prometheus-stack.fullname" .) "%(.Name)s" | trunc 63 | trimSuffix "-" }}
  namespace: {{ template "kube-prometheus-stack.namespace" . }}
  labels:
    app: {{ template "kube-prometheus-stack.name" . }}
{{ include "kube-prometheus-stack.labels" . | indent 4 }}
{{- if .Values.defaultRules.labels }}
{{ toYaml .Values.defaultRules.labels | indent 4 }}
{{- end }}
{{- if .Values.defaultRules.annotations }}
  annotations:
{{ toYaml .Values.defaultRules.annotations | indent 4 }}
{{- end }}
spec:
  groups:
`

func NewRuleHeader(headerData types.HeaderData) (string, error) {
	if config.GetContext().DebugMode {
		headerData.ByLine = ` with debug mode enabled`
	}

	templateRenderer := pythonish.NewRenderer()
	tmpl, err := templateRenderer.Parse(RuleHeader)
	if err != nil {
		return "ERROR", err
	}

	var buffer bytes.Buffer
	err = tmpl.Execute(&buffer, headerData)
	return buffer.String(), err
}

var ReplacementMap = []types.RuleReplacementRule{
	{
		Match:       `job="prometheus-operator"`,
		Replacement: `job="{{ $operatorJob }}"`,
		Init:        `{{- $operatorJob := printf "%s-%s" (include "kube-prometheus-stack.fullname" .) "operator" }}`,
	},
	{
		Match:       `job="prometheus-k8s"`,
		Replacement: `job="{{ $prometheusJob }}"`,
		Init:        `{{- $prometheusJob := printf "%s-%s" (include "kube-prometheus-stack.fullname" .) "prometheus" }}`,
	},
	{
		Match:       `job="alertmanager-main"`,
		Replacement: `job="{{ $alertmanagerJob }}"`,
		Init:        `{{- $alertmanagerJob := printf "%s-%s" (include "kube-prometheus-stack.fullname" .) "alertmanager" }}`,
	},
	{
		Match:       `namespace="monitoring"`,
		Replacement: `namespace="{{ $namespace }}"`,
		Init:        `{{- $namespace := printf "%s" (include "kube-prometheus-stack.namespace" .) }}`,
	},
	{
		Match:       `alertmanager-$1`,
		Replacement: `$1`,
		Init:        ``,
	},
	{
		Match:       `job="kube-state-metrics"`,
		Replacement: `job="{{ $kubeStateMetricsJob }}"`,
		Init:        `{{- $kubeStateMetricsJob := include "kube-prometheus-stack-kube-state-metrics.name" . }}`,
	},
	{
		Match:       `job="{{ $kubeStateMetricsJob }}"`,
		Replacement: `job="{{ $kubeStateMetricsJob }}", namespace{{ $namespaceOperator }}"{{ $targetNamespace }}"`,
		LimitGroup:  []string{"kubernetes-apps"},
		Init:        `{{- $targetNamespace := .Values.defaultRules.appNamespacesTarget }}{{- $namespaceOperator := .Values.defaultRules.appNamespacesOperator | default "=~" }}`,
	},
	{
		Match:       `job="kubelet"`,
		Replacement: `job="kubelet", namespace{{ $namespaceOperator }}"{{ $targetNamespace }}"`,
		LimitGroup:  []string{"kubernetes-storage"},
		Init:        `{{- $targetNamespace := .Values.defaultRules.appNamespacesTarget }}{{- $namespaceOperator := .Values.defaultRules.appNamespacesOperator | default "=~" }}`,
	},
	{
		Match:       `runbook_url: https://runbooks.prometheus-operator.dev/runbooks/`,
		Replacement: `runbook_url: {{ .Values.defaultRules.runbookUrl }}/`,
		Init:        ``,
	},
	{
		Match:       `(namespace,service)`,
		Replacement: `(namespace,service,cluster)`,
		Init:        ``,
	},
	{
		Match:       `(namespace, job, handler`,
		Replacement: `(cluster, namespace, job, handler`,
		Init:        ``,
	},
	{
		Match:       `$.Values.defaultRules.node.fsSelector`,
		Replacement: `{{ $.Values.defaultRules.node.fsSelector }}`,
		Init:        ``,
	},
}

const (
	Indent      = 4
	LabelIndent = 2
)
