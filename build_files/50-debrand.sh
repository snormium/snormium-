#!/usr/bin/env bash
# Remove Bazzite / Steam Deck *artwork* (Vapor/VGUI look-and-feel, wallpapers, colour schemes, avatars, logos) while
# keeping every functional Bazzite component and every RPM. Then audit.
set -Eeuo pipefail
read_list() { grep -vE '^\s*(#|$)' "$1" | awk '{print $1}'; }
mapfile -t rm < <(read_list /ctx/packages/debrand-remove.list)
for p in "${rm[@]}"; do
  rpm -q "$p" >/dev/null 2>&1 || continue
  dnf5 -y remove "$p" 2>/dev/null || { echo "  ! $p is required by another package — scrubbing its assets instead"; }
done
# Valve artwork owned by steamdeck-kde-presets-desktop (package is KEPT: it also provides steamos-add-to-steam)
rm -rf /usr/share/color-schemes/Vapor.colors /usr/share/color-schemes/VGUI.colors /usr/share/konsole/Vapor.* \
       /usr/share/plasma/avatars/Portal2 /usr/share/plasma/avatars/tf2 2>/dev/null || true
# Plasma Login Manager: if Bazzite ships its own greeter wallpaper default, override it (ours loads later, higher number)
if [[ -f /usr/lib/plasmalogin/defaults.conf ]] && grep -qiE "vapor|bazzite|steamdeck" /usr/lib/plasmalogin/defaults.conf; then
  sed -i -E '/^Image=.*(vapor|bazzite|steamdeck)/Id' /usr/lib/plasmalogin/defaults.conf
fi
# Asset paths that survive as unowned files
rm -rf /usr/share/wallpapers/{Vapor,VGUI,convergence*,bazzite*} /usr/share/backgrounds/bazzite* /usr/share/backgrounds/default*.jxl \
       /usr/share/plasma/look-and-feel/com.valve.* /usr/share/plasma/look-and-feel/org.bazzite* /usr/share/sddm/themes/steamdeck* \
       /usr/share/plymouth/themes/bazzite* /usr/share/pixmaps/bazzite* \
       /usr/share/kde-settings/kde-profile/default/share/wallpapers/* 2>/dev/null || true
# Icon/wallpaper artwork does not live under a predictable */apps/ path: Bazzite ships bazzite-logo-icon.png straight in
# /usr/share/icons/hicolor/<size>/, logos in .../scalable/places/, and papirus-icon-theme ships steamdeck-gaming-return.svg.
# Sweep the same four trees with the same name patterns the audit checks, so removal and audit cannot drift apart.
find /usr/share/icons /usr/share/pixmaps /usr/share/wallpapers /usr/share/backgrounds -not -path '*/Papirus*' \
     \( -iname '*bazzite*' -o -iname '*vapor*' -o -iname '*vgui*' -o -iname '*steamdeck*' \) \
     -exec rm -rf {} + 2>/dev/null || true
# steamdeck-kde-presets-desktop (kept installed) owns /etc/xdg/kscreenlockerrc; re-assert ours over it. rpm -V will
# report the file as modified — intended.
cp -f /ctx/system_files/etc/xdg/kscreenlockerrc /etc/xdg/kscreenlockerrc
# Bazzite has no list-driven Flatpak preinstall today; if a future base adds one, keep Snormium in control of its own list.
rm -f /etc/ublue-os/system-flatpaks.list
# Plasma default look-and-feel → Snormium (global default file used for new users)
mkdir -p /etc/xdg; cat > /etc/xdg/kdeglobals <<'EOK'
[KDE]
LookAndFeelPackage=org.snormium.desktop
[General]
ColorScheme=Snormium
AccentColor=139,92,246
[Icons]
Theme=Papirus-Dark
EOK
# Strings in user-visible desktop entries (functional ujust/uupd scripts keep their internal names)
mapfile -t hits < <(grep -rIls "Bazzite" /usr/share/applications /etc/xdg/autostart 2>/dev/null || true)
[[ ${#hits[@]} -gt 0 ]] && sed -i "s/Bazzite/${DISTRO_NAME}/g" "${hits[@]}"
gtk-update-icon-cache -q -f /usr/share/icons/hicolor 2>/dev/null || true
bash /ctx/system_files/usr/libexec/snormium/audit-bazzite-assets.sh /
