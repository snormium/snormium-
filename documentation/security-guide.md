# Security guide
**Security Center** (Applications ▸ System) answers one question: *is my computer protected?*
* **Green** — nothing to do. **Yellow** — something is recommended (a *Fix* button is shown). **Red** — act now.
* **Firewall** (firewalld) blocks incoming connections; games connect *out* and work normally. Steam Remote Play and KDE Connect have
  switches under *Advanced*.
* **Automatic updates** download the next system image and app updates in the background. The computer **never restarts by itself**;
  the new image simply takes effect at your next restart, and the previous one is kept in case you need it.
* **Application protection** is SELinux (enforcing) plus Flatpak sandboxing for every app you install.
* <a id="secure-boot"></a>**Secure Boot**: on by default. First boot may ask you to enrol the Universal Blue key (password `universalblue`) — once.
* <a id="encryption"></a>**Disk encryption** is chosen at install time (*Encrypt my data*). External drives: Disks / Partition Manager.
* **USB device guard** (Advanced) blocks unknown USB devices until you unlock. Off by default because it can block a new keyboard.
* The system image itself is read-only and cryptographically signed; malware cannot persist in it.
Passwords are asked only when a setting actually changes, never for browsing or playing.
