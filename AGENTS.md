# Instructions for AI Agents

The following guidelines apply to all files in this repository.

## Repository Overview

This is the **Grafana Community Helm Charts** repository — a collection of Helm charts for Grafana ecosystem components. Charts are published to both a Helm repository (`prometheus-community`) and as OCI artifacts on `ghcr.io`.

## Charts

All charts live under `charts/` with a subfolder for each chart.  The subfolder names must match the chart name as described in the Chart.yaml file `.name`.

Each chart follows standard Helm structure (`Chart.yaml`, `values.yaml`, `templates/`). Some charts will organize components into subdirectories (e.g., `templates/compactor/`, `templates/ingester/`).

## Feature Implementation Workflow

Most agent tasks in this repository are chart feature changes. For these tasks:

1. Identify the affected chart under `charts/<chart>/` and keep changes scoped to that chart.
2. Read the relevant `Chart.yaml`, `values.yaml`, templates, helpers, and existing tests before editing.
3. Implement the feature using the chart's existing template style and values structure.
4. If `values.yaml` changes in a schema-enabled chart, update schema annotations and regenerate `values.schema.json`.
5. Add or update focused helm-unittest coverage for the rendered behavior controlled by the feature.
6. Bump the chart version in `Chart.yaml` according to SemVer.
7. Run the relevant validation commands, normally `make helm-unittest HELM_CHART=<chart-name>` and any required schema generation command.

Ask the user for clarification only when the intended chart, feature behavior, or compatibility impact cannot be inferred from the request and local context.

## Values Schema

Some charts generate `values.schema.json` from `values.yaml` using `helm-values-schema-json`. A chart uses this flow if `values.yaml` contains `# @schema` comments or a top-level `# $schema: ./values.schema.json` comment. Upstream documentation lives at https://github.com/losisin/helm-values-schema-json/blob/main/docs/README.md; use Context7 for current docs when available.

Helm validates chart values with JSON Schema draft-07. Keep generated schemas compatible with draft-07 even if external schema tooling supports newer drafts.

When changing `values.yaml` in a schema-enabled chart:

- Use the `helm-values-schema` skill for detailed schema annotation and regeneration rules.
- Preserve and update nearby `# @schema` annotations.
- Add `# @schema` annotations when inferred schema types would be wrong or too loose.
- Keep `# @schema` comments before helm-docs comments (`# -- ...`) when both are present.
- Regenerate `values.schema.json` and include it in the change.
- For Loki, run `make helm-schema HELM_CHART=loki`.
- Add or update helm-unittest coverage for rendered behavior controlled by the changed values.

## pre-commit testing

### helm-unittests

Pull Requests against this repository require that all charts which implement helm-unittests(https://github.com/helm-unittest/helm-unittest) must pass all of their unittests.  This can be done via a single command run from the repository root:

```bash
make helm-unittest HELM_CHART=<chart-name>
```

## Contributing Conventions

- **One chart per PR**: CI enforces that PRs only change a single chart.
- **PR title format**: Must start with `[chart-name] ` (e.g., `[grafana] Add new feature`).
- **Version bumps**: Every chart change (excluding files listed in `.helmignore`) requires a SemVer version bump in `Chart.yaml`. Major bumps for breaking changes.
- **DCO sign-off**: Commits must include `Signed-off-by` line (`git commit -s`).
- **Squash merge only**: The repository only allows squash merges.
- **CODEOWNERS/MAINTAINERS**: Auto-generated from `Chart.yaml` maintainer entries by `scripts/generate-codeowners.sh` and `scripts/generate-maintainers.sh`. Do not edit `.github/CODEOWNERS` or `MAINTAINERS.md` directly.
- **Minimum Kubernetes version**: Charts target `^1.25.0-0` (`kubeVersion` in `Chart.yaml`).

## Dependency Management

Renovate manages all dependency updates.
