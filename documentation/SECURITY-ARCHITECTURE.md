# Snormium security architecture (NIST CSF-aligned, not certified)

Goal: Windows-Defender-class *consumer* protection on Linux Mint, invisible until it matters, without breaking
Steam/Proton/Wine/emulators/audio hardware. Formal NIST certification has **not** been performed.

| CSF function | Snormium implementation | Windows analogue |
|--------------|--------------------------|------------------|
| **Identify** | Security Center inventories firewall, updates, AppArmor, Secure Boot, encryption, firmware, snapshots, failed services, disk space; Driver Manager identifies GPU/driver; `fwupd` identifies firmware | Security dashboard, Device Manager |
| **Protect** | UFW default-deny inbound (opt-in app profiles); AppArmor enforce for browsers/mail/office, Steam etc. deliberately `unconfined` (Ubuntu policy); Flatpak/bubblewrap sandbox for emulators & launchers; polkit `auth_admin_keep` for every Snormium privileged action (UAC-like, prompts only on change); LUKS in installer; signed shim/GRUB/kernel (Secure Boot); `sysctl` hardening (ptrace scope, kptr, protected_* , redirects); automatic screen lock; pwquality; optional USBGuard | Firewall, UAC, SmartScreen (partial: Flatpak sandbox), BitLocker, Secure Boot, Protected system files |
| **Detect** | unattended-upgrades logs; `needrestart` reboot-required; `systemctl --failed` surfaced in Security Center; fwupd; (no AV: Linux desktop malware risk is addressed by signed repos + sandboxing, ClamAV optional via Software Center) | Defender scans, Reliability Monitor |
| **Respond** | Security Center "Fix" buttons; Recovery Center "Repair updates"; friendly error messages with Advanced details | Troubleshooters |
| **Recover** | Timeshift weekly restore points + initial snapshot on first boot; GRUB previous-kernel one-shot; Mint Backup for files; live ISO rescue | System Restore, Safe Mode, File History |

Compatibility policy: a security control that breaks any item in `packages/gaming.list`, `flatpak.list`
or a USB-class audio device is a bug in the control, not in the app.
