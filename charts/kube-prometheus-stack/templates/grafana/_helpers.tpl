{{- define "kube-prometheus-stack.grafana.datasources" -}}
{{- $scrapeInterval := .Values.grafana.sidecar.datasources.defaultDatasourceScrapeInterval | default .Values.prometheus.prometheusSpec.scrapeInterval | default "30s" -}}
{{- $datasources := list -}}

{{/* Prometheus Datasource */}}
{{- if .Values.grafana.sidecar.datasources.defaultDatasourceEnabled }}
  {{- $jsonData := dict 
    "httpMethod"  .Values.grafana.sidecar.datasources.httpMethod
    "timeInterval" $scrapeInterval
    "timeout"     .Values.grafana.sidecar.datasources.timeout
  -}}
  {{- if .Values.grafana.sidecar.datasources.exemplarTraceIdDestinations -}}
    {{- $_ := set $jsonData "exemplarTraceIdDestinations" (list (dict 
      "datasourceUid" .Values.grafana.sidecar.datasources.exemplarTraceIdDestinations.datasourceUid
      "name"         .Values.grafana.sidecar.datasources.exemplarTraceIdDestinations.traceIdLabelName
      "urlDisplayLabel" .Values.grafana.sidecar.datasources.exemplarTraceIdDestinations.urlDisplayLabel
    )) -}}
  {{- end -}}
  {{- $datasources = append $datasources (dict
    "name"     .Values.grafana.sidecar.datasources.name
    "type"     "prometheus"
    "uid"      .Values.grafana.sidecar.datasources.uid
    "url"      (coalesce .Values.grafana.sidecar.datasources.url (include "kube-prometheus-stack.grafana.datasourceUrl.defaultPrometheus" .))
    "access"   "proxy"
    "isDefault" (.Values.grafana.sidecar.datasources.isDefaultDatasource | default false)
    "jsonData" $jsonData
  ) -}}
{{- end }}

{{/* Prometheus Replica Datasources */}}
{{- if .Values.grafana.sidecar.datasources.createPrometheusReplicasDatasources }}
  {{- range $index := until (int .Values.prometheus.prometheusSpec.replicas) }}
    {{- $jsonData := dict "timeInterval" $scrapeInterval -}}
    {{- if $.Values.grafana.sidecar.datasources.exemplarTraceIdDestinations -}}
      {{- $_ := set $jsonData "exemplarTraceIdDestinations" (list (dict 
        "datasourceUid" $.Values.grafana.sidecar.datasources.exemplarTraceIdDestinations.datasourceUid
        "name"         $.Values.grafana.sidecar.datasources.exemplarTraceIdDestinations.traceIdLabelName
        "urlDisplayLabel" $.Values.grafana.sidecar.datasources.exemplarTraceIdDestinations.urlDisplayLabel
      )) -}}
    {{- end -}}
    {{- $datasources = append $datasources (dict
      "name"     (printf "%s-%d" $.Values.grafana.sidecar.datasources.name $index)
      "type"     "prometheus"
      "uid"      (printf "%s-replica-%d" $.Values.grafana.sidecar.datasources.uid $index)
      "url"      (include "kube-prometheus-stack.grafana.datasourceUrl.replica" (dict "context" $ "index" $index))
      "access"   "proxy"
      "isDefault" false
      "jsonData" $jsonData
    ) -}}
  {{- end -}}
{{- end }}

{{/* Alertmanager Datasource */}}
{{- if .Values.grafana.sidecar.datasources.alertmanager.enabled }}
  {{- $datasources = append $datasources (dict
    "name"     (.Values.grafana.sidecar.datasources.alertmanager.name | default "Alertmanager")
    "type"     "alertmanager"
    "uid"      (.Values.grafana.sidecar.datasources.alertmanager.uid | default "alertmanager")
    "url"      (coalesce .Values.grafana.sidecar.datasources.alertmanager.url (include "kube-prometheus-stack.grafana.datasourceUrl.alertmanager" .))
    "access"   "proxy"
    "isDefault" false
    "jsonData" (dict
      "handleGrafanaManagedAlerts" (.Values.grafana.sidecar.datasources.alertmanager.handleGrafanaManagedAlerts | default false)
      "implementation"            (.Values.grafana.sidecar.datasources.alertmanager.implementation | default "prometheus")
    )
  ) -}}
{{- end }}

{{/* Additional Datasources */}}
{{- if .Values.grafana.additionalDataSources -}}
  {{- $datasources = concat $datasources .Values.grafana.additionalDataSources -}}
{{- end -}}

{{- toYaml (dict "datasources" $datasources) -}}
{{- end -}}

{{- define "kube-prometheus-stack.grafana.datasourceUrl.defaultPrometheus" -}}
{{- printf "http://%s-prometheus.%s:%v/%s"
    (include "kube-prometheus-stack.fullname" .)
    (include "kube-prometheus-stack.namespace" .)
    (.Values.prometheus.service.port | toString)
    (trimPrefix "/" (.Values.prometheus.prometheusSpec.routePrefix | default "")) -}}
{{- end -}}

{{- define "kube-prometheus-stack.grafana.datasourceUrl.replica" -}}
{{- $index := .index -}}
{{- $ctx := .context -}}
{{- printf "http://prometheus-%s-%d.prometheus-operated:9090/%s"
    (include "kube-prometheus-stack.prometheus.crname" $ctx)
    $index
    (trimPrefix "/" ($ctx.Values.prometheus.prometheusSpec.routePrefix | default "")) -}}
{{- end -}}

{{- define "kube-prometheus-stack.grafana.datasourceUrl.alertmanager" -}}
{{- printf "http://%s-alertmanager.%s:%v/%s"
    (include "kube-prometheus-stack.fullname" .)
    (include "kube-prometheus-stack.namespace" .)
    (.Values.alertmanager.service.port | toString)
    (trimPrefix "/" (.Values.alertmanager.alertmanagerSpec.routePrefix | default "")) -}}
{{- end -}}

{{/* Helper function to sanitize names */}}
{{- define "kube-prometheus-stack.grafana.sanitizeName" -}}
{{- $name := lower . -}}
{{- $name := regexReplaceAll "[^a-z0-9-]" $name "-" -}}
{{- $name := regexReplaceAll "^[^a-z]" $name "x" -}}
{{- $name := regexReplaceAll "-+$" $name "" -}}
{{- $name := regexReplaceAll "^-+" $name "" -}}
{{- $name := regexReplaceAll "-+'" $name "-" -}}
{{- if eq $name "" -}}
{{- "default" -}}
{{- else -}}
{{- $name -}}
{{- end -}}
{{- end -}}
