# Snormium release test checklist

Mark each item **PASS / FAIL / N/A** with date, tester, hardware/VM. A release requires every non-N/A item to PASS
in VM (UEFI + BIOS) and on at least one AMD, one NVIDIA and one Intel-GPU machine.

## Boot & install
- [ ] ISO boots in UEFI (OVMF) — GRUB menu shows Snormium branding
- [ ] ISO boots in legacy BIOS — isolinux menu shows Snormium branding
- [ ] Secure Boot ON in OVMF: shim → GRUB → kernel chain boots without MOK prompts
- [ ] Plymouth Snormium theme visible during boot
- [ ] Live session reaches Cinnamon desktop with Snormium wallpaper/theme
- [ ] Installer: automatic partitioning, encrypted LVM, manual partitioning, second disk
- [ ] Installer: user creation, time zone, keyboard, Wi-Fi during install
- [ ] First boot: snormium-firstboot creates initial Timeshift snapshot; ufw active; timers enabled
- [ ] Welcome Center appears once; "show at login" toggle persists
## Security
- [ ] Security Center shows GREEN on a fresh encrypted UEFI+SB install; each row accurate
- [ ] Turning firewall off/on via switch prompts for password once and reflects state
- [ ] `sudo unattended-upgrade --dry-run` picks up security origin
- [ ] Reboot-required notification appears after kernel update; no auto reboot
- [ ] AppArmor: `aa-status` shows profiles enforced; Firefox confined; Steam unconfined
- [ ] USBGuard off by default; enabling allow-lists current devices
## Updates & recovery
- [ ] Update Manager shows history; automation on
- [ ] Recovery Center: create restore point; restore it; system boots
- [ ] "Restart into previous kernel" boots the older kernel once
- [ ] "Repair updates" completes after simulated interrupted dpkg (kill -9 mid-install)
## Gaming
- [ ] Steam installs and logs in; Proton game (Steam Play) launches (test: a free Proton-verified title)
- [ ] ProtonUp-Qt installs Proton-GE; selectable in Steam
- [ ] GameMode activates (`gamemoded -s` while game runs)
- [ ] MangoHud toggles with Right Shift+F12
- [ ] Heroic / Lutris / Bottles install from Welcome > More launchers
- [ ] Xbox (USB+BT), DualSense (USB+BT), Switch Pro (USB+BT): detected in Steam & jstest-gtk
- [ ] NVIDIA: Driver Manager offers recommended driver; after install + MOK enrolment, Vulkan works (`vulkaninfo --summary`)
- [ ] AMD/Intel: Vulkan works out of the box; VRR toggle in Display settings
## Emulation
- [ ] Welcome > Emulation setup creates ~/Games/Emulation layout
- [ ] RetroArch core downloader installs listed cores; homebrew ROM runs in each
- [ ] PCSX2 / RPCS3 / Azahar / DuckStation / melonDS / Flycast / PPSSPP launch and detect controller
- [ ] ES-DE (if pinned) scans folders and launches RetroArch + standalone emulators
- [ ] Eden (if pinned) launches and reports missing keys with the guide link
## Desktop
- [ ] LibreOffice, Firefox, Thunderbird, VLC (hardware decode: `vainfo`), printing to network printer, simple-scan
- [ ] Bluetooth audio, USB audio interface (Focusrite) in Pro Audio profile, qpwgraph routing
- [ ] Suspend/resume, hibernate (if swap), lid, brightness, power profiles
- [ ] Multi-monitor incl. mixed refresh rates
- [ ] Orca reads installer and desktop; magnifier; high contrast; onboard keyboard
- [ ] Privacy settings page: camera/mic/location toggles
