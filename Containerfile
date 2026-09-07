# Snormium 2.0 — a Bazzite (Fedora Atomic / bootc) derivative.
# Build:  just build            (podman build)     ISO:  just build-iso   (bootc-image-builder)
ARG BASE_IMAGE=ghcr.io/ublue-os/bazzite
ARG IMAGE_VARIANT=stable

# Build context: scripts + overlay, never copied into the final image
FROM scratch AS ctx
COPY build_files /build_files
COPY system_files /system_files
COPY packages /packages
COPY branding /branding

FROM ${BASE_IMAGE}:${IMAGE_VARIANT}
ARG DISTRO_NAME="Snormium"
ARG DISTRO_VERSION="2.0"
ARG DISTRO_CODENAME="isotope"
ARG DISTRO_HOME_URL="https://example.org/snormium"
ARG IMAGE_NAME=snormium
ENV DISTRO_NAME=${DISTRO_NAME} DISTRO_VERSION=${DISTRO_VERSION} DISTRO_CODENAME=${DISTRO_CODENAME} DISTRO_HOME_URL=${DISTRO_HOME_URL} IMAGE_NAME=${IMAGE_NAME}

LABEL org.opencontainers.image.title="${DISTRO_NAME}" \
      org.opencontainers.image.description="Snormium ${DISTRO_VERSION} (${DISTRO_CODENAME}) — secure, easy desktop & gaming OS built on Bazzite" \
      org.opencontainers.image.vendor="Snormium" \
      org.opencontainers.image.url="${DISTRO_HOME_URL}" \
      org.opencontainers.image.source="${DISTRO_HOME_URL}" \
      org.opencontainers.image.version="${DISTRO_VERSION}" \
      org.opencontainers.image.base.name="ghcr.io/ublue-os/bazzite" \
      io.artifacthub.package.logo-url="" \
      io.artifacthub.package.readme-url="" \
      io.artifacthub.package.keywords="bootc,bazzite,gaming,emulation,desktop"

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/build.sh

# Verify the image is a valid bootc container
RUN bootc container lint
