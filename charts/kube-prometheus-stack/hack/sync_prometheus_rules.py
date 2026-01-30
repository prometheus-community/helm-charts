#!/usr/bin/env python3
"""Fetch alerting and aggregation rules from provided urls into this chart."""
import json
import os
import re
import shutil
import subprocess
import textwrap

import _jsonnet
import requests
import yaml
from yaml.representer import SafeRepresenter


# https://stackoverflow.com/a/20863889/961092
class LiteralStr(str):
    pass


def change_style(style, representer):
    def new_representer(dumper, data):
        scalar = representer(dumper, data)
        scalar.style = style
        return scalar

    return new_representer


refs = {
    # renovate: git-refs=https://github.com/prometheus-operator/kube-prometheus branch=main
    'ref.kube-prometheus': 'be3a410867333faf4de99cb9b2196c0e1a21b9cb',
    # renovate: git-refs=https://github.com/kubernetes-monitoring/kubernetes-mixin branch=master
    'ref.kubernetes-mixin': '21dfec71a73ae5da9bda98cdc1a734452316b9fe',
    # renovate: git-refs=https://github.com/etcd-io/etcd branch=main
    'ref.etcd': 'd89978e8e32196a3d7410690ebed1d94baf32dbe',
}

# Source files list
charts = [
    {
        'git': 'https://github.com/prometheus-operator/kube-prometheus.git',
        'branch': refs['ref.kube-prometheus'],
        'source': 'main.libsonnet',
        'cwd': '',
        'destination': '../templates/prometheus/rules-1.14',
        'min_kubernetes': '1.14.0-0',
        'mixin': """
        local kp =
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
        """
    },
    {
        'git': 'https://github.com/kubernetes-monitoring/kubernetes-mixin.git',
        'branch': refs['ref.kubernetes-mixin'],
        'source': 'windows.libsonnet',
        'cwd': 'rules',
        'destination': '../templates/prometheus/rules-1.14',
        'min_kubernetes': '1.14.0-0',
        'mixin': """
        local kp =
            { prometheusAlerts+:: {}, prometheusRules+:: {}} +
            (import "windows.libsonnet") +
            {'_config': {
                'clusterLabel': 'cluster',
                'windowsExporterSelector': 'job="windows-exporter"',
                'kubeStateMetricsSelector': 'job="kube-state-metrics"',
            }};

        kp.prometheusAlerts + kp.prometheusRules
        """
    },
    {
        'git': 'https://github.com/etcd-io/etcd.git',
        'branch': refs['ref.etcd'],
        'source': 'mixin.libsonnet',
        'cwd': 'contrib/mixin',
        'destination': '../templates/prometheus/rules-1.14',
        'min_kubernetes': '1.14.0-0',
        # Override the default etcd_instance_labels to get proper aggregation for etcd instances in k8s clusters (#2720)
        # see https://github.com/etcd-io/etcd/blob/1c22e7b36bc5d8543f1646212f2960f9fe503b8c/contrib/mixin/config.libsonnet#L13
        'mixin': """
        local kp =
            { prometheusAlerts+:: {}, prometheusRules+:: {}} +
            (import "mixin.libsonnet") +
            {'_config': {
                'etcd_selector': 'job=~".*etcd.*"',
                'etcd_instance_labels': 'instance, pod',
                'scrape_interval_seconds': 30,
                'clusterLabel': 'job',
            }};

        kp.prometheusAlerts + kp.prometheusRules
        """
    },
]

