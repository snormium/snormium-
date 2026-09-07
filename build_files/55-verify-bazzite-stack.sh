#!/usr/bin/env bash
# Guarantee Bazzite's native stack is intact: (1) no RPM that existed in the base is missing now; (2) the gaming and
# system tooling Snormium is built on is present and executable. Hard failure on either.
set -Eeuo pipefail
[[ -f /tmp/rpm-before.txt ]] || { echo "05-snapshot.sh did not run"; exit 1; }
rpm -qa --qf '%{NAME}\n' | sort -u > /tmp/rpm-after.txt
mapfile -t gone < <(comm -23 /tmp/rpm-before.txt /tmp/rpm-after.txt)
if [[ ${#gone[@]} -gt 0 ]]; then
  echo "FAIL: packages present in Bazzite but missing from Snormium:"; printf '   %s\n' "${gone[@]}"; exit 1
fi
echo "package integrity: all $(wc -l < /tmp/rpm-before.txt) base packages retained ($(comm -13 /tmp/rpm-before.txt /tmp/rpm-after.txt | wc -l) added)"
fail=0
# executables that define the platform
for b in steam gamescope mangohud ujust uupd bootc rpm-ostree flatpak firewall-cmd fwupdmgr distrobox podman \
         plymouth-set-default-theme steamos-add-to-steam pipewire wireplumber plasmashell kwin_wayland bazaar-daemon; do
  if p=$(command -v "$b" 2>/dev/null) && [[ -x "$p" ]]; then :; else echo "FAIL: missing/unexecutable: $b"; fail=1; fi
done
# A display manager must exist (Bazzite moved from sddm to plasmalogin in 2026-09; accept either)
if ! command -v plasmalogin >/dev/null 2>&1 && ! command -v sddm >/dev/null 2>&1; then echo "FAIL: no display manager (plasmalogin/sddm)"; fail=1; fi
# packages that must exist — prefer VIRTUAL PROVIDES and binaries over literal names: Bazzite renames packages within weeks
# (gamescope → terra-gamescope, sddm → plasma-login-manager, gamemode dropped; all seen 2026-09-06).
for p in steam gamescope mangohud mesa-vulkan-drivers pipewire wireplumber firewalld fwupd flatpak bootc rpm-ostree \
         kernel selinux-policy-targeted xorg-x11-server-Xwayland bluez; do
  rpm -q --whatprovides "$p" >/dev/null 2>&1 || { echo "FAIL: nothing provides: $p"; fail=1; }
done
# Dropped/renamed upstream: keep visible as WARN, never fail. GameMode's role is covered by Gamescope on Bazzite.
command -v gamemoderun >/dev/null 2>&1 || echo "WARN: optional binary absent from base (upstream dropped it): gamemoderun"
# 32-bit gaming libraries (Steam client + many Windows titles need them)
for p in mesa-vulkan-drivers.i686 glibc.i686 libgcc.i686 mesa-dri-drivers.i686; do
  rpm -q "$p" >/dev/null 2>&1 || { echo "WARN: 32-bit lib not found: $p"; }
done
# Bazzite's own services still enabled
for u in uupd.timer bazzite-flatpak-manager.service; do
  systemctl is-enabled "$u" >/dev/null 2>&1 || echo "WARN: $u not enabled (check whether Bazzite renamed it)"
done
[[ $fail -eq 0 ]] && echo "Bazzite native stack: INTACT" || { echo "Bazzite native stack: BROKEN"; exit 1; }
