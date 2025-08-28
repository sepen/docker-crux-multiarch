# 3.8/Dockerfile
# Multi-arch Dockerfile for CRUX 3.8

# Builder stage to unpack the relevant rootfs tarball
FROM --platform=$BUILDPLATFORM sepen/crux-multiarch:3.7 AS intermediate

# Enable buildkit args for multi-arch builds
#
# These args are set automatically by docker buildx
# when using `docker buildx build --platform ...`
# See https://docs.docker.com/engine/reference/commandline/buildx_build/#set-build-args
# for more details.
#
# TARGETOS: e.g linux, windows, etc
# TARGETARCH: e.g. amd64, arm64, arm, etc
# TARGETVARIANT: e.g. v7 for arm32v7
# TARGETPLATFORM: e.g. linux/amd64, linux/arm64, etc
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG TARGETPLATFORM

# Copy all the rootfs tarballs into the builder image
COPY ${TARGETARCH}*${TARGETVARIANT}.rootfs.tar /rootfs.tar

# Unpack the tarball into a rootfs directory
RUN install -d -m 0755 -o root -g root /rootfs && \
    tar -C /rootfs -xf /rootfs.tar

# Configure the image and packages installation
RUN if [ -d /rootfs/media/crux ] && ls /rootfs/media/crux/core/*.pkg.tar.* >/dev/null 2>&1; then \
      mv /rootfs /oldrootfs && \
      install -d -m 0755 /rootfs/var/lib/pkg && \
      touch /rootfs/var/lib/pkg/db && \
      install -d -m 0755 /rootfs/etc && \
      echo 'INSTALL ^dev/.*$ NO' >> /rootfs/etc/pkgadd.conf && \
      echo "Installing CRUX packages..."; \
      find /oldrootfs/media/crux/core -type f -name '*.pkg.tar.*' \
        -exec pkgadd -r /rootfs -f {} \; || true; \
    else \
      echo "No CRUX packages found, skipping"; \
    fi

# Final stage
FROM scratch

# Copy the unpacked rootfs from the intermediate stage
COPY --from=intermediate /rootfs /

# Default command
CMD /usr/bin/crux