# Additional conditions map
condition_map = {
    'alertmanager.rules': ' .Values.defaultRules.rules.alertmanager',
    'config-reloaders': ' .Values.defaultRules.rules.configReloaders',
    'etcd': ' .Values.kubeEtcd.enabled .Values.defaultRules.rules.etcd',
    'general.rules': ' .Values.defaultRules.rules.general',
    'k8s.rules.container_cpu_limits': ' .Values.defaultRules.rules.k8sContainerCpuLimits',
    'k8s.rules.container_cpu_requests': ' .Values.defaultRules.rules.k8sContainerCpuRequests',
    'k8s.rules.container_cpu_usage_seconds_total': ' .Values.defaultRules.rules.k8sContainerCpuUsageSecondsTotal',
    'k8s.rules.container_memory_cache': ' .Values.defaultRules.rules.k8sContainerMemoryCache',
    'k8s.rules.container_memory_limits': ' .Values.defaultRules.rules.k8sContainerMemoryLimits',
    'k8s.rules.container_memory_requests': ' .Values.defaultRules.rules.k8sContainerMemoryRequests',
    'k8s.rules.container_memory_rss': ' .Values.defaultRules.rules.k8sContainerMemoryRss',
    'k8s.rules.container_memory_swap': ' .Values.defaultRules.rules.k8sContainerMemorySwap',
    'k8s.rules.container_memory_working_set_bytes': ' .Values.defaultRules.rules.k8sContainerMemoryWorkingSetBytes',
    'k8s.rules.container_resource': ' .Values.defaultRules.rules.k8sContainerResource',
    'k8s.rules.pod_owner': ' .Values.defaultRules.rules.k8sPodOwner',
    'kube-apiserver-availability.rules': ' .Values.kubeApiServer.enabled .Values.defaultRules.rules.kubeApiserverAvailability',
    'kube-apiserver-burnrate.rules': ' .Values.kubeApiServer.enabled .Values.defaultRules.rules.kubeApiserverBurnrate',
    'kube-apiserver-histogram.rules': ' .Values.kubeApiServer.enabled .Values.defaultRules.rules.kubeApiserverHistogram',
    'kube-apiserver-slos': ' .Values.kubeApiServer.enabled .Values.defaultRules.rules.kubeApiserverSlos',
    'kube-prometheus-general.rules': ' .Values.defaultRules.rules.kubePrometheusGeneral',
    'kube-prometheus-node-recording.rules': ' .Values.defaultRules.rules.kubePrometheusNodeRecording',
    'kube-scheduler.rules': ' .Values.kubeScheduler.enabled .Values.defaultRules.rules.kubeSchedulerRecording',
    'kube-state-metrics': ' .Values.defaultRules.rules.kubeStateMetrics',
    'kubelet.rules': ' .Values.kubelet.enabled .Values.defaultRules.rules.kubelet',
    'kubernetes-apps': ' .Values.defaultRules.rules.kubernetesApps',
    'kubernetes-resources': ' .Values.defaultRules.rules.kubernetesResources',
    'kubernetes-storage': ' .Values.defaultRules.rules.kubernetesStorage',
    'kubernetes-system': ' .Values.defaultRules.rules.kubernetesSystem',
    'kubernetes-system-kube-proxy': ' .Values.kubeProxy.enabled .Values.defaultRules.rules.kubeProxy',
    'kubernetes-system-apiserver': ' .Values.defaultRules.rules.kubernetesSystem', # kubernetes-system was split into more groups in 1.14, one of them is kubernetes-system-apiserver
    'kubernetes-system-kubelet': ' .Values.defaultRules.rules.kubernetesSystem', # kubernetes-system was split into more groups in 1.14, one of them is kubernetes-system-kubelet
    'kubernetes-system-controller-manager': ' .Values.kubeControllerManager.enabled .Values.defaultRules.rules.kubeControllerManager',
    'kubernetes-system-scheduler': ' .Values.kubeScheduler.enabled .Values.defaultRules.rules.kubeSchedulerAlerting',
    'node-exporter.rules': ' .Values.defaultRules.rules.nodeExporterRecording',
    'node-exporter': ' .Values.defaultRules.rules.nodeExporterAlerting',
    'node.rules': ' .Values.defaultRules.rules.node',
    'node-network': ' .Values.defaultRules.rules.network',
    'prometheus-operator': ' .Values.defaultRules.rules.prometheusOperator',
    'prometheus': ' .Values.defaultRules.rules.prometheus', # kube-prometheus >= 1.14 uses prometheus as group instead of prometheus.rules
    'windows.node.rules': ' .Values.windowsMonitoring.enabled .Values.defaultRules.rules.windows',
    'windows.pod.rules': ' .Values.windowsMonitoring.enabled .Values.defaultRules.rules.windows',
}

