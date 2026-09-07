#!/usr/bin/env bash
set -Eeuo pipefail
dnf5 clean all; rm -rf /var/cache/* /var/log/* /tmp/* /var/lib/dnf /run/dnf /run/selinux-policy 2>/dev/null || true   # dnf state + countme counters must not ship in the image
# bootc requires /var and /opt content to be clean in the image
find /var -mindepth 1 -maxdepth 1 -not -name 'lib' -not -name 'cache' -not -name 'log' -not -name 'tmp' -not -name 'opt' -not -name 'usrlocal' -not -name 'roothome' -not -name 'mnt' -not -name 'srv' -not -name 'home' -not -name 'games' -exec rm -rf {} + 2>/dev/null || true
