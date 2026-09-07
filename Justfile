set dotenv-filename := "snormium.env"
image_name := env_var("IMAGE_NAME")
tag        := env_var("DEFAULT_TAG")
bib        := env_var("BIB_IMAGE")
base       := env_var("BASE_IMAGE")
base_nv    := env_var("BASE_IMAGE_NVIDIA")
variant    := env_var("IMAGE_VARIANT")

default:
    @just --list

# Static checks (no container needed)
lint:
    testing/lint.sh

# Build the Snormium image (AMD/Intel). Use `just build-nvidia` for the NVIDIA-open variant.
build:
    sudo podman build --pull=newer --build-arg BASE_IMAGE={{base}} --build-arg IMAGE_VARIANT={{variant}} \
        --build-arg IMAGE_NAME={{image_name}} -t localhost/{{image_name}}:{{tag}} .

build-nvidia:
    sudo podman build --pull=newer --build-arg BASE_IMAGE={{base_nv}} --build-arg IMAGE_VARIANT={{variant}} \
        --build-arg IMAGE_NAME={{image_name}}-nvidia -t localhost/{{image_name}}-nvidia:{{tag}} .

# Run the Bazzite-artwork audit against the built image
audit img=("localhost/" + image_name + ":" + tag):
    sudo podman run --rm {{img}} bash /usr/libexec/snormium/audit-bazzite-assets.sh /

# Build an installer ISO with bootc-image-builder (rootful podman; output/ gets the .iso + sha256)
build-iso img=("localhost/" + image_name + ":" + tag): (_bib img "iso" "disk_config/iso.toml")
build-qcow2 img=("localhost/" + image_name + ":" + tag): (_bib img "qcow2" "disk_config/disk.toml")