alert_condition_map = {
    'AggregatedAPIDown': 'semverCompare ">=1.18.0-0" $kubeTargetVersion',
    'AlertmanagerDown': '.Values.alertmanager.enabled',
    'CoreDNSDown': '.Values.kubeDns.enabled',
    'KubeAPIDown': '.Values.kubeApiServer.enabled',  # there are more alerts which are left enabled, because they'll never fire without metrics
    'KubeControllerManagerDown': '.Values.kubeControllerManager.enabled',
    'KubeletDown': '.Values.prometheusOperator.kubeletService.enabled',  # there are more alerts which are left enabled, because they'll never fire without metrics
    'KubeSchedulerDown': '.Values.kubeScheduler.enabled',
    'KubeStateMetricsDown': '.Values.kubeStateMetrics.enabled',  # there are more alerts which are left enabled, because they'll never fire without metrics
    'NodeExporterDown': '.Values.nodeExporter.enabled',
    'PrometheusOperatorDown': '.Values.prometheusOperator.enabled',
}

replacement_map = {
    'job="prometheus-operator"': {
        'replacement': 'job="{{ $operatorJob }}"',
        'init': '{{- $operatorJob := printf "%s-%s" (include "kube-prometheus-stack.fullname" .) "operator" }}'},
    'job="prometheus-k8s"': {
        'replacement': 'job="{{ $prometheusJob }}"',
        'init': '{{- $prometheusJob := printf "%s-%s" (include "kube-prometheus-stack.fullname" .) "prometheus" }}'},
    'job="alertmanager-main"': {
        'replacement': 'job="{{ $alertmanagerJob }}"',
        'init': '{{- $alertmanagerJob := printf "%s-%s" (include "kube-prometheus-stack.fullname" .) "alertmanager" }}'},
    'namespace="monitoring"': {
        'replacement': 'namespace="{{ $namespace }}"',
        'init': '{{- $namespace := printf "%s" (include "kube-prometheus-stack.namespace" .) }}'},
    'alertmanager-$1': {
        'replacement': '$1',
        'init': ''},
    'job="kube-state-metrics"': {
        'replacement': 'job="{{ $kubeStateMetricsJob }}"',
        'init': '{{- $kubeStateMetricsJob := include "kube-prometheus-stack-kube-state-metrics.name" . }}'},
    'job="{{ $kubeStateMetricsJob }}"': {
        'replacement': 'job="{{ $kubeStateMetricsJob }}", namespace{{ $namespaceOperator }}"{{ $targetNamespace }}"',
        'limitGroup': ['kubernetes-apps'],
        'init': '{{- $targetNamespace := .Values.defaultRules.appNamespacesTarget }}{{- $namespaceOperator := .Values.defaultRules.appNamespacesOperator | default "=~" }}'},
    'job="kubelet", metrics_path="/metrics': {
        'replacement': 'job="{{ $kubeletJob }}", namespace{{ $namespaceOperator }}"{{ $targetNamespace }}", metrics_path="/metrics',
        'limitGroup': ['kubernetes-storage'],
        'init': '{{- $kubeletJob := include "kube-prometheus-stack-kubelet.name" . }}\n{{- $targetNamespace := .Values.defaultRules.appNamespacesTarget }}\n{{- $namespaceOperator := .Values.defaultRules.appNamespacesOperator | default "=~" }}'},
    'job="kubelet"': {
        'replacement': 'job="{{ $kubeletJob }}"',
        'init': '{{- $kubeletJob := include "kube-prometheus-stack-kubelet.name" . }}'},
    'job="kube-controller-manager"': {
        'replacement': 'job="{{ $kubeControllerManagerJob }}"',
        'init': '{{- $kubeControllerManagerJob := include "kube-prometheus-stack-kube-controller-manager.name" . }}'},
    'job="kube-scheduler"': {
        'replacement': 'job="{{ $kubeSchedulerJob }}"',
        'init': '{{- $kubeSchedulerJob := include "kube-prometheus-stack-kube-scheduler.name" . }}'},
    'job="kube-proxy"': {
        'replacement': 'job="{{ $kubeProxyJob }}"',
        'init': '{{- $kubeProxyJob := include "kube-prometheus-stack-kube-proxy.name" . }}'},
    'runbook_url: https://runbooks.prometheus-operator.dev/runbooks/': {
        'replacement': 'runbook_url: {{ .Values.defaultRules.runbookUrl }}/',
        'init': ''},
    '(namespace,service)': {
        'replacement': '(namespace,service,cluster)',
        'init': ''},
    '(namespace, job, handler': {
        'replacement': '(cluster, namespace, job, handler',
        'init': ''},
    '$.Values.defaultRules.node.fsSelector': {
        'replacement': '{{ $.Values.defaultRules.node.fsSelector }}',
        'init': ''},
}

