#!/usr/bin/env bash
# Build images/product.img for the installer ISO: an overlay Anaconda applies at boot. Replaces Fedora's sidebar
# logo/background and top bar with Snormium's. Runs on the BUILD HOST (needs rsvg-convert, python3-pillow, cpio).
# Usage: make-product-img.sh <out product.img> [logo.svg]
set -Eeuo pipefail
out="${1:?output path}"; here="$(cd "$(dirname "$0")" && pwd)"; logo="${2:-$here/sidebar-logo.svg}"
t=$(mktemp -d); trap 'rm -rf "$t"' EXIT
px="$t/root/usr/share/anaconda/pixmaps"; mkdir -p "$px"
rsvg-convert -w 260 "$logo" -o "$px/sidebar-logo.png"
python3 - "$px" <<'PY'
import sys; from PIL import Image
px=sys.argv[1]; VOID,SLATE,VIOLET=(18,16,28),(34,31,53),(139,92,246)
bg=Image.new("RGB",(1,1200)); p=bg.load()
for y in range(1200): p[0,y]=tuple(int(VOID[i]+(SLATE[i]-VOID[i])*(y/1200)**1.5) for i in range(3))
bg.save(px+"/sidebar-bg.png")
Image.new("RGB",(1,1),SLATE).save(px+"/topbar-bg.png")
# accent used by the hub's "spoke" highlight in older anaconda themes
Image.new("RGB",(1,1),VIOLET).save(px+"/sidebar-accent.png")
PY
# Anaconda's GTK theme reads these names; keep Fedora's file set so nothing 404s
( cd "$t/root" && find . | cpio -o -H newc --quiet ) | gzip -9 > "$out"
echo "product.img: $(du -h "$out" | cut -f1) ($(gzip -dc "$out" | cpio -t --quiet | wc -l) files)"
