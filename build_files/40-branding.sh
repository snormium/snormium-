#!/usr/bin/env bash
# Snormium identity: os-release, wallpapers (custom drop-ins win), logo PNGs, Plymouth, SDDM, Plasma look-and-feel.
set -Eeuo pipefail
CUST=/ctx/branding/custom; WP=/usr/share/backgrounds/snormium; mkdir -p "$WP"
shopt -s nullglob; cwp=("$CUST"/*.png "$CUST"/*.jpg "$CUST"/*.jpeg); shopt -u nullglob
cwp=("${cwp[@]/*plymouth-background*/}"); cwp=("${cwp[@]/*logo*/}")
if [[ -n "${cwp[*]// /}" ]]; then
  for f in "${cwp[@]}"; do [[ -n $f ]] && cp "$f" "$WP/"; done
  if [[ -f $CUST/wallpaper.png ]]; then DEF=wallpaper.png; elif [[ -f $CUST/wallpaper.jpg ]]; then DEF=wallpaper.jpg; else DEF=$(ls "$WP" | head -1); fi
else
  python3 /ctx/branding/wallpapers/generate.py "$WP" 3840 2160; DEF=snormium-nucleus.png
fi
LOGO=/ctx/branding/snormium-logo.svg; [[ -f $CUST/logo.svg ]] && LOGO=$CUST/logo.svg
for n in snormium-logo snormium-security snormium-recovery snormium-emulation snormium-logo-symbolic; do cp "$LOGO" "/usr/share/icons/hicolor/scalable/apps/$n.svg"; done
rsvg-convert -w 160 "$LOGO" -o /usr/share/plymouth/themes/snormium/logo.png
rsvg-convert -w 256 "$LOGO" -o /usr/share/snormium/snormium-logo-256.png
python3 - <<'PY'
from PIL import Image; Image.new("RGB",(4,4),(139,92,246)).save("/usr/share/plymouth/themes/snormium/bar.png")
PY
[[ -f $CUST/plymouth-background.png ]] && cp "$CUST/plymouth-background.png" /usr/share/plymouth/themes/snormium/background.png
# Wallpaper references
LNF=/usr/share/plasma/look-and-feel/org.snormium.desktop
LOCK="$WP/snormium-calm.png"; [[ -f "$LOCK" ]] || LOCK="$WP/$DEF"
sed -i "s|@WALLPAPER@|$WP/$DEF|g; s|@LOCKWALLPAPER@|$LOCK|g" "$LNF/contents/defaults"
# Login screen: Bazzite uses Plasma Login Manager (plasmalogin) since 2026-09; older bases used SDDM. Brand whichever
# exists and FAIL if neither does — a branding step must never "succeed" by editing a file nothing reads (build 5, 9.1).
if [[ -x /usr/bin/plasmalogin || -f /usr/lib/systemd/system/plasmalogin.service ]]; then
  sed -i "s|@LOCKWALLPAPER@|$LOCK|g" /usr/lib/plasmalogin/plasmalogin.conf.d/90-snormium.conf
  rm -rf /usr/share/sddm /etc/sddm.conf.d   # our SDDM files are dead on this base; do not ship them
  echo "login screen: plasmalogin branded ($LOCK)"
elif [[ -d /usr/share/sddm/themes/breeze ]]; then
  printf '[General]\nbackground=%s\ntype=image\n' "$LOCK" > /usr/share/sddm/themes/breeze/theme.conf.user
  mkdir -p /etc/sddm.conf.d; printf '[Theme]\nCurrent=breeze\n' > /etc/sddm.conf.d/10-snormium.conf
  rm -rf /usr/lib/plasmalogin
  echo "login screen: sddm branded ($LOCK)"
else
  echo "no display manager found to brand (neither plasmalogin nor sddm)"; exit 1
fi
mkdir -p "$LNF/contents/splash/images" "$LNF/contents/previews"
rsvg-convert -w 160 "$LOGO" -o "$LNF/contents/splash/images/logo.png"
python3 - "$WP/$DEF" "$LNF/contents/previews" <<'PY'
import sys; from PIL import Image
im=Image.open(sys.argv[1]).convert("RGB"); im.resize((800,450)).save(sys.argv[2]+"/preview.png"); im.resize((800,450)).save(sys.argv[2]+"/fullscreenpreview.jpg")
im.resize((800,450)).save(sys.argv[2]+"/splash.png"); im.resize((800,450)).save(sys.argv[2]+"/lockscreen.png")
PY
ln -sf "/usr/share/backgrounds/snormium/$DEF" /usr/share/backgrounds/default.png
# Plymouth: set our theme, and replace the spinner theme's watermark (Bazzite's wordmark) so even the fallback is ours.
plymouth-set-default-theme snormium
for wm in /usr/share/plymouth/themes/spinner/watermark.png /usr/share/plymouth/themes/bgrt/watermark.png; do
  [[ -e "$wm" ]] && rsvg-convert -w 200 "$LOGO" -o "$wm"
