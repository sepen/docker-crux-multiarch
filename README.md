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

## Development

### Enable Multi-Arch Containers on macOS

To register the missing binfmt interpreters. You need qemu-user-static with binfmt entries for arm, arm64, etc. inside your Podman machine VM.

Steps (inside podman machine ssh):
```sh
podman machine ssh
```

1. Install qemu-user-static
   ```sh
   rpm-ostree install qemu-user-static
   ```

2. Reboot VM to apply rpm-ostree changes
   ```sh
   systemctl reboot
   ```

3. After reboot, check supported archs:
   ```sh
   ls /proc/sys/fs/binfmt_misc/
   ```

   You should now see entries like:
   ```
   qemu-arm
   qemu-armbe
   qemu-aarch64
   qemu-mips
   ...
   ```

   Note, that if there’s no qemu-arm interpreter available inside /proc/sys/fs/binfmt_misc/ you need to explicitly installs the ARM little-endian handler. To do that run this inside your Podman machine VM:
   ```sh
   podman machine ssh
   podman run --privileged --rm tonistiigi/binfmt --install arm
   ```

4. Test
   ```sh
   podman run --rm -it --platform=linux/arm/v7 alpine uname -m
   ```