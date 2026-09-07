# Driver guide
Snormium is an *image-based* system: drivers are part of the system image, not something you install.
* **AMD / Intel** — `snormium` image. Mesa, Vulkan, VA-API video decode: nothing to do.
* **NVIDIA** — `snormium-nvidia` image (open kernel modules, RTX 20-series and newer). Already installed; updated with the system.
  Switch an existing install between images in Recovery Center ▸ Advanced, or `sudo bootc switch ghcr.io/snormium/snormium-nvidia`.
* **Firmware** (UEFI, SSDs, docks) — `ujust update` applies LVFS firmware; Security Center warns if any is pending and offers a Fix button.
* **Wi-Fi / Bluetooth / printers** — in the kernel and image. Printers via System Settings ▸ Printers (driverless IPP).
What's active: System Settings ▸ About this System, or `inxi -G`.