done
# The boot splash is rendered from the INITRAMFS, which Bazzite built with the spinner theme before we existed.
# Regenerate it the way Universal Blue does (ublue-os/main build_files/initramfs.sh), with two container-build fixes:
#  * /root -> /var/roothome is a DANGLING symlink in the published Bazzite image (their cleanup removes the target);
#    dracut-install then fails with "ERROR: installing '/root'" and leaves a half-built initramfs. Create it for the run.
#  * DRACUT_NO_XATTR=1: overlayfs cannot copy xattrs; without this dracut prints thousands of harmless warnings.
KVER=$(rpm -q --queryformat="%{evr}.%{arch}" kernel-core 2>/dev/null || ls /usr/lib/modules | sort -V | tail -1)
[[ -d /usr/lib/modules/$KVER ]] || { echo "kernel $KVER not found in /usr/lib/modules"; exit 1; }
made_roothome=no; [[ -e /var/roothome ]] || { mkdir -p /var/roothome; made_roothome=yes; }
export DRACUT_NO_XATTR=1
dracut --no-hostonly --kver "$KVER" --reproducible --zstd --add "ostree plymouth" \
       -i /usr/share/plymouth/themes/snormium /usr/share/plymouth/themes/snormium \
       -f "/usr/lib/modules/$KVER/initramfs.img" 2>&1 | grep -vE "^dracut-install: Failed to copy xattr" | tail -n 40
rc=${PIPESTATUS[0]}; [[ $rc -eq 0 ]] || { echo "dracut exited $rc"; exit 1; }
[[ $made_roothome == yes ]] && rmdir /var/roothome 2>/dev/null || true
chmod 0600 "/usr/lib/modules/$KVER/initramfs.img"
# NOTE: never `lsinitrd | grep -q` under pipefail — grep -q closes the pipe on first match, lsinitrd dies of SIGPIPE,
# and the pipeline reports failure for an initramfs that DOES contain the theme (this cost a build on 2026-09-06).
lsinitrd "/usr/lib/modules/$KVER/initramfs.img" > /tmp/initramfs.lst
grep -q "plymouth/themes/snormium/snormium.plymouth" /tmp/initramfs.lst || { echo "initramfs does not contain the Snormium plymouth theme"; exit 1; }
grep -qE "plymouth/(script|label)[^/]*\.so" /tmp/initramfs.lst || echo "WARN: plymouth script/label plugins not found in initramfs; splash may fall back to text"
rm -f /tmp/initramfs.lst
echo "initramfs rebuilt for $KVER with Snormium plymouth theme"
# os-release (bootc keeps it in /usr/lib/os-release; /etc/os-release is a symlink)
# VERSION_ID MUST stay the *Fedora* release, not Snormium's product version: bootc-image-builder picks its distro
# definition by "<ID>-<VERSION_ID>"; VERSION_ID=2.0 made every ISO build die with "could not find def file for distro
# snormium-2.0". Bazzite does the same (VERSION="44.x (Kinoite)", VERSION_ID=44). Do not "fix" this.
FEDORA_RELEASE="$(rpm -E %fedora)"
cat > /usr/lib/os-release <<EOR
NAME="${DISTRO_NAME}"
VERSION="${DISTRO_VERSION} (${DISTRO_CODENAME}, Fedora ${FEDORA_RELEASE})"
ID=snormium
ID_LIKE="fedora"
VERSION_ID=${FEDORA_RELEASE}
VARIANT="${DISTRO_CODENAME}"
VARIANT_ID=snormium
VERSION_CODENAME="${DISTRO_CODENAME}"
PRETTY_NAME="${DISTRO_NAME} ${DISTRO_VERSION} (based on Bazzite)"
ANSI_COLOR="1;35"
LOGO=snormium-logo
HOME_URL="${DISTRO_HOME_URL}"
SUPPORT_URL="${DISTRO_HOME_URL}/support"
BUG_REPORT_URL="${DISTRO_HOME_URL}/issues"
OSTREE_VERSION="${DISTRO_VERSION}"
IMAGE_ID="${IMAGE_NAME}-${FEDORA_RELEASE}"
IMAGE_VERSION="${DISTRO_VERSION}"
EOR
# bootc/ublue image-info consumed by ujust/uupd
mkdir -p /usr/share/ublue-os; cat > /usr/share/ublue-os/image-info.json <<EOJ
{"image-name":"${IMAGE_NAME}","image-vendor":"snormium","image-ref":"ostree-image-signed:docker://ghcr.io/snormium/${IMAGE_NAME}","image-tag":"latest","base-image-name":"bazzite","fedora-version":"${FEDORA_RELEASE}"}
EOJ
gtk-update-icon-cache -q /usr/share/icons/hicolor || true
