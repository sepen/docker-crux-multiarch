## Development

### Enable Multi-Arch Containers on macOS (podman)

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
   podman run --rm -it --platform=linux/arm/v7 sepen/crux-multiarch:3.8 uname -m
   ```
