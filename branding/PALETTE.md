# Snormium visual identity

**Name:** Snormium — a fictional element ("a stable element for your computer"). Version 1.0 codename *Nucleus*.
**Motif:** a crystalline hexagonal element tile with a stylised nucleus and one electron orbit. Violet + ion-cyan on
near-black. Deliberately nothing green, no leaves, no rings-in-a-shield — zero visual overlap with Linux Mint.

| Token             | Hex       | Use |
|-------------------|-----------|-----|
| snormium-void     | `#12101C` | backgrounds, Plymouth, greeter |
| snormium-slate    | `#221F35` | panels, headers, hero cards |
| snormium-violet   | `#8B5CF6` | primary accent (selection, switches, links) |
| snormium-ion      | `#22D3EE` | secondary accent (orbit, highlights) |
| snormium-amber    | `#F5B041` | warnings / "action recommended" |
| snormium-mist     | `#ECEAF6` | light text, light-theme background |
| snormium-green    | `#2FBF71` | "protected" |
| snormium-red      | `#E5484D` | "action required" |

Fonts: Ubuntu / Ubuntu Mono. Icons: Papirus-Dark (GPL-3). Cursor: DMZ-White.
GTK/Cinnamon themes `Snormium-Dark` / `Snormium-Light` are generated at build time from Mint-Y sources (GPL-3) with the
accent replaced, **after which the Mint theme/icon/artwork packages are purged** so no Mint asset ships in the image
(`scripts/03-apply-chroot.sh` stage `debrand` + `testing/audit-mint-assets.sh`).

Trademark note: "Linux Mint" is a trademark of Linux Mint. Snormium ships no Mint logos or artwork; the phrase
"based on Linux Mint" appears only in /etc/os-release and About as a factual statement.

## Desktop rice (2.0)
Global theme `org.snormium.desktop` (`system_files/usr/share/plasma/look-and-feel/`): colour scheme **Snormium** (void/slate
surfaces, violet accent, ion links), Breeze widgets/decorations with no borders, blur + translucency, one floating translucent
bottom panel (hexagon launcher, icon tasks, tray, clock), Inter + JetBrains Mono, KSplash with logo and violet progress bar, lock
and login on the *calm* wallpaper, Konsole profile + colour scheme, fastfetch with the hex logo. Applied to new accounts via the
LnF defaults and once per user by `snormium-firstlogin` (so accounts created by the installer get it too).