_bib img type config:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p output; tmp=$(mktemp -d -p "$PWD" _bib.XXXXXX); keys=$(mktemp -d -p "$PWD" _bibkeys.XXXXXX)
    trap 'sudo rm -rf "$keys"' EXIT
    # bib depsolves against the dnf repos *inside* the image but runs the solver in its own container, where the
    # gpgkey=file:///etc/pki/rpm-gpg/... paths (Terra repos, repo_gpgcheck=1) do not exist. Stock Bazzite fails the
    # same way. Merge the image's keyring into the bib container (cp -n keeps bib's own keys).
    cid=$(sudo podman create {{img}} true); sudo podman cp "$cid:/etc/pki/rpm-gpg/." "$keys/"; sudo podman rm "$cid" >/dev/null
    # bib selects its distro definition by "<ID>-<VERSION_ID>"; downstreams are registered in its defs dir as symlinks
    # onto the base distro (bazzite-*, bluefin-*, aurora-* ship that way). Register snormium the same way for this run.
    osid=$(sudo podman run --rm {{img}} sh -c '. /usr/lib/os-release; echo "${ID}-${VERSION_ID}"')
    sudo podman run --rm --privileged --pull=newer --net=host --security-opt label=type:unconfined_t \
      --entrypoint /bin/bash \
      -v "$PWD/{{config}}:/config.toml:ro" -v "$tmp:/output" -v "$keys:/tmp/imgkeys:ro" \
      -v /var/lib/containers/storage:/var/lib/containers/storage \
      {{bib}} -c "set -euo pipefail
        base=\$(ls /usr/share/bootc-image-builder/defs/fedora-*.yaml | sort -V | tail -1); [ -n \"\$base\" ] || { echo 'no fedora-*.yaml in bib defs'; exit 1; }
        ln -sf \"\$(basename \"\$base\")\" /usr/share/bootc-image-builder/defs/${osid}.yaml
        cp -rn /tmp/imgkeys/. /etc/pki/rpm-gpg/ 2>/dev/null || true
        exec /usr/bin/bootc-image-builder build --type {{type}} --use-librepo=True --rootfs=btrfs --output /output {{img}}"
    sudo mv -f "$tmp"/* output/; sudo rmdir "$tmp"; sudo chown -R "$USER" output
    if [[ "{{type}}" == iso ]]; then
      iso=$(find output -name '*.iso' | head -1); mv "$iso" "output/{{image_name}}-{{tag}}-x86_64.iso"
      just brand-iso "output/{{image_name}}-{{tag}}-x86_64.iso"
      just provenance {{img}} "output/{{image_name}}-{{tag}}-x86_64.iso"
      (cd output && sha256sum "{{image_name}}-{{tag}}-x86_64.iso" > "{{image_name}}-{{tag}}-x86_64.iso.sha256"); ls -la output/*.iso*
    fi

# Inject Snormium installer branding (images/product.img) into a finished ISO and re-stamp its media checksum.
# bootc-image-builder builds the Anaconda environment from stock Fedora packages, so without this the installer
# shows Fedora's sidebar. product.img is Anaconda's official overlay mechanism; no repack of install.img needed.
brand-iso iso:
    #!/usr/bin/env bash
    set -euo pipefail
    command -v xorriso >/dev/null && command -v implantisomd5 >/dev/null || { echo "need xorriso + isomd5sum"; exit 1; }
    logo=branding/anaconda/sidebar-logo.svg; [[ -f branding/custom/sidebar-logo.svg ]] && logo=branding/custom/sidebar-logo.svg
    # Scratch MUST be on the same real filesystem as the ISO: xorriso writes a full second copy here, and /tmp on a stock
    # Fedora host is a RAM tmpfs (half of RAM) — a bare `mktemp -d` killed a 6 GB ISO with ENOSPC on an 8 GB VM.
    tmp=$(mktemp -d -p "$PWD" _bib.brand.XXXXXX); trap 'rm -rf "$tmp"' EXIT
    branding/anaconda/make-product-img.sh "$tmp/product.img" "$logo"
    xorriso -indev "{{iso}}" -outdev "$tmp/branded.iso" -boot_image any replay -map "$tmp/product.img" /images/product.img -commit >/dev/null 2>"$tmp/xorriso.err" \
      || { echo "xorriso failed (exit $?); last lines of its stderr:"; tail -n 20 "$tmp/xorriso.err"; exit 1; }
    implantisomd5 --force "$tmp/branded.iso" >/dev/null
    mv -f "$tmp/branded.iso" "{{iso}}"; echo "branded: {{iso}} (images/product.img added, md5 re-implanted)"

# Record what went into a release: base digest/version, image id/digest, ISO hash, date -> output/RELEASE.json
provenance img iso:
    #!/usr/bin/env bash
    set -euo pipefail
    variant=$(sed -n 's/^IMAGE_VARIANT=//p' snormium.env); base=$(sed -n 's/^BASE_IMAGE=//p' snormium.env)
    bdig=$(sudo podman inspect --format '{{{{.Digest}}}}' "$base:$variant" 2>/dev/null || echo unknown)
    bver=$(sudo podman inspect --format '{{{{index .Labels "org.opencontainers.image.version"}}}}' "$base:$variant" 2>/dev/null || echo unknown)
    iid=$(sudo podman inspect --format '{{{{.Id}}}}' {{img}}); idig=$(sudo podman inspect --format '{{{{.Digest}}}}' {{img}})
    sha=$(sha256sum "{{iso}}" | cut -d' ' -f1); size=$(stat -c %s "{{iso}}"); commit=$(git rev-parse --short HEAD 2>/dev/null || echo untracked)
    python3 - "$base:$variant" "$bdig" "$bver" "$iid" "$idig" "$(basename "{{iso}}")" "$sha" "$size" "$commit" <<'PY'
    import json,sys,datetime
    b,bd,bv,iid,idig,iso,sha,size,commit=sys.argv[1:]
    json.dump({"name":"Snormium","built":datetime.datetime.now(datetime.timezone.utc).isoformat(),"base":{"ref":b,"digest":bd,"version":bv},
               "image":{"id":iid,"digest":idig},"iso":{"file":iso,"sha256":sha,"bytes":int(size)},"source_commit":commit},open("output/RELEASE.json","w"),indent=2)
    print(open("output/RELEASE.json").read())
    PY

# Boot the qcow2 in QEMU (needs KVM)
run-vm:
    qemu-system-x86_64 -accel kvm -cpu host -m 8192 -smp 4 -M q35 -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd \
      -drive file=output/qcow2/disk.qcow2,format=qcow2,if=virtio -device virtio-vga-gl -display gtk,gl=on -nic user,model=virtio-net-pci

clean:
    sudo rm -rf output _bib.*
