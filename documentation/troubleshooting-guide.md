# Troubleshooting
| Symptom | Try |
|---------|-----|
| Game won't start under Proton | Right-click ▸ Properties ▸ Compatibility ▸ GE-Proton; check ProtonDB |
| No sound in a game | Sound settings ▸ output device; in-game audio device; `pavucontrol` per-app |
| USB audio interface has no inputs | Sound settings ▸ profile *Pro Audio*; qpwgraph shows all channels |
| Controller works in Steam but not emulator | Disable Steam Input for that game, or run the emulator outside Steam |
| Screen tearing | Display settings ▸ VRR/compositing; for games use Gamescope or fullscreen |
| Bluetooth pad won't pair | Remove old pairing, hold pair button 3 s, try again; update pad firmware |
| Security Center shows "Firmware update available" | Update Manager ▸ Firmware tab |
| "Restart needed" every day | Normal after kernel/system-library updates; restart when convenient |
Logs for advanced users: `journalctl -b -p err`, `/var/log/unattended-upgrades/`, Steam: `~/.steam/steam/logs`.
