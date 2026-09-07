#!/usr/bin/env bash
# Record the base image's package set BEFORE Snormium touches anything. 55-verify-bazzite-stack.sh diffs against it.
set -Eeuo pipefail
rpm -qa --qf '%{NAME}\n' | sort -u > /tmp/rpm-before.txt
echo "base package count: $(wc -l < /tmp/rpm-before.txt)"
