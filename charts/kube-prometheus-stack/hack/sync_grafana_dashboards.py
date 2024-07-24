#!/usr/bin/env python3
"""Fetch dashboards from provided urls into this chart."""
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
    # https://github.com/prometheus-operator/kube-prometheus
    'ref.kube-prometheus': 'b5b59bc0b45508b85647eb7a84b96dc167be15f1',
    # https://github.com/kubernetes-monitoring/kubernetes-mixin
    'ref.kubernetes-mixin': 'de834e9a291b49396125768f041e2078763f48b5',
    # https://github.com/etcd-io/etcd
    'ref.etcd': '1c22e7b36bc5d8543f1646212f2960f9fe503b8c',
}

# Source files list
charts = [
    {
        'source': '../files/dashboards/k8s-coredns.json',
        'destination': '../templates/grafana/dashboards-1.14',
        'type': 'dashboard_json',
        'min_kubernetes': '1.14.0-0',
        'multicluster_key': '.Values.grafana.sidecar.dashboards.multicluster.global.enabled',
    },
    {
        'source': 'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/%s/manifests/grafana-dashboardDefinitions.yaml' % (refs['ref.kube-prometheus'],),
        'destination': '../templates/grafana/dashboards-1.14',
        'type': 'yaml',
        'min_kubernetes': '1.14.0-0',
        'multicluster_key': '.Values.grafana.sidecar.dashboards.multicluster.global.enabled',
    },
    {
        'git': 'https://github.com/kubernetes-monitoring/kubernetes-mixin.git',
        'branch': refs['ref.kubernetes-mixin'],
        'content': "(import 'dashboards/windows.libsonnet') + (import 'config.libsonnet') + { _config+:: { windowsExporterSelector: 'job=\"windows-exporter\"', }}",
        'cwd': '.',
        'destination': '../templates/grafana/dashboards-1.14',
        'min_kubernetes': '1.14.0-0',
        'type': 'jsonnet_mixin',
        'mixin_vars': {},
        'multicluster_key': '.Values.grafana.sidecar.dashboards.multicluster.global.enabled',
    },
    {
        'git': 'https://github.com/etcd-io/etcd.git',
        'branch': refs['ref.etcd'],
        'source': 'mixin.libsonnet',
        'cwd': 'contrib/mixin',
        'destination': '../templates/grafana/dashboards-1.14',
        'min_kubernetes': '1.14.0-0',
        'type': 'jsonnet_mixin',
        'mixin_vars': {'_config+': {}},
        'multicluster_key': '(or .Values.grafana.sidecar.dashboards.multicluster.global.enabled .Values.grafana.sidecar.dashboards.multicluster.etcd.enabled)'
    },
]

# Additional conditions map
condition_map = {
    'grafana-coredns-k8s': ' .Values.coreDns.enabled',
    'etcd': ' .Values.kubeEtcd.enabled',
    'apiserver': ' .Values.kubeApiServer.enabled',
    'controller-manager': ' .Values.kubeControllerManager.enabled',
    'kubelet': ' .Values.kubelet.enabled',
    'proxy': ' .Values.kubeProxy.enabled',
    'scheduler': ' .Values.kubeScheduler.enabled',
    'node-rsrc-use': ' (or .Values.nodeExporter.enabled .Values.nodeExporter.forceDeployDashboards)',
    'node-cluster-rsrc-use': ' (or .Values.nodeExporter.enabled .Values.nodeExporter.forceDeployDashboards)',
    'nodes': ' (and (or .Values.nodeExporter.enabled .Values.nodeExporter.forceDeployDashboards) .Values.nodeExporter.operatingSystems.linux.enabled)',
    'nodes-darwin': ' (and (or .Values.nodeExporter.enabled .Values.nodeExporter.forceDeployDashboards) .Values.nodeExporter.operatingSystems.darwin.enabled)',
    'prometheus-remote-write': ' .Values.prometheus.prometheusSpec.remoteWriteDashboards',
    'k8s-coredns': ' .Values.coreDns.enabled',
    'k8s-windows-cluster-rsrc-use': ' .Values.windowsMonitoring.enabled',
    'k8s-windows-node-rsrc-use': ' .Values.windowsMonitoring.enabled',
    'k8s-resources-windows-cluster': ' .Values.windowsMonitoring.enabled',
    'k8s-resources-windows-namespace': ' .Values.windowsMonitoring.enabled',
    'k8s-resources-windows-pod': ' .Values.windowsMonitoring.enabled',
}

