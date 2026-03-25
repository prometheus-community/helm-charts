#!/usr/bin/env bash

# Make sure sort works predictably.
export LC_ALL=C

cat <<EOF
# Maintainers

## General maintainers

- André Bauer (<monotek23@gmail.com> / @monotek)
- Jan-Otto Kröpke (<github@jkroepke.de> / @jkroepke)
- Scott Rigby (<scott@r6by.com> / @scottrigby)
- Torsten Walter (<mail@torstenwalter.de> / @torstenwalter)

## GitHub Workflows & Renovate maintainers

- Gabriel Martinez (<kube-prometheus-stack@sisti.pt> / @GMartinez-Sisti)

## Helm charts maintainers
EOF

yq_script='"\n### " + .name + "\n\n" + ([.maintainers[] | "- " + .name + " (" + (("<" + .email + ">") // "unknown") + " / " + (.url | sub("https://github.com/", "@") + ")")] | sort | join("\n"))'
yq e "${yq_script}" charts/*/Chart.yaml
