#!/usr/bin/env python3
"""Fetch alerting and aggregation rules from provided urls into this chart."""
import json
import re
import textwrap
from os import makedirs

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


# Source files list
charts = [
    {
        'source': 'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/alertmanager-prometheusRule.yaml',
        'destination': '../templates/prometheus/rules-1.14',
        'min_kubernetes': '1.14.0-0'
    },
    {
        'source': 'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/kubePrometheus-prometheusRule.yaml',
        'destination': '../templates/prometheus/rules-1.14',
        'min_kubernetes': '1.14.0-0'
    },
    {
        'source': 'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/kubernetesControlPlane-prometheusRule.yaml',
        'destination': '../templates/prometheus/rules-1.14',
        'min_kubernetes': '1.14.0-0'
    },
    {
        'source': 'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/kubeStateMetrics-prometheusRule.yaml',
        'destination': '../templates/prometheus/rules-1.14',
        'min_kubernetes': '1.14.0-0'
    },
    {
        'source': 'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/nodeExporter-prometheusRule.yaml',
        'destination': '../templates/prometheus/rules-1.14',
        'min_kubernetes': '1.14.0-0'
    },
    {
        'source': 'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/prometheus-prometheusRule.yaml',
        'destination': '../templates/prometheus/rules-1.14',
        'min_kubernetes': '1.14.0-0'
    },
    {
        'source': 'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/prometheusOperator-prometheusRule.yaml',
        'destination': '../templates/prometheus/rules-1.14',
        'min_kubernetes': '1.14.0-0'
    },
    {
        'source': 'https://raw.githubusercontent.com/etcd-io/etcd/main/contrib/mixin/mixin.libsonnet',
        'destination': '../templates/prometheus/rules-1.14',
        'min_kubernetes': '1.14.0-0',
        'is_mixin': True
    },
]

# Additional conditions map
condition_map = {
    'alertmanager.rules': ' .Values.defaultRules.rules.alertmanager',
    'config-reloaders': ' .Values.defaultRules.rules.configReloaders',
    'etcd': ' .Values.kubeEtcd.enabled .Values.defaultRules.rules.etcd',
    'general.rules': ' .Values.defaultRules.rules.general',
    'k8s.rules': ' .Values.defaultRules.rules.k8s',
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
        'replacement': 'job="kube-state-metrics", namespace=~"{{ $targetNamespace }}"',
        'limitGroup': ['kubernetes-apps'],
        'init': '{{- $targetNamespace := .Values.defaultRules.appNamespacesTarget }}'},
    'job="kubelet"': {
        'replacement': 'job="kubelet", namespace=~"{{ $targetNamespace }}"',
        'limitGroup': ['kubernetes-storage'],
        'init': '{{- $targetNamespace := .Values.defaultRules.appNamespacesTarget }}'},
    'runbook_url: https://runbooks.prometheus-operator.dev/runbooks/': {
        'replacement': 'runbook_url: {{ .Values.defaultRules.runbookUrl }}/',
        'init': ''},
    '(controller,namespace)': {
        'replacement': '(controller,namespace,cluster)',
        'init': ''}
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


def add_custom_labels(rules, indent=4):
    """Add if wrapper for additional rules labels"""
    rule_condition = '{{- if .Values.defaultRules.additionalRuleLabels }}\n{{ toYaml .Values.defaultRules.additionalRuleLabels | indent 8 }}\n{{- end }}'
    rule_condition_len = len(rule_condition) + 1

    separator = " " * indent + "- alert:.*"
    alerts_positions = re.finditer(separator,rules)
    alert=-1
    for alert_position in alerts_positions:
        # add rule_condition at the end of the alert block
        if alert >= 0 :
            index = alert_position.start() + rule_condition_len * alert - 1
            rules = rules[:index] + "\n" + rule_condition + rules[index:]
        alert += 1

    # add rule_condition at the end of the last alert
    if alert >= 0:
        index = len(rules) - 1
        rules = rules[:index] + "\n" + rule_condition + rules[index:]
    return rules


def add_custom_annotations(rules, indent=4):
    """Add if wrapper for additional rules annotations"""
    rule_condition = '{{- if .Values.defaultRules.additionalRuleAnnotations }}\n{{ toYaml .Values.defaultRules.additionalRuleAnnotations | indent 8 }}\n{{- end }}'
    annotations = "      annotations:"
    annotations_len = len(annotations) + 1
    rule_condition_len = len(rule_condition) + 1

    separator = " " * indent + "- alert:.*"
    alerts_positions = re.finditer(separator,rules)
    alert = 0

    for alert_position in alerts_positions:
        # Add rule_condition after 'annotations:' statement
        index = alert_position.end() + annotations_len + rule_condition_len * alert
        rules = rules[:index] + "\n" + rule_condition + rules[index:]
        alert += 1

    return rules


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
    rules = add_custom_labels(rules)
    rules = add_custom_annotations(rules)
    rules = add_rules_conditions_from_condition_map(rules)
    rules = add_rules_per_rule_conditions(rules, group)
    # initialize header
    lines = header % {
        'name': group['name'],
        'url': url,
        'condition': condition_map.get(group['name'], ''),
        'init_line': init_line,
        'min_kubernetes': min_kubernetes,
        'max_kubernetes': max_kubernetes
    }

    # rules themselves
    lines += rules

    # footer
    lines += '{{- end }}'

    filename = group['name'] + '.yaml'
    new_filename = "%s/%s" % (destination, filename)

    # make sure directories to store the file exist
    makedirs(destination, exist_ok=True)

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
            f.write('  - "%s"\n' % rule)
        f.write('{{- end }}')

def main():
    init_yaml_styles()
    # read the rules, create a new template file per group
    for chart in charts:
        print("Generating rules from %s" % chart['source'])
        response = requests.get(chart['source'])
        if response.status_code != 200:
            print('Skipping the file, response code %s not equals 200' % response.status_code)
            continue
        raw_text = response.text
        if chart.get('is_mixin'):
            alerts = json.loads(_jsonnet.evaluate_snippet(chart['source'], raw_text + '.prometheusAlerts'))
        else:
            alerts = yaml.full_load(raw_text)

        if ('max_kubernetes' not in chart):
            chart['max_kubernetes']="9.9.9-9"

        # etcd workaround, their file don't have spec level
        groups = alerts['spec']['groups'] if alerts.get('spec') else alerts['groups']
        for group in groups:
            write_group_to_file(group, chart['source'], chart['destination'], chart['min_kubernetes'], chart['max_kubernetes'])

    # write rules.names named template
    write_rules_names_template()

    print("Finished")


if __name__ == '__main__':
    main()
