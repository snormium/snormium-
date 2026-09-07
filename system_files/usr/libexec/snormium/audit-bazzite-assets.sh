#!/usr/bin/env bash
# Fails if user-visible Bazzite/Steam-Deck artwork survives. Functional Bazzite tooling (ujust, uupd, /usr/share/ublue-os)
# is allowed by design. Usage: audit-bazzite-assets.sh <root>
set -Eeuo pipefail; R="${1:-/}"; bad=0; say() { echo "  ! $1"; bad=1; }
for path in usr/share/wallpapers/Vapor usr/share/wallpapers/VGUI usr/share/plasma/look-and-feel/com.valve.vapor.desktop usr/share/plasma/look-and-feel/com.valve.vgui.desktop \
            usr/share/sddm/themes/steamdeck usr/share/backgrounds/bazzite usr/share/plymouth/themes/bazzite \
            usr/share/color-schemes/Vapor.colors usr/share/color-schemes/VGUI.colors usr/share/konsole/Vapor.profile \
            usr/share/plasma/avatars/Portal2 usr/share/plasma/avatars/tf2; do
  [[ -e "$R/$path" ]] && say "asset present: /$path"
done
while read -r f; do [[ -n $f ]] && say "logo-like file: $f"; done < <(find "$R/usr/share/icons" "$R/usr/share/pixmaps" "$R/usr/share/wallpapers" "$R/usr/share/backgrounds" -not -path '*/Papirus*' \( -iname '*bazzite*' -o -iname '*vapor*' -o -iname '*vgui*' -o -iname '*steamdeck*' \) 2>/dev/null | sed "s|^$R/*|/|" || true)
# Login screen must be branded for the display manager that actually exists
if [[ -f "$R/usr/lib/systemd/system/plasmalogin.service" ]]; then
  c="$R/usr/lib/plasmalogin/plasmalogin.conf.d/90-snormium.conf"
  img=$(sed -n 's|^Image=file://||p' "$c" 2>/dev/null | head -1)
  [[ -n "$img" && -f "$R/$img" ]] || say "plasmalogin greeter wallpaper not configured or missing ($img)"
  grep -rqsiE "vapor|bazzite|steamdeck" "$R/usr/lib/plasmalogin" "$R/etc/plasmalogin.conf" 2>/dev/null && say "plasmalogin config still references Bazzite/Valve theming"
elif [[ -d "$R/usr/share/sddm" ]]; then
  grep -qs "backgrounds/snormium" "$R/usr/share/sddm/themes/breeze/theme.conf.user" 2>/dev/null || say "sddm greeter not branded"
else say "no display manager config found"; fi
# SELinux: helpers systemd/pkexec execute must resolve to bin_t under the image's own policy (ls -Z in a container is meaningless)
if [[ "$R" == "/" ]] && command -v matchpathcon >/dev/null 2>&1; then
  for f in /usr/libexec/snormium/*; do matchpathcon "$f" 2>/dev/null | grep -q ':bin_t:' || say "SELinux: $f would not be bin_t"; done
fi
# Every desktop launcher we ship must point at something that exists in the image
for d in "$R"/usr/share/snormium/desktop-icons/*.desktop; do
  ex=$(sed -n 's/^Exec=//p' "$d" | awk '{print $1}')
  case "$ex" in flatpak|xdg-open|konsole|systemsettings) continue ;; esac
  [[ -x "$R/usr/bin/$ex" || -x "$R/usr/sbin/$ex" || -x "$R/usr/libexec/$ex" ]] || say "desktop launcher $(basename "$d") runs '$ex' which is not in the image"
done
grep -qs "^LookAndFeelPackage=org.snormium.desktop" "$R/etc/xdg/kdeglobals" || say "default look-and-feel is not Snormium"
grep -qs '^NAME="Snormium"' "$R/usr/lib/os-release" || say "os-release NAME is not Snormium"
# plymouth >= 22 records the default theme as Theme= in plymouthd.conf and deletes the legacy default.plymouth symlink.
pt=$(sed -n 's/^[[:blank:]]*Theme[[:blank:]]*=[[:blank:]]*//p' "$R/etc/plymouth/plymouthd.conf" 2>/dev/null | tail -n1)
if [[ -z "$pt" ]]; then pl=$(readlink -e "$R/usr/share/plymouth/themes/default.plymouth" 2>/dev/null || true); [[ -n "$pl" ]] && pt=$(basename "$pl" .plymouth); fi
[[ "$pt" == snormium ]] || say "plymouth default theme is '$pt' (expected snormium)"
# The initramfs is what actually draws the boot splash: it must contain our theme, not just the config.
for ir in "$R"/usr/lib/modules/*/initramfs.img; do
  [[ -f "$ir" ]] || continue
  if command -v lsinitrd >/dev/null; then
    lst=$(mktemp); lsinitrd "$ir" > "$lst" 2>/dev/null || true   # no `| grep -q` under pipefail (SIGPIPE → false failure)
    grep -q "plymouth/themes/snormium/" "$lst" || say "initramfs $(basename "$(dirname "$ir")") lacks the Snormium plymouth theme (boot splash would be Bazzite's)"
    rm -f "$lst"
  fi
done
while read -r f; do [[ -n $f ]] && say "string 'Bazzite' in $f"; done < <(grep -rIls "Bazzite" "$R/usr/share/applications" 2>/dev/null || true)
[[ $bad -eq 0 ]] && { echo "Bazzite asset audit: CLEAN"; exit 0; } || { echo "Bazzite asset audit: FAILED"; exit 1; }
