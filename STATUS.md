# Snormium 2.0 (Bazzite base) — status, 2026-09-04

## First real build (Fedora 44 host VM, 2026-09-03) — ISO PRODUCED
`snormium-latest-x86_64.iso`, 6.27 GB, hybrid UEFI/BIOS Anaconda installer; Bazzite asset audit CLEAN; bootc lint 0 errors.
Five defects found and now fixed in this source: icon/wallpaper removal globs (F1), plymouth audit used the removed
default.plymouth symlink (F2), VERSION_ID must be the Fedora release for bootc-image-builder (F3), bib has no "snormium"
distro definition → registered as a symlink at invocation (F4), bib cannot read the image's file:// GPG keys → keyring
merged in (F5; stock Bazzite fails identically). Also resolved from the report's open issues: **the Flatpak preinstall was a
no-op** (Bazzite has no list-driven installer) → replaced by `snormium-flatpaks.service`, a retrying first-boot installer;
`plasma-firewall` added; dnf state/countme scrubbed from the image; os-release gains VARIANT/VARIANT_ID/IMAGE_ID; stale
`__pycache__` no longer packaged. **Second build (2026-09-04): first try, zero source changes, bootc lint 0 warnings** → ISO `6e52bb88…2573a5`. Follow-ups now in
source: `.containerignore` (podman ignores .gitignore, so bytecode had still shipped), lint no longer writes bytecode, bib base def
resolved at runtime instead of hard-coded `fedora-40.yaml`, explicit removal of any upstream flatpak list, `--skip-test` accepted.
Known cosmetic: ISO volume label is bib's default "Container-Installer-x86_64" (no knob in bib). **FIRST BOOT (VMware, 2026-09-06): ISO boots, Anaconda runs, title "SNORMIUM 44 INSTALLATION"** — but the installer sidebar showed
Fedora art, because bootc-image-builder assembles the Anaconda environment from stock Fedora packages. Added `just brand-iso`
(run automatically by `build-iso`): generates `images/product.img` (Anaconda's overlay mechanism) with Snormium sidebar
logo/background/top bar, injects it with xorriso, re-implants the media MD5. Untested on a real boot; if Anaconda ignores it,
the fallback is repacking install.img. Install itself not yet completed.
**INSTALL COMPLETED, SYSTEM BOOTS (2026-09-06)** — but first boot showed Bazzite's spinner splash: the initramfs (built by Bazzite,
embedded in the base image) carries the plymouth theme, and we only changed the config. Now: initramfs regenerated in the image
build with dracut (ublue's own method), spinner/bgrt watermark replaced with our logo, and the audit inspects the initramfs
with lsinitrd. Needs a full image rebuild.
**Emulators/Flatpaks absent on the installed system (2026-09-06)**: root cause under investigation; most likely SELinux — service
scripts lived in `/usr/lib/snormium` (`lib_t`), which systemd may not execute. All service scripts and pkexec helpers moved to
`/usr/libexec/snormium` (`bin_t`). Resolved: the installer was simply still running — confirmed working on the installed VM (2026-09-06).
**Native-stack guarantee (2026-09-06)**: Snormium no longer removes ANY RPM from Bazzite (steamdeck-kde-presets-desktop is kept;
its Valve artwork is scrubbed file-by-file). New `05-snapshot.sh` + `55-verify-bazzite-stack.sh` fail the build if any base package
is missing afterwards or if steam/gamescope/gamemode/mangohud/ujust/uupd/bootc/... are absent. Package names in the verify list
match the 2026-09-03 base; if Bazzite renames one, the build fails loudly and the list gets updated.
**Product decision 2026-09-06**: Firefox, full codec extensions for Flatpaks, and the entire Creative Studio (GIMP, Krita, Inkscape,
Blender, Kdenlive, OBS + capture plugins, Ardour, Audacity) are now in the `core` tier → installed on first boot (~+4 GB of
downloads; first boot takes longer). Native codecs asserted at build time.
**Build 4 (2026-09-06, clean VM)**: dracut failed with `ERROR: installing '/root'` — /root → /var/roothome is dangling in the
published Bazzite image. Fixed: create /var/roothome for the dracut run, DRACUT_NO_XATTR=1 (as ublue does), theme dir force-included
with `-i`, dracut exit code now checked, xattr noise filtered. **Actual cause of the "does not contain" verdict (found by Claude Code): `lsinitrd | grep -q` under pipefail → SIGPIPE → false failure; the theme was present.** Fixed in 40-branding and both audit copies. Codec WARNs (`mesa-va-drivers`, gstreamer
freeworld) are informational — Bazzite provides equivalents under other names; assertion list to be aligned.
**Build 5 (2026-09-06, clean VM): ISO PRODUCED** `5cab4032…76b4ef`, 6.53 GB, all 12 verifications passed, bootc lint 13/13.
Two in-build fixes folded in: Bazzite renamed gamescope→terra-gamescope, replaced sddm with plasmalogin, dropped gamemode
(55-verify now asserts virtual provides/binaries, warns on gamemode); `brand-iso` scratch moved off the RAM tmpfs.
**Critical finding fixed**: login-screen branding was dead code — Bazzite uses Plasma Login Manager, not SDDM. Now branded via
`/usr/lib/plasmalogin/plasmalogin.conf.d/90-snormium.conf` (`[Greeter][Wallpaper][org.kde.image]`, format read from
plasma-login-manager source), with display-manager detection that FAILS the build if nothing is branded, and an audit check.
Also: codec assertions use `--whatprovides` (no more permanent WARNs), units moved to /usr/lib/systemd/system, lint no longer
writes bytecode, RAM check in build.sh, DISTRO_HOME_URL placeholder now warned by lint. GameMode: dropped by Bazzite upstream;
Welcome/docs still mention it — Gamescope covers the role. Untested on boot: plasmalogin greeter wallpaper.
**Build 6 (2026-09-06, clean snapshot): first try, ZERO source changes, 12/12 verifications** → ISO `9cc290f0…2726b2`.
Reviewer findings now fixed: App Store launcher pointed at plasma-discover (Bazzite ships **Bazaar**) → Bazaar everywhere
(desktop, Welcome, docs); inert "Game Library" launcher removed until ES-DE is pinned; absolute path for My Games; OCI labels
now Snormium's, not Bazzite's; audit is a single file and now also checks that every shipped launcher's Exec exists in the
image and that helpers resolve to bin_t (matchpathcon); readlink -e; Papirus icons no longer deleted; dav1d asserted;
flatpak timeout 4 h; RELEASE.json provenance written with every ISO. **URLs set to github.com/snormium/snormium (2026-09-06)** — the GitHub user/org `snormium` must be created and the CI
workflow run once before installed systems can receive updates (they look for ghcr.io/snormium/snormium). Still not boot-tested.**
**Desktop icons (2026-09-06)**: 37 flat launchers in 6 themed rows at 32 px, placed via plasmashell `evaluateScript` using Folder View's
`positions` StringList (format read from plasma-desktop `positioner.cpp`: `[numStripes, perStripe, url, stripe, pos …]`). Untested on
a real session: if Plasma re-flows them, fallback is name-sorted rows.
**Rice (2026-09-06)**: full Plasma global theme (see branding/PALETTE.md). Unverified until booted: panel layout JS, KSplash QML,
font package names `rsms-inter-fonts` / `jetbrains-mono-fonts`, `kpackagetool6` validation of the LnF package.


## Done here
| Item | State | Evidence |
|---|---|---|
| Containerfile + 6 build steps (packages, system, security, branding, debrand+audit, cleanup) | written, lint-clean | shellcheck; structure mirrors ublue-os/image-template (verified against upstream today) |
| Security / Welcome / Recovery centers ported to Fedora Atomic (firewalld, SELinux, rpm-ostree rollback, uupd, KDE) | launch-tested under Xvfb | probes run; windows construct |
| KDE look-and-feel, SDDM, Plymouth, os-release branding; Bazzite/Valve artwork removal + audit | written | audit cannot run here (no container runtime, registries blocked) |
| Flatpak preinstall via Bazzite's system-flatpaks list; ujust recipes; firstboot pin | written | — |
| Justfile (build, build-nvidia, audit, build-iso, build-qcow2, run-vm), bootc-image-builder configs | written | bib invocation copied from upstream template |
| GitHub Actions: weekly rebuild on latest Bazzite, audit, push, cosign | written | — |
| build.sh one-shot for a VM (podman + just + bib) | lint-clean | — |

## Not done — why
* Verified on the real base (2026-09-03): all RPM names correct; `steamdeck-kde-presets-desktop` is the artwork package; `uupd.timer`
  is the updater; `kcm_gamecontroller/kscreen/lookandfeel/access` exist. Unverified: `kwalletmanager5` binary name;
  `snormium-flatpaks.service` (new, untested until first boot).
* bib coupling: the ISO build symlinks `fedora-40.yaml` in bib's defs dir — if bib renames that file, `just build-iso` breaks with
  "could not find def file". No `--distro` flag exists as of bib 2026-06.
* Bazzite branding is broader than Mint's: the audit targets *user-visible* art (wallpapers, Vapor/VGUI themes, SDDM, logos,
  desktop entries). Functional `ujust`/`uupd` scripts keep the Bazzite name internally by design.
* `bootc container lint` at the end of the Containerfile enforces /var cleanliness; `90-cleanup.sh` may need tuning on first build.
* Not boot-tested. testing/CHECKLIST.md applies.

## Next
1. On the VM: `bash ~/Downloads/build.sh` (needs ~40 GB free, pulls ~8 GB). Fix any package name, rerun.
2. `just build-qcow2 && just run-vm` on a KVM host, or write the ISO to USB and boot real hardware (Secure Boot on; enrol key once).
3. Push to GitHub with `REPO_ORGANIZATION` set so users get signed automatic updates from `ghcr.io/<you>/snormium`.