# standard header
header = '''{{- /*
Generated from '%(name)s' group from %(url)s
Do not change in-place! In order to change this file first read following link:
https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack/hack
*/ -}}
{{- $kubeTargetVersion := default .Capabilities.KubeVersion.GitVersion .Values.kubeTargetVersionOverride }}
{{- if and (semverCompare ">=%(min_kubernetes)s" $kubeTargetVersion) (semverCompare "<%(max_kubernetes)s" $kubeTargetVersion) .Values.defaultRules.create%(condition)s }}%(init_line)s
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: {{ printf "%%s-%%s" (include "kube-prometheus-stack.fullname" .) "%(name)s" | trunc 63 | trimSuffix "-" }}
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
  -'''


def init_yaml_styles():
    represent_literal_str = change_style('|', SafeRepresenter.represent_str)
    yaml.add_representer(LiteralStr, represent_literal_str)


def escape(s):
    return s.replace("{{", "{{`{{").replace("}}", "}}`}}").replace("{{`{{", "{{`{{`}}").replace("}}`}}", "{{`}}`}}")


def fix_expr(rules):
    """Remove trailing whitespaces and line breaks, which happen to creep in
     due to yaml import specifics;
     convert multiline expressions to literal style, |-"""
    for rule in rules:
        rule['expr'] = rule['expr'].rstrip()
        if '\n' in rule['expr']:
            rule['expr'] = LiteralStr(rule['expr'])


def yaml_str_repr(struct, indent=4):
    """represent yaml as a string"""
    text = yaml.dump(
        struct,
        width=1000,  # to disable line wrapping
        default_flow_style=False  # to disable multiple items on single line
    )
    text = escape(text)  # escape {{ and }} for helm
    text = textwrap.indent(text, ' ' * indent)[indent - 1:]  # indent everything, and remove very first line extra indentation
    return text


def get_rule_group_condition(group_name, value_key):
    if group_name == '':
        return ''

    if group_name.count(".Values") > 1:
        group_name = group_name.split(' ')[-1]

    return group_name.replace('Values.defaultRules.rules', f"Values.defaultRules.{value_key}").strip()


def add_rules_conditions(rules, rules_map, indent=4):
    """Add if wrapper for rules, listed in rules_map"""
    rule_condition = '{{- if %s }}\n'
    for alert_name in rules_map:
        line_start = ' ' * indent + '- alert: '
        if line_start + alert_name in rules:
            rule_text = rule_condition % rules_map[alert_name]
            start = 0
            # to modify all alerts with same name
            while True:
                try:
                    # add if condition
                    index = rules.index(line_start + alert_name, start)
                    start = index + len(rule_text) + 1
                    rules = rules[:index] + rule_text + rules[index:]
                    # add end of if
                    try:
                        next_index = rules.index(line_start, index + len(rule_text) + 1)
                    except ValueError:
                        # we found the last alert in file if there are no alerts after it
                        next_index = len(rules)

                    # depending on the rule ordering in rules_map it's possible that an if statement from another rule is present at the end of this block.
                    found_block_end = False
                    last_line_index = next_index
                    while not found_block_end:
                        last_line_index = rules.rindex('\n', index, last_line_index - 1)  # find the starting position of the last line
                        last_line = rules[last_line_index + 1:next_index]

                        if last_line.startswith('{{- if'):
                            next_index = last_line_index + 1  # move next_index back if the current block ends in an if statement
                            continue

                        found_block_end = True
                    rules = rules[:next_index] + '{{- end }}\n' + rules[next_index:]
                except ValueError:
                    break
    return rules


def add_rules_conditions_from_condition_map(rules, indent=4):
    """Add if wrapper for rules, listed in alert_condition_map"""
    rules = add_rules_conditions(rules, alert_condition_map, indent)
    return rules


def add_rules_per_rule_conditions(rules, group, indent=4):
    """Add if wrapper for rules, listed in alert_condition_map"""
    rules_condition_map = {}
    for rule in group['rules']:
        if 'alert' in rule:
            rules_condition_map[rule['alert']] = f"not (.Values.defaultRules.disabled.{rule['alert']} | default false)"

    rules = add_rules_conditions(rules, rules_condition_map, indent)
    return rules


