#!/usr/bin/env bash

# Make sure sort works predictably.
export LC_ALL=C

cat <<EOF
# Maintainers

## General maintainers

- André Bauer (@monotek)
- Jan-Otto Kröpke (@jkroepke)
- Scott Rigby (@scottrigby)
- Torsten Walter (@torstenwalter)

## GitHub Workflows & Renovate maintainers

- Gabriel Martinez (@GMartinez-Sisti)

## Helm charts maintainers
EOF

yq_script='"\n### " + .name + "\n\n" + ([.maintainers[] | "- " + .name + " <" + .email + "> (" + (.url | sub("https://github.com/", "@") + ")")] | sort | join("\n"))'
yq e "${yq_script}" charts/*/Chart.yaml
