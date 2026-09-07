#!/usr/bin/env bash
# Consumer-security defaults on Fedora Atomic: firewalld default-deny zone, SELinux enforcing (Bazzite default),
# polkit auth_admin_keep for Snormium actions, sysctl hardening (overlay), auto screen lock (KDE defaults).
set -Eeuo pipefail
# firewalld: default zone "public" already denies inbound except a few services; drop mdns? keep for printers/casting.
# Steam Remote Play / KDE Connect are toggled by the Security Center via firewall-cmd --add-service.
sed -i 's/^DefaultZone=.*/DefaultZone=public/' /etc/firewalld/firewalld.conf
# SELinux stays enforcing (Bazzite default). Assert, don't assume.
grep -q '^SELINUX=enforcing' /etc/selinux/config || sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
# usbguard installed but disabled (Advanced toggle)
systemctl disable usbguard.service 2>/dev/null || true
