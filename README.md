# Snormium 2.0 — a Bazzite-based desktop & gaming OS

Snormium 2.0 is **Bazzite** (Fedora Atomic, KDE Plasma/Wayland, bootc) with Snormium's consumer-security layer, Welcome/Security/
Recovery centers, curated emulation setup, and an original visual identity — built as a container image and shipped as a signed,
atomically-updating system with an installer ISO.

* Secure by default: firewalld, SELinux enforcing, signed read-only system image, Flatpak sandboxing, polkit prompts only on change
* Automatic background updates that never restart the computer; previous image always kept; one-click rollback
* Bazzite's gaming stack: Steam/Proton, Gamescope, HDR, VRR, MangoHud, controllers — maintained upstream
* Emulation: RetroArch + curated cores, DuckStation, PCSX2, RPCS3, Azahar, melonDS, Flycast, PPSSPP, Dolphin; Eden/ES-DE/SRM pinned AppImages
* Full desktop via Flathub: LibreOffice, Thunderbird, VLC, qBittorrent; Creative Studio one click away

## Build
```
# on a Linux VM with ~40 GB free:  put snormium2-*-source.tar.gz (+.sha256) and optional art in ~/Downloads, then
bash ~/Downloads/build.sh            # AMD/Intel image + ISO     (--nvidia for the NVIDIA-open image)
# or manually:
just build && just audit && just build-iso    # output/snormium-latest-x86_64.iso
```
Publishing: push this repo to GitHub, set `REPO_ORGANIZATION` in `snormium.env`; the workflow builds weekly on top of the
latest Bazzite, audits, pushes to ghcr.io and signs with cosign. Installed systems then update automatically.

## Layout
```
Containerfile           FROM bazzite → runs build_files/build.sh
build_files/            05-snapshot 10-packages 20-system 30-security 40-branding 50-debrand(+audit) 55-verify-bazzite-stack 90-cleanup
system_files/           overlaid on /: apps (usr/bin, usr/lib/snormium), KDE/SDDM/Plymouth defaults, udev, polkit, ujust recipes, docs
packages/               rpm-add, debrand-remove, flatpak (core/full), appimage (pinned), THIRD-PARTY.md
branding/               logo, palette, wallpaper generator, custom/ drop-in
disk_config/            bootc-image-builder configs (iso.toml, disk.toml)
testing/                lint.sh, CHECKLIST.md
```
Read `STATUS.md` before relying on anything. 1.0 (Linux Mint base) lives in its own archive and is unaffected.