def add_custom_labels(rules_str, group, indent=4, label_indent=2):
    """Add if wrapper for additional rules labels"""
    rule_group_labels = get_rule_group_condition(condition_map.get(group['name'], ''), 'additionalRuleGroupLabels')

    additional_rule_labels = textwrap.indent("""
{{- with .Values.defaultRules.additionalRuleLabels }}
  {{- toYaml . | nindent 8 }}
{{- end }}
{{- with %s }}
  {{- toYaml . | nindent 8 }}
{{- end }}""" % (rule_group_labels,), " " * (indent + label_indent * 2))

    additional_rule_labels_condition_start = "\n" + " " * (indent + label_indent) + '{{- if or .Values.defaultRules.additionalRuleLabels %s }}' % (rule_group_labels,)
    additional_rule_labels_condition_end = "\n" + " " * (indent + label_indent) + '{{- end }}'
    # labels: cannot be null, if a rule does not have any labels by default, the labels block
    # should only be added if there are .Values defaultRules.additionalRuleLabels defined
    rule_seperator = "\n" + " " * indent + "-.*"
    label_seperator = "\n" + " " * indent + "  labels:"
    section_seperator = "\n" + " " * indent + "  \\S"
    section_seperator_len = len(section_seperator)-1
    rules_positions = re.finditer(rule_seperator,rules_str)

    # fetch breakpoint between each set of rules
    ruleStartingLine = [(rule_position.start(),rule_position.end()) for rule_position in rules_positions]
    head = rules_str[:ruleStartingLine[0][0]]

    # construct array of rules so they can be handled individually
    rules = []
    # pylint: disable=E1136
    # See https://github.com/pylint-dev/pylint/issues/1498 for None Values
    previousRule = None
    for r in ruleStartingLine:
         if previousRule != None:
             rules.append(rules_str[previousRule[0]:r[0]])
         previousRule = r
    rules.append(rules_str[previousRule[0]:len(rules_str)-1])

    for i, rule in enumerate(rules):
        current_label = re.search(label_seperator,rule)
        if current_label:
            # `labels:` block exists
            # determine if there are any existing entries
            entries = re.search(section_seperator,rule[current_label.end():])
            if entries:
                entries_start = current_label.end()
                entries_end = entries.end()+current_label.end()-section_seperator_len
                rules[i] = rule[:entries_end] + additional_rule_labels_condition_start + additional_rule_labels + additional_rule_labels_condition_end + rule[entries_end:]
            else:
                # `labels:` does not contain any entries
                # append template to label section
                rules[i] += additional_rule_labels_condition_start + additional_rule_labels + additional_rule_labels_condition_end
        else:
            # `labels:` block does not exist
            # create it and append template
            rules[i] += additional_rule_labels_condition_start + "\n" + " " * indent + "  labels:" + additional_rule_labels + additional_rule_labels_condition_end
    return head + "".join(rules) + "\n"


def add_custom_annotations(rules, group, indent=4):
    """Add if wrapper for additional rules annotations"""
    rule_condition = '{{- if .Values.defaultRules.additionalRuleAnnotations }}\n{{ toYaml .Values.defaultRules.additionalRuleAnnotations | indent 8 }}\n{{- end }}'
    rule_group_labels = get_rule_group_condition(condition_map.get(group['name'], ''), 'additionalRuleGroupAnnotations')
    rule_group_condition = '\n{{- if %s }}\n{{ toYaml %s | indent 8 }}\n{{- end }}' % (rule_group_labels, rule_group_labels)
    annotations = "      annotations:"
    annotations_len = len(annotations) + 1
    rule_condition_len = len(rule_condition) + 1
    rule_group_condition_len = len(rule_group_condition)

    separator = " " * indent + "- alert:.*"
    alerts_positions = re.finditer(separator,rules)
    alert = 0

    for alert_position in alerts_positions:
        # Add rule_condition after 'annotations:' statement
        index = alert_position.end() + annotations_len + (rule_condition_len + rule_group_condition_len) * alert
        rules = rules[:index] + "\n" + rule_condition + rule_group_condition +  rules[index:]
        alert += 1

    return rules


