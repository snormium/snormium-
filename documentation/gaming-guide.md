# Gaming guide
* **Steam** is preinstalled. Steam ▸ Settings ▸ Compatibility ▸ *Enable Steam Play for all other titles* is on by default
  in recent Steam clients; if not, tick it. Windows games then run through **Proton** automatically.
* **Proton-GE / Wine-GE** (extra codecs, fixes): Welcome ▸ *Set up Proton-GE*, click Add, pick GE-Proton. In Steam, right-click a
  game ▸ Properties ▸ Compatibility ▸ choose GE-Proton.
* **Epic / GOG / Amazon**: Heroic — sign in, install, play; it manages Proton-GE itself. **Ubisoft Connect, EA App, Battle.net,
  Rockstar**: Lutris — search the launcher's name inside Lutris and run its install script, then sign in as on Windows.
  **Anything else**: Bottles. All are installed by default (Flatpak).
* **GameMode** is no longer shipped by Bazzite (its priority tweaks are covered by Gamescope and the kernel's scheduler); `gamemoderun` in launch options can simply be removed.
* **MangoHud** overlay: Right Shift + F12 in any Vulkan/OpenGL game. Welcome ▸ *Performance overlay* makes it default-on.
* **Gamescope** is built in: in Steam, add `gamescope -W 2560 -H 1440 -r 144 --hdr-enabled -- %command%` to a game's launch options,
  or use Bazzite's *Gaming Mode* session (`ujust enable-gaming-mode` on desktops) for a Steam-Deck-style full-screen experience.
* **HDR** works on the desktop (Wayland): System Settings ▸ Display ▸ HDR, on a supported monitor.
* **VRR / high refresh**: System Settings ▸ Display. Multi-monitor VRR on X11 works with the monitor the game is fullscreen on.
* Anti-cheat: EAC/BattlEye work when the game's publisher enabled Linux support; nothing in Snormium blocks them.
* NVIDIA: use the `snormium-nvidia` image; nothing to install. AMD/Intel: nothing to install.
