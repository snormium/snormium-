# Package management
Snormium is image-based: the system is one signed image that updates atomically; apps come from **Flathub** via the **App Store** (Bazaar).
* The App Store (Bazaar) installs Flatpak apps; `ujust update` (Welcome ▸ Update) updates the system image, Flatpaks and firmware together.
* Need a command-line tool or something not on Flathub? `brew install <tool>` (Homebrew is built in) or a Distrobox container
  (`ujust distrobox`) — neither touches the system image.
* Layering RPMs onto the image (`rpm-ostree install`) works but slows updates; prefer the options above.
* No PPAs, no curl-pipe installers. Emulators that exist only as AppImages are fetched with pinned checksums
  (`snormium-app-fetch`), never blindly.