def add_custom_keep_firing_for(rules, indent=4):
    """Add if wrapper for additional rules annotations"""
    indent_spaces = " " * indent + "  "
    keep_firing_for = (indent_spaces + '{{- with .Values.defaultRules.keepFiringFor }}\n' +
                        indent_spaces + 'keep_firing_for: "{{ . }}"\n' +
                        indent_spaces + '{{- end }}')
    keep_firing_for_len = len(keep_firing_for) + 1

    separator = " " * indent + "  for:.*"
    alerts_positions = re.finditer(separator, rules)
    alert = 0

    for alert_position in alerts_positions:
        # Add rule_condition after 'annotations:' statement
        index = alert_position.end() + keep_firing_for_len * alert
        rules = rules[:index] + "\n" + keep_firing_for + rules[index:]
        alert += 1

    return rules


def add_custom_for(rules, indent=4):
    """Add custom 'for:' condition in rules"""
    replace_field = "for:"
    rules = add_custom_alert_rules(rules, replace_field, indent)

    return rules


def add_custom_severity(rules, indent=4):
    """Add custom 'severity:' condition in rules"""
    replace_field = "severity:"
    rules = add_custom_alert_rules(rules, replace_field, indent)

    return rules


def add_custom_alert_rules(rules, key_to_replace, indent):
    """Extend alert field to allow custom values"""
    key_to_replace_indented = ' ' * indent + key_to_replace
    alertkey_field = '- alert:'
    found_alert_key = False
    alertname = None
    updated_rules = ''

    # pylint: disable=C0200
    i = 0
    while i < len(rules):
        if rules[i:i + len(alertkey_field)] == alertkey_field:
            found_alert_key = True
            start_index_word_after = i + len(alertkey_field) + 1
            end_index_alertkey_field = start_index_word_after
            while end_index_alertkey_field < len(rules) and rules[end_index_alertkey_field].isalnum():
                end_index_alertkey_field += 1

            alertname = rules[start_index_word_after:end_index_alertkey_field]

        if found_alert_key:
            if rules[i:i + len(key_to_replace_indented)] == key_to_replace_indented:
                found_alert_key = False
                start_index_key_value = i + len(key_to_replace_indented) + 1
                end_index_key_to_replace = start_index_key_value
                while end_index_key_to_replace < len(rules) and rules[end_index_key_to_replace].isalnum():
                    end_index_key_to_replace += 1

                word_after_key_to_replace = rules[start_index_key_value:end_index_key_to_replace]
                new_key = key_to_replace_indented + ' {{ dig "' + alertname + \
                    '" "' + key_to_replace[:-1] + '" "' + \
                    word_after_key_to_replace + '" .Values.customRules }}'
                updated_rules += new_key
                i = end_index_key_to_replace

        updated_rules += rules[i]
        i += 1

    return updated_rules


def write_group_to_file(group, url, destination, min_kubernetes, max_kubernetes):
    fix_expr(group['rules'])
    group_name = group['name']

    # prepare rules string representation
    rules = yaml_str_repr(group)
    # add replacements of custom variables and include their initialisation in case it's needed
    init_line = ''
    for line in replacement_map:
        if group_name in replacement_map[line].get('limitGroup', [group_name]) and line in rules:
            rules = rules.replace(line, replacement_map[line]['replacement'])
            if replacement_map[line]['init']:
                init_line += '\n' + replacement_map[line]['init']
    # append per-alert rules
    rules = add_custom_labels(rules, group)
    rules = add_custom_annotations(rules, group)
    rules = add_custom_keep_firing_for(rules)
    rules = add_custom_for(rules)
    rules = add_custom_severity(rules)
    rules = add_rules_conditions_from_condition_map(rules)
    rules = add_rules_per_rule_conditions(rules, group)
    # initialize header
    lines = header % {
        'name': sanitize_name(group['name']),
        'url': url,
        'condition': condition_map.get(group['name'], ''),
        'init_line': init_line,
        'min_kubernetes': min_kubernetes,
        'max_kubernetes': max_kubernetes
    }

    # rules themselves
    lines += re.sub(
        r'\s(by|on) ?\(',
        r' \1 ({{ range $.Values.defaultRules.additionalAggregationLabels }}{{ . }},{{ end }}',
        rules,
        flags=re.IGNORECASE
    )

    # footer
    lines += '{{- end }}'

    filename = group['name'] + '.yaml'
    new_filename = "%s/%s" % (destination, filename)

    # make sure directories to store the file exist
    os.makedirs(destination, exist_ok=True)

    # recreate the file
    with open(new_filename, 'w') as f:
        f.write(lines)

    print("Generated %s" % new_filename)

