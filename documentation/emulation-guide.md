# Emulation guide
Snormium ships emulators, **never** games, BIOS files, firmware or keys. You must own the original hardware/games and dump
them yourself; see each emulator's site for how.
## Setup
Welcome ▸ **Emulation setup** installs the emulators (Flatpak), writes RetroArch defaults, and creates
`~/Games/Emulation/` with `roms/<system>/`, `bios/`, `saves/`, `states/`, `screenshots/`. Then in RetroArch:
*Main Menu ▸ Online Updater ▸ Core Downloader* and install the cores listed in `snormium-cores.txt` (one per system; see
the table below).
## Where files go
| System | Emulator | ROM folder | BIOS / firmware (your own dumps) |
|--------|----------|------------|-----------------------------------|
| Atari 2600/7800/Lynx, NES, SNES, GB/GBC/GBA, N64, Master System, Genesis, 32X, PC Engine | RetroArch | `roms/<system>` | GBA: `bios/gba_bios.bin` (optional); Lynx: `bios/lynxboot.img` |
| Sega CD | RetroArch (Genesis Plus GX) | `roms/segacd` | `bios/bios_CD_U.bin`, `bios_CD_E.bin`, `bios_CD_J.bin` |
| Saturn | RetroArch (Beetle Saturn) | `roms/saturn` | `bios/sega_101.bin`, `bios/mpr-17933.bin` |
| Neo Geo / Arcade | RetroArch (FBNeo) | `roms/neogeo`, `roms/arcade` | `roms/neogeo/neogeo.zip` (BIOS ROM set) |
| PlayStation | DuckStation | `roms/psx` | `bios/scph5501.bin` etc. (point DuckStation at `bios/`) |
| PlayStation 2 | PCSX2 | `roms/ps2` | `bios/` (PCSX2 ▸ Settings ▸ BIOS ▸ folder) |
| PlayStation 3 | RPCS3 | `roms/ps3` | PS3 firmware `PS3UPDAT.PUP` from Sony's site — install via RPCS3 ▸ File ▸ Install Firmware |
| PSP | PPSSPP | `roms/psp` | none |
| Dreamcast | Flycast | `roms/dreamcast` | `bios/dc/dc_boot.bin`, `dc_flash.bin` |
| GameCube / Wii | Dolphin | `roms/gc`, `roms/wii` | none (optional IPL) |
| DS | melonDS | `roms/nds` | `bios/bios7.bin`, `bios9.bin`, `firmware.bin` (optional; free BIOS built in) |
| 3DS | Azahar | `roms/3ds` | none for decrypted dumps; Azahar ▸ Help for key/dump instructions |
| Switch | Eden | `roms/switch` | `prod.keys` + firmware **from your own console** into Eden's keys folder (Eden shows the path) |
## Frontend
**ES-DE** scans the folders above and launches everything from a controller-friendly library (installed by Emulation Setup once its release checksum is pinned).
**Steam ROM Manager** adds games to Steam with artwork, if you prefer Big Picture. Eden/ES-DE/SRM are AppImages fetched only
when a maintainer has pinned their checksum; otherwise the Welcome buttons explain how to install manually.
## Graphics
RetroArch defaults: Vulkan, VSync on, auto frame delay, ozone menu. Shaders: Quick Menu ▸ Shaders (CRT-Royale, crt-geom…).
Integer scaling: Settings ▸ Video ▸ Scaling. Standalone emulators default to Vulkan where available.
