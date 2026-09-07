#!/usr/bin/env bash
# RPM layer. Bazzite already ships Steam, Proton tooling, Gamescope, GameMode, MangoHud, Vulkan 32-bit,
# controller udev rules, PipeWire, fwupd, firewalld, SELinux, Flatpak+Flathub, ujust. We add little.
set -Eeuo pipefail
read_list() { grep -vE '^\s*(#|$)' "$1" | awk '{print $1}'; }
mapfile -t add < <(read_list /ctx/packages/rpm-add.list)
mapfile -t rm  < <(read_list /ctx/packages/rpm-remove.list)
[[ ${#rm[@]}  -gt 0 ]] && dnf5 -y remove  "${rm[@]}"  || true
[[ ${#add[@]} -gt 0 ]] && dnf5 -y install --setopt=install_weak_deps=False "${add[@]}"
# Flatpaks are installed on first boot by snormium-flatpaks.service (see 20-system.sh).
# Native multimedia: Bazzite provides full codecs (RPM Fusion ffmpeg, gstreamer freeworld, Terra Mesa with H.264/HEVC VA-API).
# Assert rather than assume, so a future base change cannot silently ship a codec-less Snormium.
# Names verified against the 2026-09-06 base. VA-API drivers now live inside mesa-dri-drivers (virtual provide
# mesa-va-drivers); Fedora's ffmpeg 8 is unrestricted and gstreamer1-plugin-libav routes GStreamer through it, so the
# old RPM Fusion "freeworld" packages are neither present nor needed. Use --whatprovides so renames don't create WARN noise.
# NOTE: "mesa-va-drivers" is a VIRTUAL PROVIDE of mesa-dri-drivers on Fedora 44+; do not "correct" it to a real name.
for p in ffmpeg gstreamer1-plugins-bad-free gstreamer1-plugins-good gstreamer1-plugins-ugly-free gstreamer1-plugin-libav gstreamer1-plugin-dav1d \
         mesa-va-drivers libva libva-intel-media-driver; do
  rpm -q --whatprovides "$p" >/dev/null 2>&1 || echo "WARN: expected codec component missing from base: $p"
done
for f in /usr/lib64/dri/radeonsi_drv_video.so /usr/lib64/dri/iHD_drv_video.so; do
  [[ -e $f ]] || echo "WARN: VA-API driver not found: $f"
done
dnf5 clean all
