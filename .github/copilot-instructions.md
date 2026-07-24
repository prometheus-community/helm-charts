# GitHub Copilot Instructions

Follow the repository-wide agent guidance in `AGENTS.md`. This repository contains Helm charts for Prometheus ecosystem components.

Most tasks are Helm chart feature changes. When changing a chart:

- Work within a single chart under `charts/<chart>/`.
- Read `Chart.yaml`, `values.yaml`, relevant templates, helpers, and existing tests before editing.
- Follow existing chart patterns before adding new structure.
- Update `values.yaml`, templates, tests, and generated schema artifacts together when a new value changes rendered behavior.
- If `values.yaml` contains `# @schema` comments or `# $schema: ./values.schema.json`, follow the `helm-values-schema` skill guidance and regenerate `values.schema.json`.
- Add or update helm-unittest coverage for rendered behavior changed by templates or values.
- Run `make helm-unittest HELM_CHART=<chart-name>` for charts with helm-unittest coverage.
- Bump the chart version in `Chart.yaml` for chart changes not ignored by `.helmignore`.
- Do not edit generated ownership files such as `.github/CODEOWNERS` or `MAINTAINERS.md` directly.
