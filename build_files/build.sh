#!/usr/bin/env bash
# Orchestrates the Snormium layer on top of Bazzite. Runs INSIDE the container build as root.
set -Eeuo pipefail
export CTX=/ctx
for step in "$CTX"/build_files/[0-9][0-9]-*.sh; do
  echo "=================== $(basename "$step") ==================="
  bash "$step"
done
echo "Snormium layer applied."