def write_rules_names_template():
    with open('../templates/prometheus/_rules.tpl', 'w') as f:
        f.write('''{{- /*
Generated file. Do not change in-place! In order to change this file first read following link:
https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack/hack
*/ -}}\n''')
        f.write('{{- define "rules.names" }}\n')
        f.write('rules:\n')
        for rule in condition_map:
            f.write('  - "%s"\n' % sanitize_name(rule))
        f.write('{{- end }}')

def main():
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    init_yaml_styles()
    # read the rules, create a new template file per group
    for chart in charts:
        if 'git' in chart:
            if 'source' not in chart:
                chart['source'] = '_mixin.jsonnet'

            url = chart['git']

            print("Clone %s" % chart['git'])
            checkout_dir = os.path.basename(chart['git'])
            shutil.rmtree(checkout_dir, ignore_errors=True)

            branch = "main"
            if 'branch' in chart:
                branch = chart['branch']

            subprocess.run(["git", "init", "--initial-branch", "main", checkout_dir, "--quiet"])
            subprocess.run(["git", "-C", checkout_dir, "remote", "add", "origin", chart['git']])
            subprocess.run(["git", "-C", checkout_dir, "fetch", "--depth", "1", "origin", branch, "--quiet"])
            subprocess.run(["git", "-c", "advice.detachedHead=false", "-C", checkout_dir, "checkout", "FETCH_HEAD", "--quiet"])

            if chart.get('mixin'):
                cwd = os.getcwd()

                source_cwd = chart['cwd']
                mixin_file = chart['source']

                mixin_dir = cwd + '/' + checkout_dir + '/' + source_cwd + '/'
                if os.path.exists(mixin_dir + "jsonnetfile.json"):
                    print("Running jsonnet-bundler, because jsonnetfile.json exists")
                    subprocess.run(["jb", "install"], cwd=mixin_dir)

                if 'content' in chart:
                    f = open(mixin_dir + mixin_file, "w")
                    f.write(chart['content'])
                    f.close()

                print("Generating rules from %s" % mixin_file)
                print("Change cwd to %s" % checkout_dir + '/' + source_cwd)
                os.chdir(mixin_dir)

                alerts = json.loads(_jsonnet.evaluate_snippet(mixin_file, chart['mixin'], import_callback=jsonnet_import_callback))

                os.chdir(cwd)
            else:
                with open(checkout_dir + '/' + chart['source'], "r") as f:
                    raw_text = f.read()

                alerts = yaml.full_load(raw_text)

        else:
            url = chart['source']
            print("Generating rules from %s" % url)
            response = requests.get(url)
            if response.status_code != 200:
                print('Skipping the file, response code %s not equals 200' % response.status_code)
                continue
            raw_text = response.text
            if chart.get('mixin'):
                alerts = json.loads(_jsonnet.evaluate_snippet(url, raw_text + '.prometheusAlerts'))
            else:
                alerts = yaml.full_load(raw_text)

        if ('max_kubernetes' not in chart):
            chart['max_kubernetes']="9.9.9-9"

        # etcd workaround, their file don't have spec level
        groups = alerts['spec']['groups'] if alerts.get('spec') else alerts['groups']
        for group in groups:
            write_group_to_file(group, url, chart['destination'], chart['min_kubernetes'], chart['max_kubernetes'])

    # write rules.names named template
    write_rules_names_template()

    print("Finished")


def sanitize_name(name):
    return re.sub('[_]', '-', name).lower()


def jsonnet_import_callback(base, rel):
    # rel_base is the path relative to the current cwd.
    # see https://github.com/prometheus-community/helm-charts/issues/5283
    # for more details.
    rel_base = base
    if rel_base.startswith(os.getcwd()):
        rel_base = base[len(os.getcwd()):]

    if "github.com" in rel:
        base = os.getcwd() + '/vendor/'
    elif "github.com" in rel_base:
        base = os.getcwd() + '/vendor/' + rel_base[rel_base.find('github.com'):]

    if os.path.isfile(base + rel):
        return base + rel, open(base + rel).read().encode('utf-8')

    raise RuntimeError('File not found')


if __name__ == '__main__':
    main()
