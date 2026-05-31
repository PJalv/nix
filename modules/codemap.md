# modules/

This directory contains small, self-contained NixOS modules for host-specific functionality:
backup automation, gaming support, system optimization, and a placeholder for dotfiles wiring.

## Responsibility

- **pi-backup.nix**: Provides an opt-in incremental backup service that syncs a local directory to a Raspberry Pi over SSH/rsync, with logs, manifests, and success/failure state tracking on the remote disk.
- **gaming.nix**: Enables a gaming-oriented desktop setup: Steam/Proton, compatibility tooling, game performance services, controller support, and runtime library coverage for non-Nix binaries.
- **optimization.nix**: Applies system-wide Nix store maintenance and build-performance settings such as GC, store optimisation, and binary cache configuration.
- **dotfiles.nix**: Placeholder module reserved for future dotfiles configuration; currently documents that dotfiles are injected from flake-level `specialArgs`.

## Design Patterns / Structure

- All modules follow the standard NixOS pattern: `{ config, lib, pkgs, ... }:` plus `options` gated by `config`/`cfg` with `lib.mkIf` for conditional activation.
- **pi-backup** uses a two-layer design:
  - a `pkgs.writeShellApplication` wrapper for the actual backup command
  - NixOS service/timer units to schedule and run it declaratively
- **gaming** uses package override customization (`overridePythonAttrs`) to patch upstream `ds4drv` for current Python/evdev APIs.
- **optimization** is a pure declarative settings module with minimal branching.
- **dotfiles** is intentionally inert: no options/config today, only comments for future extensibility.

## Data & Control Flow

- **pi-backup**:
  1. User enables `services.piBackup` and optionally configures source, Pi host/user, destination root, excludes, and timer.
  2. `backup-to-pi` validates the source directory, verifies passwordless SSH reachability, creates remote directories, and records an `in-progress` marker.
  3. `rsync` performs an incremental mirror to `DEST_ROOT/latest` while excluding configured patterns.
  4. On success, the script writes a manifest and updates remote `last-success` state; on failure, a trap appends failure metadata, uploads the log, and records `last-failure`.
  5. The systemd timer optionally triggers the one-shot service on a calendar schedule.
- **gaming**:
  1. `gaming.enable` activates the stack.
  2. Steam/Proton is enabled, `nix-ld` exposes a broad runtime library set for proprietary/game binaries, and graphics is configured with 32-bit support.
  3. `gamemode` and `gamescope` provide runtime performance tuning.
  4. udev rules and kernel modules grant controller/device access.
  5. A `ds4drv` systemd service starts at boot to emulate an Xbox 360 controller from a DualShock 4.
- **optimization**:
  1. `optimization.enable` defaults to true.
  2. When enabled, Nix GC runs weekly, the store is auto-optimised, and substituters/public keys are configured for cache-based builds.
  3. `extraOptions` constrains free disk space to keep the store healthy.
- **dotfiles**: no runtime flow yet; it is a stub for future config injection.

## Integration Points

- **NixOS services/timers**: `pi-backup` and `ds4drv` integrate through `systemd.services` and `systemd.timers`.
- **User environment**: `pi-backup` exports its helper script into `environment.systemPackages` for manual runs.
- **Networking/SSH**: `pi-backup` depends on `openssh`, `rsync`, and network-online targets.
- **Hardware/device access**: `gaming` integrates with kernel modules, udev rules, Bluetooth, and graphics stack components.
- **Desktop/game stack**: Steam, Proton-GE, Heroic, Wine, MangoHud, Protontricks, `steam-run`, `gamemode`, and `gamescope` form the core gaming integration surface.
- **Nix build infrastructure**: `optimization` configures Nix GC, store optimisation, binary caches, trusted keys, and build parallelism.
- **Flake-level wiring**: `dotfiles` currently documents external integration via `specialArgs` rather than implementing its own settings.
