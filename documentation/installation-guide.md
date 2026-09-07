# Installation guide
1. **Download** the ISO and its `.sha256`; verify with `sha256sum -c`.
2. **Write to USB** (8 GB+): Rufus (DD mode) or balenaEtcher on Windows; Etcher or `dd` on Linux/macOS.
3. **Boot** from USB (F12 / F2 / Del / Esc at power-on). Secure Boot can stay **on** — Snormium is signed with the
   Universal Blue key; if the firmware asks you to enrol a key on first boot, the password is `universalblue`.
4. The installer (Anaconda) asks for language, keyboard, disk, and your user. Tick **Encrypt my data** on the disk screen —
   that is what turns "Disk encryption" green in Security Center. Dual-boot: choose *Custom* and keep the other OS's partitions.
5. Restart, remove the USB. First boot installs the bundled apps from Flathub (needs internet, a few minutes) and pins the
   initial system image as a permanent restore point.
**NVIDIA cards**: download the `snormium-nvidia` ISO instead. There is no driver to install afterwards — it's part of the image.
