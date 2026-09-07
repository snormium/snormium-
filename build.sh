#!/usr/bin/env bash
# =====================================================================================
#  Snormium 2.0 one-shot ISO builder — run on a fresh Linux Mint 22 / Ubuntu 24.04 / Fedora VM.
#  Put in ~/Downloads:  snormium2-*-source.tar.gz (+ .sha256)   and optional art:
#    logo.svg|logo.png  wallpaper.png|.jpg  other *.png/*.jpg  plymouth-background.png
#  Then:  bash ~/Downloads/build.sh          Options: --nvidia  --no-art  --prepare  --iso-only
#  Needs: ~40 GB free, >=8 GB RAM (12 GB recommended), internet (pulls ~8 GB Bazzite image), 30-60 min. No KVM required.
# =====================================================================================
set -Eeuo pipefail
DL="${DL:-$HOME/Downloads}"; WORK="${WORK:-$HOME/snormium2-build}"; NV=no; ART=yes; PREP=no; ISO_ONLY=no
for a in "$@"; do case $a in --nvidia) NV=yes;; --no-art) ART=no;; --prepare) PREP=yes;; --iso-only) ISO_ONLY=yes;; --skip-test) :;; -h|--help) sed -n '2,8p' "$0"; exit 0;; *) echo "unknown option: $a" >&2; exit 2;; esac; done
B=$'\e[1;35m'; G=$'\e[32m'; Y=$'\e[33m'; R=$'\e[31m'; N=$'\e[0m'
say() { echo "${B}==>${N} $*"; }; ok() { echo "${G} ✓${N} $*"; }; warn() { echo "${Y} !${N} $*"; }; die() { echo "${R} ✗ $*${N}"; exit 1; }
[[ $EUID -ne 0 ]] || die "Run as your normal user."
[[ "$(uname -m)" == x86_64 ]] || die "x86_64 host required."

say "1/5  Installing tools"
if [[ $PREP == no ]]; then
  if command -v apt-get >/dev/null; then
    sudo apt-get update -q; sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -q podman just shellcheck python3 python3-pil curl librsvg2-bin cpio xorriso isomd5sum qemu-system-x86 ovmf
  elif command -v dnf >/dev/null; then sudo dnf install -y podman just ShellCheck python3 python3-pillow curl librsvg2-tools cpio xorriso isomd5sum qemu-kvm edk2-ovmf; fi
  command -v just >/dev/null || { warn "just not packaged here; installing from GitHub release"; curl -fsSL https://just.systems/install.sh | bash -s -- --to ~/.local/bin; export PATH="$HOME/.local/bin:$PATH"; }
fi
ok "tools ready"

say "2/5  Unpacking source"
src=$(ls -t "$DL"/snormium2-*-source.tar.gz 2>/dev/null | head -1) || true; [[ -n "$src" ]] || die "No snormium2-*-source.tar.gz in $DL"
[[ -f "$src.sha256" ]] && { (cd "$DL" && sha256sum -c --quiet "$(basename "$src").sha256") && ok "source checksum OK" || die "source checksum FAILED"; }
mkdir -p "$WORK"; tar xzf "$src" -C "$WORK"; SRC="$WORK/snormium2"; [[ -f "$SRC/Containerfile" ]] || die "bad archive"

say "3/5  Importing art from $DL"
CUST="$SRC/branding/custom"; mkdir -p "$CUST"; n=0
if [[ $ART == yes ]]; then
  for f in "$DL"/*; do [[ -f $f ]] || continue; b=$(basename "$f"); lb=${b,,}
    case "$lb" in logo.svg|logo.png|wallpaper.png|wallpaper.jpg|wallpaper.jpeg|plymouth-background.png|*.png|*.jpg|*.jpeg) ;; *) continue ;; esac
    if [[ $lb != *.svg ]] && ! python3 -c "from PIL import Image; Image.open('$f').verify()" 2>/dev/null; then warn "skipping non-image $b"; continue; fi
    cp "$f" "$CUST/$lb"; ((n++)) || true
  done
fi
[[ $n -gt 0 ]] && ok "$n art file(s) imported" || warn "no custom art — using Snormium's generated art"

say "4/5  Static checks"; (cd "$SRC" && ./testing/lint.sh) || die "lint failed"
[[ $PREP == yes ]] && { ok "--prepare done: $SRC"; exit 0; }

say "5/5  Building image + ISO (this pulls Bazzite, ~8 GB)"
free_gb=$(df -BG --output=avail "$WORK" | tail -1 | tr -dc 0-9); [[ ${free_gb:-0} -ge 40 ]] || die "Need ≥40 GB free (have ${free_gb}G)"
mem_mb=$(awk '/MemTotal/{printf "%d", $2/1024}' /proc/meminfo); [[ $mem_mb -ge 7500 ]] || warn "RAM ${mem_mb} MB is below the 8 GB minimum; dracut and squashfs will be slow"
# nothing large is written to /tmp (RAM tmpfs) — Justfile keeps all ISO scratch under $PWD
cd "$SRC"
if [[ $ISO_ONLY == no ]]; then if [[ $NV == yes ]]; then just build-nvidia; else just build; fi; fi
img="localhost/snormium:latest"; [[ $NV == yes ]] && img="localhost/snormium-nvidia:latest"
just audit "$img"
just build-iso "$img"
mkdir -p "$DL/snormium2-iso"; cp output/*.iso output/*.sha256 "$DL/snormium2-iso/"; cp output/RELEASE.json "$DL/snormium2-iso/" 2>/dev/null || true
ok "ISO: $(find "$DL/snormium2-iso" -name "*.iso" | head -1)"; cat "$DL"/snormium2-iso/*.sha256
echo "  Write with Rufus (DD mode) / balenaEtcher, boot with Secure Boot ON (enrol the Universal Blue key when asked on first boot)."
