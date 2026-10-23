# resource-state-metrics

A Helm chart for deploying the **resource‑state‑metrics** controller.

## Installing the chart

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install my-rsm prometheus-community/resource-state-metrics
```

## Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `quay.io/giantswarm/resource-state-metrics` |
| `image.tag` | Image tag | `"0.13.0"` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `8080` |

You can customise any field by passing a `values.yaml` file to `helm install`.
