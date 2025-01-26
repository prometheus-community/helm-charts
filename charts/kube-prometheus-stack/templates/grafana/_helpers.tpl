{{- define "kube-prometheus-stack.datasources" -}}
{{- $scrapeInterval := .Values.grafana.sidecar.datasources.defaultDatasourceScrapeInterval | default .Values.prometheus.prometheusSpec.scrapeInterval | default "30s" }}
{{- $datasources := list }}
{{- if .Values.grafana.sidecar.datasources.defaultDatasourceEnabled }}
{{/* Create jsonData dictionary first */}}
{{- $jsonData := dict 
  "httpMethod" .Values.grafana.sidecar.datasources.httpMethod
  "timeInterval" $scrapeInterval
  "timeout" .Values.grafana.sidecar.datasources.timeout
}}
{{/* Conditionally add exemplarTraceIdDestinations */}}
{{- if .Values.grafana.sidecar.datasources.exemplarTraceIdDestinations }}
{{- $_ := set $jsonData "exemplarTraceIdDestinations" (list (dict 
  "datasourceUid" .Values.grafana.sidecar.datasources.exemplarTraceIdDestinations.datasourceUid
  "name" .Values.grafana.sidecar.datasources.exemplarTraceIdDestinations.traceIdLabelName)) }}
{{- end }}
{{/* Create defaultDS with ordered fields */}}
{{- $defaultDS := dict }}
{{- $_ := set $defaultDS "name" .Values.grafana.sidecar.datasources.name }}
{{- $_ := set $defaultDS "type" "prometheus" }}
{{- $_ := set $defaultDS "uid" .Values.grafana.sidecar.datasources.uid }}
{{- $_ := set $defaultDS "url" (default (printf "http://%s-prometheus.%s:%v/%s"
    (include "kube-prometheus-stack.fullname" .)
    (include "kube-prometheus-stack.namespace" .)
    .Values.prometheus.service.port
    (trimPrefix "/" .Values.prometheus.prometheusSpec.routePrefix)
  ) .Values.grafana.sidecar.datasources.url) }}
{{- $_ := set $defaultDS "access" "proxy" }}
{{- $_ := set $defaultDS "isDefault" .Values.grafana.sidecar.datasources.isDefaultDatasource }}
{{- $_ := set $defaultDS "jsonData" $jsonData }}
{{- $datasources = append $datasources $defaultDS }}
{{- end }}

{{/* Same pattern for replica datasources */}}
{{- if .Values.grafana.sidecar.datasources.createPrometheusReplicasDatasources }}
{{- range until (int .Values.prometheus.prometheusSpec.replicas) }}
{{- $replicaDS := dict }}
{{- $_ := set $replicaDS "name" (printf "%s-%d" $.Values.grafana.sidecar.datasources.name .) }}
{{- $_ := set $replicaDS "type" "prometheus" }}
{{- $_ := set $replicaDS "uid" (printf "%s-replica-%d" $.Values.grafana.sidecar.datasources.uid .) }}
{{- $_ := set $replicaDS "url" (printf "http://prometheus-%s-%d.prometheus-operated:9090/%s"
    (include "kube-prometheus-stack.prometheus.crname" $)
    .
    (trimPrefix "/" $.Values.prometheus.prometheusSpec.routePrefix)) }}
{{- $_ := set $replicaDS "access" "proxy" }}
{{- $_ := set $replicaDS "isDefault" false }}
{{- $_ := set $replicaDS "jsonData" (dict "timeInterval" $scrapeInterval) }}
{{- if $.Values.grafana.sidecar.datasources.exemplarTraceIdDestinations }}
{{- $_ := set $replicaDS "jsonData" (dict 
    "timeInterval" $scrapeInterval
    "exemplarTraceIdDestinations" (list (dict 
      "datasourceUid" $.Values.grafana.sidecar.datasources.exemplarTraceIdDestinations.datasourceUid
      "name" $.Values.grafana.sidecar.datasources.exemplarTraceIdDestinations.traceIdLabelName))) }}
{{- end }}
{{- $datasources = append $datasources $replicaDS }}
{{- end }}
{{- end }}

{{/* And for alertmanager datasource */}}
{{- if .Values.grafana.sidecar.datasources.alertmanager.enabled }}
{{- $alertmanagerDS := dict }}
{{- $_ := set $alertmanagerDS "name" .Values.grafana.sidecar.datasources.alertmanager.name }}
{{- $_ := set $alertmanagerDS "type" "alertmanager" }}
{{- $_ := set $alertmanagerDS "uid" .Values.grafana.sidecar.datasources.alertmanager.uid }}
{{- $_ := set $alertmanagerDS "url" (default (printf "http://%s-alertmanager.%s:%v/%s"
    (include "kube-prometheus-stack.fullname" .)
    (include "kube-prometheus-stack.namespace" .)
    .Values.alertmanager.service.port
    (trimPrefix "/" .Values.alertmanager.alertmanagerSpec.routePrefix)
  ) .Values.grafana.sidecar.datasources.alertmanager.url) }}
{{- $_ := set $alertmanagerDS "access" "proxy" }}
{{- $_ := set $alertmanagerDS "isDefault" false }}
{{- $_ := set $alertmanagerDS "jsonData" (dict
    "handleGrafanaManagedAlerts" .Values.grafana.sidecar.datasources.alertmanager.handleGrafanaManagedAlerts
    "implementation" .Values.grafana.sidecar.datasources.alertmanager.implementation) }}
{{- $datasources = append $datasources $alertmanagerDS }}
{{- end }}

{{- if .Values.grafana.additionalDataSources }}
{{- $datasources = concat $datasources .Values.grafana.additionalDataSources }}
{{- end }}
{{- $result := dict "datasources" $datasources -}}
{{- $result | toYaml -}}
{{- end }}