replacement_map = {
    'var-namespace=$__cell_1': {
        'replacement': 'var-namespace=`}}{{ if .Values.grafana.sidecar.dashboards.enableNewTablePanelSyntax }}${__data.fields.namespace}{{ else }}$__cell_1{{ end }}{{`',
    },
    'var-type=$__cell_2': {
        'replacement': 'var-type=`}}{{ if .Values.grafana.sidecar.dashboards.enableNewTablePanelSyntax }}${__data.fields.workload_type}{{ else }}$__cell_2{{ end }}{{`',
    },
    '=$__cell': {
        'replacement': '=`}}{{ if .Values.grafana.sidecar.dashboards.enableNewTablePanelSyntax }}${__value.text}{{ else }}$__cell{{ end }}{{`',
    },
    'job=\\"prometheus-k8s\\",namespace=\\"monitoring\\"': {
        'replacement': '',
    },
}

# standard header
header = '''{{- /*
Generated from '%(name)s' from %(url)s
Do not change in-place! In order to change this file first read following link:
https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack/hack
*/ -}}
{{- $kubeTargetVersion := default .Capabilities.KubeVersion.GitVersion .Values.kubeTargetVersionOverride }}
{{- if and (or .Values.grafana.enabled .Values.grafana.forceDeployDashboards) (semverCompare ">=%(min_kubernetes)s" $kubeTargetVersion) (semverCompare "<%(max_kubernetes)s" $kubeTargetVersion) .Values.grafana.defaultDashboardsEnabled%(condition)s }}
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: {{ template "kube-prometheus-stack-grafana.namespace" . }}
  name: {{ printf "%%s-%%s" (include "kube-prometheus-stack.fullname" $) "%(name)s" | trunc 63 | trimSuffix "-" }}
  annotations:
{{ toYaml .Values.grafana.sidecar.dashboards.annotations | indent 4 }}
  labels:
    {{- if $.Values.grafana.sidecar.dashboards.label }}
    {{ $.Values.grafana.sidecar.dashboards.label }}: {{ ternary $.Values.grafana.sidecar.dashboards.labelValue "1" (not (empty $.Values.grafana.sidecar.dashboards.labelValue)) | quote }}
    {{- end }}
    app: {{ template "kube-prometheus-stack.name" $ }}-grafana
{{ include "kube-prometheus-stack.labels" $ | indent 4 }}
data:
'''


def init_yaml_styles():
    represent_literal_str = change_style('|', SafeRepresenter.represent_str)
    yaml.add_representer(LiteralStr, represent_literal_str)


def yaml_str_repr(struct, indent=2):
    """represent yaml as a string"""
    text = yaml.dump(
        struct,
        width=1000,  # to disable line wrapping
        default_flow_style=False  # to disable multiple items on single line
    )
    text = textwrap.indent(text, ' ' * indent)
    return text


def replace_nested_key(data, key, value, replace):
    if isinstance(data, dict):
        return {
            k: replace if k == key and v == value else replace_nested_key(v, key, value, replace)
            for k, v in data.items()
        }
    elif isinstance(data, list):
        return [replace_nested_key(v, key, value, replace) for v in data]
    else:
        return data


def patch_dashboards_json(content, multicluster_key):
    try:
        content_struct = json.loads(content)

        # multicluster
        overwrite_list = []
        for variable in content_struct['templating']['list']:
            if variable['name'] == 'cluster':
                variable['allValue'] = '.*'
                variable['hide'] = ':multicluster:'
            overwrite_list.append(variable)
        content_struct['templating']['list'] = overwrite_list

        # Replace decimals=-1 with decimals= (nil value)
        # ref: https://github.com/kubernetes-monitoring/kubernetes-mixin/pull/859
        content_struct = replace_nested_key(content_struct, "decimals", -1, None)

        content = json.dumps(content_struct, separators=(',', ':'))
        content = content.replace('":multicluster:"', '`}}{{ if %s }}0{{ else }}2{{ end }}{{`' % multicluster_key,)

        for line in replacement_map:
            content = content.replace(line, replacement_map[line]['replacement'])
    except (ValueError, KeyError):
        pass

    return "{{`" + content + "`}}"


def patch_json_set_timezone_as_variable(content):
    # content is no more in json format, so we have to replace using regex
    return re.sub(r'"timezone"\s*:\s*"(?:\\.|[^\"])*"', '"timezone": "`}}{{ .Values.grafana.defaultDashboardsTimezone }}{{`"', content, flags=re.IGNORECASE)


