# users/primary/laptop/

## Responsibility

Laptop-specific hardware definition. This profile is imported by the shared user module when `machine = "laptop"`.

## Design Patterns/Structure

- Generated hardware config with only platform facts and mount declarations.
- Keeps host-specific disks, swap, and network defaults separate from policy and packages.
- Serves as a thin input to the shared `users/primary/user.nix` module.

## Data & Control Flow

- Declares installed hardware modules and mounts, then hands control to the shared profile module for actual system behavior.
- Provides the base filesystem/network defaults used by the laptop branch of the shared config.

## Integration Points

- Filesystems: root Btrfs, separate `/boot`, and separate `/home` Btrfs mount.
- Swap: a dedicated swap device.
- Networking: default DHCP on interfaces, with commented interface-specific examples.
- Microcode: AMD CPU microcode via redistributable firmware defaults.
