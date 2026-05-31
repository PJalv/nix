# users/primary/desktop/

## Responsibility

Desktop-specific hardware definition. This is the machine profile consumed by the shared `users/primary/user.nix` module when `machine = "desktop"`.

## Design Patterns/Structure

- Generated `nixos-generate-config` output kept as a hardware-only module.
- Minimal scope: filesystem, kernel modules, and platform defaults only.
- No policy or userland app configuration lives here.

## Data & Control Flow

- Imports the installer scan module, then declares disk mounts, boot-time modules, and host platform defaults.
- The shared `user.nix` module imports this file and layers system services, packages, and desktop-specific runtime behavior on top.

## Integration Points

- Filesystems: root Btrfs and `/boot` VFAT mount definitions.
- Boot/kernel: NVMe/AHCI/initrd modules, `kvm-amd`, and AMD microcode handling.
- Consumed by the shared desktop configuration; does not stand alone.
