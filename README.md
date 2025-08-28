# docker-crux-multiarch

Non-official, multi-architecture Docker images for CRUX Linux

This repository provides non-official CRUX Linux images prebuilt for multiple CPU architectures: amd64, arm64, and arm/v7. They are ideal for developers, hobbyists, and enthusiasts who want to experiment with CRUX Linux in containerized environments.

## Tags

See all available tags here: https://hub.docker.com/r/sepen/crux-multiarch/tags

## Features

* Multi-arch support: Works seamlessly on x86_64, ARM64, and ARMv7 platforms.
* Minimal base: Only the essential CRUX root filesystem, allowing you to build your own packages and applications on top.
* Preconfigured rootfs: Includes the CRUX package system and core libraries, ready for containerized development.
* Lightweight: Designed for efficiency and simplicity, following CRUX’s minimal philosophy.

## Usage

Pull and run the latest CRUX image for your platform:
```
docker run --rm -it --platform linux/amd64 sepen/crux-multiarch:3.7 /bin/sh
docker run --rm -it --platform linux/arm64 sepen/crux-multiarch:3.8 /bin/sh
```

Replace `--platform` with your target architecture.

Note: These are non-official images, created for convenience and experimentation.
