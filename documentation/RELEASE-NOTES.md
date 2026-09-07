# Snormium 2.0 "Isotope" — release notes (pre-release / source only)
**Base:** Bazzite (Fedora Atomic, KDE Plasma on Wayland, bootc). Two images: `snormium` (AMD/Intel) and `snormium-nvidia`.
**Status:** image recipe, apps and documentation complete; **image and ISO not yet built or booted** — see STATUS.md.
## What changed from 1.0 (Linux Mint)
* Atomic updates with rollback replace Timeshift; Recovery Center = roll back / pin images
* Gamescope, HDR, VRR, Gaming Mode session come from Bazzite; nothing hand-rolled
* firewalld + SELinux replace ufw + AppArmor; Security Center reports both
* Discover + Flathub replace Software Center + apt; LibreOffice, Thunderbird, VLC, qBittorrent ship as Flatpaks
* KDE Plasma replaces Cinnamon; Snormium look-and-feel, SDDM and Plymouth theming; Bazzite/Steam-Deck artwork removed and audited
## Kept
Welcome / Security / Recovery centers, emulation layout and curated cores, controller and USB-audio rules, PipeWire studio profile,
checksum-pinned AppImages, all guides.
