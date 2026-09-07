# Developer / build guide
## Build host
Linux Mint 22.x or Ubuntu 24.04, 25 GB free, root. `sudo apt install squashfs-tools xorriso isolinux rsync gpg
python3-pil librsvg2-bin ovmf qemu-system-x86 shellcheck desktop-file-utils`.
## Build
```
git clone <repo> snormium-os && cd snormium-os
make lint          # static checks, runs anywhere
sudo make          # 00 host check → 01 fetch+verify Mint ISO → 02 extract → 03 apply → 04 ISO → 05 validate → 06 release
make vm-test       # QEMU UEFI boot;  testing/vm-test.sh --bios ;  --install adds a test disk
```
Re-run a single stage: `sudo scripts/03-apply-chroot.sh security` (stages: packages security gaming emulation desktop branding debrand cleanup).
Everything is driven by `build.conf`; override with env vars (`MINT_VERSION=22.3 sudo make`).
## Layout
`packages/` manifests · `configs/` dropped into the chroot verbatim (path documented at top of each) · `security/ desktop/
recovery/ applications/ emulation/` our apps (Python 3 + GTK 3, bash helpers behind polkit) · `branding/` generated
theme/wallpapers/plymouth · `installer/` Ubiquity notes · `testing/` lint, VM harness, checklist, hardware matrix.
## Principles
Never edit an upstream file in place when a drop-in directory exists (`*.d/`). Every privileged action is a fixed
sub-command of a helper behind a polkit action. New third-party sources need a row in `packages/sources/THIRD-PARTY.md`.
Update AppImage pins with `scripts/update-appimages.sh` (to be written; see STATUS.md) and review the diff.
## Testing
`testing/CHECKLIST.md` is the release gate; results go in `testing/HARDWARE-MATRIX.md`. Nothing is claimed working
without a row there.
## Debranding
Stage `debrand` purges `packages/debrand-purge.list` **after** `branding` generated Snormium-Dark/Light from Mint-Y, scrubs
leftover paths, patches the Cinnamon menu icon default and Ubiquity's desktop entry, installs our slideshow, then runs
`testing/audit-mint-assets.sh` and aborts the build if anything Mint-branded remains. If purging a package fails because
a Mint metapackage hard-depends on it, create an `equivs` dummy providing that name (add to `packages/`) so apt stays consistent.
