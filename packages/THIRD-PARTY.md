# Third-party source evaluation

Every source outside Linux Mint / Ubuntu repositories, with why it's needed and how it's kept safe.

| Source | Used for | Trust basis | Verification | Update path | Fallback |
|--------|----------|-------------|--------------|-------------|----------|
| **Flathub** (dl.flathub.org) | Discord, ProtonUp-Qt, RetroArch, Azahar, PCSX2, RPCS3, DuckStation, melonDS, Flycast, PPSSPP, Heroic, Lutris, Bottles, Protontricks, OBS, Krita, Blender, Kdenlive, Flatseal | Already a default remote on Linux Mint; OSTree commits GPG-signed by Flathub; apps sandboxed (bubblewrap) | `flatpak` verifies repo signature on every pull | Automatic via Mint Update Manager (Flatpak tab) | apt where a package exists (retroarch, lutris, obs-studio, krita, blender, kdenlive) |
| **libretro buildbot** (buildbot.libretro.com) | RetroArch cores | Upstream's only distribution channel; RetroArch's core updater is what the project supports | RetroArch checks cores against its `.index-extended` list; **no** GPG. Accepted risk, same as every RetroArch install. Cores run inside RetroArch's Flatpak sandbox | RetroArch > Online Updater | Ubuntu `libretro-*` packages (older) |
| **Eden** (github.com/eden-emulator/Releases) | Nintendo Switch emulator (AppImage) | GPL-3 project, active fork of yuzu; not on Flathub/apt | SHA256 pinned in `appimage.list` by a maintainer per release; fetch refuses unpinned hashes | `scripts/update-appimages.sh` proposes new pins; human reviews | none (user can install manually) |
| **ES-DE** (gitlab.com/es-de) | Emulation frontend (AppImage) | MIT, official distribution is AppImage | SHA256 pinned | same | RetroArch's own playlists |
| **Steam ROM Manager** (github.com/SteamGridDB) | Add emulated games to Steam (AppImage) | MIT, official AppImage | SHA256 pinned | same | manual "Add non-Steam game" |
| **Steam** (repo.steampowered.com via Ubuntu `steam-installer`) | Steam client | Ubuntu multiverse bootstrapper; Steam self-updates over TLS from Valve | Ubuntu package signature | Steam self-update | — |
| **Intel media driver** (`intel-media-va-driver-non-free`, multiverse) | VA-API on Intel Gen8+ | Ubuntu multiverse, Intel-published | Ubuntu package signature | apt | `intel-media-va-driver` (free, older) |
| **mint-meta-codecs** | Codecs, MS core fonts | Linux Mint repository | Mint package signature | apt | — |

Explicitly **not** used: PPAs, Wine's WineHQ repo (Ubuntu's wine 9 + Wine-GE via ProtonUp-Qt is enough),
curl-pipe-to-shell installers of any kind, Snap.