def patch_json_set_editable_as_variable(content):
    # content is no more in json format, so we have to replace using regex
    return re.sub(r'"editable"\s*:\s*(?:true|false)', '"editable":`}}{{ .Values.grafana.defaultDashboardsEditable }}{{`', content, flags=re.IGNORECASE)


def jsonnet_import_callback(base, rel):
    if "github.com" in rel:
        base = os.getcwd() + '/vendor/'
    elif "github.com" in base:
        base = os.getcwd() + '/vendor/' + base[base.find('github.com'):]

    if os.path.isfile(base + rel):
        return base + rel, open(base + rel).read().encode('utf-8')

    raise RuntimeError('File not found')


def write_group_to_file(resource_name, content, url, destination, min_kubernetes, max_kubernetes, multicluster_key):
    # initialize header
    lines = header % {
        'name': resource_name,
        'url': url,
        'condition': condition_map.get(resource_name, ''),
        'min_kubernetes': min_kubernetes,
        'max_kubernetes': max_kubernetes
    }

    content = patch_dashboards_json(content, multicluster_key)
    content = patch_json_set_timezone_as_variable(content)
    content = patch_json_set_editable_as_variable(content)

    filename_struct = {resource_name + '.json': (LiteralStr(content))}
    # rules themselves
    lines += yaml_str_repr(filename_struct)

    # footer
    lines += '{{- end }}'

    filename = resource_name + '.yaml'
    new_filename = "%s/%s" % (destination, filename)

    # make sure directories to store the file exist
    os.makedirs(destination, exist_ok=True)

    # recreate the file
    with open(new_filename, 'w') as f:
        f.write(lines)

    print("Generated %s" % new_filename)


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
            print("Generating rules from %s" % chart['source'])

            mixin_file = chart['source']
            mixin_dir = checkout_dir + '/' + chart['cwd'] + '/'
            if os.path.exists(mixin_dir + "jsonnetfile.json"):
                print("Running jsonnet-bundler, because jsonnetfile.json exists")
                subprocess.run(["jb", "install"], cwd=mixin_dir)

            if 'content' in chart:
                f = open(mixin_dir + mixin_file, "w")
                f.write(chart['content'])
                f.close()

            mixin_vars = json.dumps(chart['mixin_vars'])

            cwd = os.getcwd()
            os.chdir(mixin_dir)
            raw_text = '((import "%s") + %s)' % (mixin_file, mixin_vars)
            source = os.path.basename(mixin_file)
        elif 'source' in chart and chart['source'].startswith('http'):
            print("Generating rules from %s" % chart['source'])
            response = requests.get(chart['source'])
            if response.status_code != 200:
                print('Skipping the file, response code %s not equals 200' % response.status_code)
                continue
            raw_text = response.text
            source = chart['source']
            url = chart['source']
        else:
            with open(chart['source']) as f:
                raw_text = f.read()

            source = chart['source']
            url = chart['source']

        if ('max_kubernetes' not in chart):
            chart['max_kubernetes']="9.9.9-9"

        if chart['type'] == 'yaml':
            yaml_text = yaml.full_load(raw_text)
            groups = yaml_text['items']
            for group in groups:
                for resource, content in group['data'].items():
                    write_group_to_file(resource.replace('.json', ''), content, url, chart['destination'], chart['min_kubernetes'], chart['max_kubernetes'], chart['multicluster_key'])
        elif chart['type'] == 'jsonnet_mixin':
            json_text = json.loads(_jsonnet.evaluate_snippet(source, raw_text + '.grafanaDashboards', import_callback=jsonnet_import_callback))

            if 'git' in chart:
                os.chdir(cwd)
            # is it already a dashboard structure or is it nested (etcd case)?
            flat_structure = bool(json_text.get('annotations'))
            if flat_structure:
                resource = os.path.basename(chart['source']).replace('.json', '')
                write_group_to_file(resource, json.dumps(json_text, indent=4), url, chart['destination'], chart['min_kubernetes'], chart['max_kubernetes'], chart['multicluster_key'])
            else:
                for resource, content in json_text.items():
                    write_group_to_file(resource.replace('.json', ''), json.dumps(content, indent=4), url, chart['destination'], chart['min_kubernetes'], chart['max_kubernetes'], chart['multicluster_key'])
        elif chart['type'] == 'dashboard_json':
            write_group_to_file(os.path.basename(source).replace('.json', ''),
                                raw_text, url, chart['destination'], chart['min_kubernetes'],
                                chart['max_kubernetes'], chart['multicluster_key'])


print("Finished")


if __name__ == '__main__':
    main()
