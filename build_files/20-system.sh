#!/usr/bin/env bash
# Overlay system_files, enable services, register Flatpak preinstall list, wire ujust recipes.
set -Eeuo pipefail
cp -avf /ctx/system_files/. /
find /usr/bin /usr/lib/snormium /usr/share/snormium -name __pycache__ -type d -exec rm -rf {} + 2>/dev/null || true
chmod 755 /usr/bin/snormium-* /usr/libexec/snormium/*
# Plasma theme package must be valid or new sessions fall back to Breeze silently
kpackagetool6 --type Plasma/LookAndFeel --show org.snormium.desktop >/dev/null 2>&1 || echo "WARN: kpackagetool6 cannot read org.snormium.desktop (check metadata.json)"
# Flatpaks: Bazzite has NO file-driven system-Flatpak preinstall (verified 2026-09-03: bazzite-flatpak-manager only
# configures remotes/overrides). Snormium installs its "core" tier itself via snormium-flatpaks.service on first boot.
# Package manifests visible to the running system (Welcome Center / snormium-setup read them)
mkdir -p /usr/share/snormium/packages; cp /ctx/packages/*.list /usr/share/snormium/packages/
cp /ctx/packages/appimage.list /usr/share/snormium/appimage.list; cp /ctx/packages/flatpak.list /usr/share/snormium/flatpak.list
systemctl enable snormium-firstboot.service snormium-flatpaks.service
# Automatic updates: Bazzite ships uupd (or ublue-update) on a timer. Make sure it is on; never auto-reboot.
systemctl enable uupd.timer
systemctl enable firewalld.service fwupd-refresh.timer
