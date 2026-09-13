---
name: bump-prometheus-operator
description: >-
  Bump the prometheus-operator version shipped by the kube-prometheus-stack
  chart. Use when a new prometheus-operator/prometheus-operator release is out
  and the chart's appVersion needs to follow it: syncs CRDs, checks for new CRD
  kinds, RBAC changes and newly added spec fields, bumps the chart version,
  updates UPGRADE.md, and opens a PR. Triggers on "bump prometheus-operator",
  "update kube-prometheus-stack to the latest operator", "sync operator CRDs".
---

# Bump prometheus-operator in kube-prometheus-stack

Promotes the `appVersion` of `charts/kube-prometheus-stack` to a new
`prometheus-operator/prometheus-operator` release and brings everything that
travels with the operator (CRDs, RBAC, upgrade notes) along with it.

## Scope of an operator bump

The operator version is the chart's `appVersion`. A bump touches a small,
fixed set of files — mirror the most recent merged bump PR (search
`git log --oneline -S "appVersion: v" -- charts/kube-prometheus-stack/Chart.yaml`)
rather than improvising:

- `charts/kube-prometheus-stack/Chart.yaml` — `appVersion` + chart `version`
- `charts/kube-prometheus-stack/charts/crds/crds/crd-*.yaml` (10 CRDs) and
  `charts/crds/files/crds.bz2` — regenerated, never hand-edited
- `charts/kube-prometheus-stack/UPGRADE.md` — new section
- `charts/kube-prometheus-stack/templates/prometheus-operator/clusterrole.yaml`
  — only if the operator's RBAC actually changed (see step 4)

## Procedure

### 1. Find the target version & branch

```bash
# Latest non-prerelease operator tag
curl -s https://api.github.com/repos/prometheus-operator/prometheus-operator/releases/latest | jq -r .tag_name
git checkout -b kube-prometheus-stack-bump-operator-<vX.Y.Z> upstream/main
```

Always branch off a fresh `upstream/main` so the PR diff is just the bump.

### 2. Bump Chart.yaml

Set `appVersion` to the new `vX.Y.Z`. Bump the chart `version` following the
precedent of the previous bump: historically a **minor** operator bump
(e.g. `v0.91.0 → v0.92.0`) is released as a **major** chart bump
(e.g. `86.x → 87.0.0`). Confirm the convention against the last bump PR.

### 3. Regenerate CRDs

`hack/update_crds.sh` reads `appVersion` from `Chart.yaml`, so bump Chart.yaml
**first**, then:

```bash
bash charts/kube-prometheus-stack/hack/update_crds.sh
```

This downloads the 10 CRDs from
`prometheus-operator/.../<appVersion>/example/prometheus-operator-crd/` and
rebuilds `charts/crds/files/crds.bz2`.

**Check for new CRD kinds** — if the operator added a CRD, the `FILES` array in
`update_crds.sh` (and the `crds` subchart) must be extended:

```bash
diff \
  <(curl -s "https://api.github.com/repos/prometheus-operator/prometheus-operator/contents/example/prometheus-operator-crd?ref=<OLD>" | jq -r '.[].name' | sort) \
  <(curl -s "https://api.github.com/repos/prometheus-operator/prometheus-operator/contents/example/prometheus-operator-crd?ref=<NEW>" | jq -r '.[].name' | sort)
```

### 4. Check RBAC

The chart's operator `ClusterRole` is maintained by hand, so confirm whether the
operator's required RBAC changed between versions:

```bash
f=example/rbac/prometheus-operator/prometheus-operator-cluster-role.yaml
diff \
  <(curl -s "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/<OLD>/$f") \
  <(curl -s "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/<NEW>/$f")
```

A diff in only the `app.kubernetes.io/version` label = **no change needed**.
Any new/removed `rules` entry = update
`templates/prometheus-operator/clusterrole.yaml` to match. Most patch/minor
operator bumps need no RBAC change.

### 5. Check for new spec fields

New CRD properties arrive silently with the regenerated CRDs — the chart renders
each `*Spec` field explicitly, so a field nobody wires up stays unreachable
except through `additionalConfig`. Diff the regenerated CRDs against the
committed ones to find what the release added:

```bash
cd charts/kube-prometheus-stack/charts/crds/crds
for f in crd-*.yaml; do python3 - "$f" <<'PY'
import subprocess, sys, yaml
f = sys.argv[1]
# crd-alertmanagerconfigs.yaml contains a bare `=`, which SafeLoader rejects
yaml.SafeLoader.add_constructor("tag:yaml.org,2002:value", lambda l, n: l.construct_scalar(n))
def paths(doc, prefix=""):
    out = set()
    for k, v in (doc.get("properties") or {}).items():
        out.add(prefix + k)
        out |= paths(v, prefix + k + ".")
    return out
def spec(doc):
    return doc["spec"]["versions"][0]["schema"]["openAPIV3Schema"]["properties"]["spec"]
old = yaml.safe_load(subprocess.run(["git", "show", f"HEAD:./{f}"], capture_output=True, text=True).stdout)
added = paths(spec(yaml.safe_load(open(f)))) - paths(spec(old))
if added:
    print(f, *sorted(added), sep="\n  ")
PY
done
```

Then check which of the added paths the chart can already reach: grep the
rendering template for `.Values.<component>Spec.<field>`. A field passed through
`toYaml`/`with` covers its whole subtree; one rendered key by key (`tsdb`,
`thanos`) only covers the sub-keys it names.

**Exposing them is a separate PR.** Keep the bump to the file set above — a
follow-up adds the values, the template lines and helm-unittest coverage with a
minor chart bump. The same sweep run against the full CRD (not just the diff)
finds older gaps too; see #7270 and #7272 for both shapes.

### 6. Update UPGRADE.md

Prepend a `## From <old-major>.x to <new-major>.x` section. Copy the previous
section's wording and the 10 `kubectl apply --server-side -f .../<NEW>/...`
CRD commands, swapping the version.

### 7. Validate

```bash
cd charts/kube-prometheus-stack
helm dependency build .        # required, or lint nil-pointers on subchart values
helm lint .
helm template t . | grep 'prometheus-operator:'   # must show the new vX.Y.Z
```

> CRDs live in the Helm-native `charts/crds/crds/` directory and are **not**
> rendered by `helm template` — that is expected. The `crds.bz2` only feeds the
> optional `crds.upgradeJob`.

### 8. Commit & PR

- Sign off (DCO) — see `CONTRIBUTING.md#sign-off-your-work`.
- Title: `[kube-prometheus-stack] Bump prometheus-operator to vX.Y.Z`.
- On review updates, add new commits — **do not squash** (the PR is squashed on
  merge).
- Fill the PR template; tick DCO + Chart Version bumped + title-starts-with-chart.
