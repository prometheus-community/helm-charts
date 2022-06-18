#!/usr/bin/env python3
"""Fetch dashboards from provided urls into this chart."""
import json
import re
from os import makedirs, path

import _jsonnet
import requests
import yaml

# Source files list
charts = [
    {
        'source': 'https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/manifests/grafana-dashboardDefinitions.yaml',
        'destination': '../dashboards-1.14',
        'type': 'yaml',
        'multicluster_key': '(and .Values.grafana.enabled .Values.grafana.sidecar.dashboards.multicluster.global.enabled)',
    },
    {
        'source': 'https://raw.githubusercontent.com/etcd-io/etcd/main/contrib/mixin/mixin.libsonnet',
        'destination': '../dashboards-1.14',
        'type': 'jsonnet_mixin',
        'multicluster_key': '(and .Values.grafana.enabled (or .Values.grafana.sidecar.dashboards.multicluster.global.enabled .Values.grafana.sidecar.dashboards.multicluster.etcd.enabled))',
    },
]


def escape(s):
    return s.replace("{{", "{{`{{").replace("}}", "}}`}}").replace("{{`{{", "{{`{{`}}").replace("}}`}}", "{{`}}`}}")


def unescape(s):
    return s.replace("[{", "{{").replace("}]", "}}")


def patch_dashboards_json(content, multicluster_key):
    try:
        content_struct = json.loads(content)

        # multicluster
        overwrite_list = []
        for variable in content_struct['templating']['list']:
            if variable['name'] == 'cluster':
                variable['hide'] = ':multicluster:'
            overwrite_list.append(variable)
        content_struct['templating']['list'] = overwrite_list

        # fix drilldown links. See https://github.com/kubernetes-monitoring/kubernetes-mixin/issues/659
        for row in content_struct['rows']:
            for panel in row['panels']:
                for style in panel.get('styles', []):
                    if 'linkUrl' in style and style['linkUrl'].startswith('./d'):
                        style['linkUrl'] = style['linkUrl'].replace('./d', '/d')

        content_array = []
        original_content_lines = content.split('\n')
        for i, line in enumerate(json.dumps(content_struct, indent=4).split('\n')):
            if (' []' not in line and ' {}' not in line) or line == original_content_lines[i]:
                content_array.append(line)
                continue

            append = ''
            if line.endswith(','):
                line = line[:-1]
                append = ','

            if line.endswith('{}') or line.endswith('[]'):
                content_array.append(line[:-1])
                content_array.append('')
                content_array.append(' ' * (len(line) - len(line.lstrip())) + line[-1] + append)

        content = '\n'.join(content_array)

        multicluster = content.find(':multicluster:')
        if multicluster != -1:
            content = ''.join((
                content[:multicluster-1],
                '[{ if %s }]0[{ else }]2[{ end }]' % multicluster_key,
                content[multicluster + 15:]
            ))
    except (ValueError, KeyError):
        pass

    return content


def patch_json_set_timezone_as_variable(content):
    # content is no more in json format, so we have to replace using regex
    return re.sub(r'"timezone"\s*:\s*"(?:\\.|[^\"])*"', '"timezone": "[{ if .Values.grafana.enabled }][{ .Values.grafana.defaultDashboardsTimezone }][{ else }][{ (index .Values "grafana-operator" "defaultDashboardsTimezone") }][{ end }]"', content, flags=re.IGNORECASE)


def write_dashboard_to_file(resource_name, content, url, destination, multicluster_key):
    content = patch_dashboards_json(content, multicluster_key)
    content = patch_json_set_timezone_as_variable(content)
    content = escape(content)  # escape {{ and }} for helm
    content = unescape(content)  # unescape [{ and }] for templating

    filename = resource_name + '.jtpl'
    new_filename = "%s/%s" % (destination, filename)

    # make sure directories to store the file exist
    makedirs(destination, exist_ok=True)

    if content[-1] != "\n":
        content += "\n"

    # recreate the file
    with open(new_filename, 'w') as f:
        f.write(content)

    print("Generated %s" % new_filename)


def main():
    # read the dashboards, create a new template file per group
    for chart in charts:
        print("Generating dashboards from %s" % chart['source'])
        response = requests.get(chart['source'])
        if response.status_code != 200:
            print('Skipping the file, response code %s not equals 200' % response.status_code)
            continue
        raw_text = response.text

        if chart['type'] == 'yaml':
            yaml_text = yaml.full_load(raw_text)
            items = yaml_text['items']
            for item in items:
                for resource, content in item['data'].items():
                    write_dashboard_to_file(resource.replace('.json', ''), content, chart['source'], chart['destination'], chart['multicluster_key'])
        elif chart['type'] == 'jsonnet_mixin':
            json_text = json.loads(_jsonnet.evaluate_snippet(chart['source'], raw_text + '.grafanaDashboards'))
            # is it already a dashboard structure or is it nested (etcd case)?
            flat_structure = bool(json_text.get('annotations'))
            if flat_structure:
                resource = path.basename(chart['source']).replace('.json', '')
                write_dashboard_to_file(resource, json.dumps(json_text, indent=4), chart['source'], chart['destination'], chart['multicluster_key'])
            else:
                for resource, content in json_text.items():
                    write_dashboard_to_file(resource.replace('.json', ''), json.dumps(content, indent=4), chart['source'], chart['destination'], chart['multicluster_key'])
    print("Finished")


if __name__ == '__main__':
    main()
