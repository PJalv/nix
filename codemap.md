# Repository Atlas: nixos

## Project Responsibility

NixOS flake for desktop, laptop, WSL, and standalone remote Home Manager use. The repository layers shared NixOS modules, user profiles, hardware profiles, Home Manager application modules, local packages, public-safe defaults, and pinned flake inputs into complete machine configurations.

## System Entry Points

- `flake.nix`: Primary composition root. Defines inputs, pins an external dotfiles repository, wires a public-safe `private.template` flake input, and exposes generic `nixosConfigurations` for `desktop`, `laptop`, and `wsl`, plus a standalone `homeConfigurations.ubuntu` profile.
- `flake.lock`: Locks upstream inputs such as `nixpkgs`, `home-manager`, `nixos-wsl`, `spicetify-nix`, `firefox-addons`, `nix-gaming`, `opencode-flake`, `llm-agents`, `handy`, and `mex`.
- `install.sh`: Fresh-install automation referenced by the README; bootstraps flakes, clones the repo, detects target machine type, generates hardware config, and applies the configuration.
- `test.nix`: Root-level Nix expression for ad hoc testing/experimentation.
- `README.md` / `INSTALL.md`: Human-facing installation and usage documentation.

## Design

- **Flake composition root**: `flake.nix` passes `machine`, `username`, `dotfilesDir`, and `inputs` through `specialArgs` / `extraSpecialArgs`, letting downstream NixOS and Home Manager modules branch on host context without duplicating whole configurations.
- **Profile layering**: Shared system config lives under `users/primary/user.nix`; machine-specific concerns are selected by the `machine` argument, hardware profile files, and the overridable private flake.
- **One module per concern**: `modules/` and `hm/` are organized into focused Nix modules for backup, gaming, optimization, Hyprland, Waybar, terminals, shell, browser, theming, and media tools.
- **Pinned external assets**: The flake fetches fixed external sources and passes `dotfilesDir`; individual modules also pin sources for specific tools/assets where needed.
- **Local package island**: `pkgs/` contains package-specific derivations and patch sets, currently centered on `stremio-linux-shell`.

## Flow

1. Nix evaluates `flake.nix` and resolves locked inputs from `flake.lock`.
2. A selected output (`desktop`, `laptop`, `wsl`, or `homeConfigurations.ubuntu`) imports the relevant system, private overlay, and Home Manager modules.
3. `specialArgs` propagate machine/user context and external inputs into modules.
4. NixOS modules configure system services, hardware integration, gaming/runtime support, backups, optimization, and user accounts.
5. Home Manager modules configure the user session, shell, Wayland desktop, theming, browser, terminals, status bar, launcher, and application integrations.
6. Local packages and pinned external sources are built or referenced as needed, then exposed through system or user package lists.

## Repository Directory Map

| Directory | Responsibility Summary | Detailed Map |
|-----------|------------------------|--------------|
| `modules/` | Self-contained NixOS modules for Raspberry Pi backup automation, gaming support, Nix/store optimization, and dotfiles-extension placeholder wiring. | [modules/codemap.md](modules/codemap.md) |
| `hm/` | Home Manager module set for the user desktop/session environment: Hyprland, Waybar, lock/idle, shell, terminals, browser, theming, Spicetify, and helper tools. | [hm/codemap.md](hm/codemap.md) |
| `users/` | User-scoped NixOS and Home Manager profiles for workstation/WSL systems and a lightweight `remote` profile. | [users/codemap.md](users/codemap.md) |
| `users/primary/` | Shared primary system profile with machine-aware desktop/laptop/WSL composition and Home Manager integration. | [users/primary/codemap.md](users/primary/codemap.md) |
| `users/primary/desktop/` | Desktop generated hardware profile consumed by the generic `desktop` configuration. | [users/primary/desktop/codemap.md](users/primary/desktop/codemap.md) |
| `users/primary/laptop/` | Laptop generated hardware profile for filesystems, swap, DHCP, and CPU microcode defaults. | [users/primary/laptop/codemap.md](users/primary/laptop/codemap.md) |
| `users/remote/` | Minimal remote Home Manager profile for shell/dev tooling and standalone HM deployment. | [users/remote/codemap.md](users/remote/codemap.md) |
| `pkgs/` | Local package definitions and package-local patches/overrides. | [pkgs/codemap.md](pkgs/codemap.md) |
| `pkgs/stremio-linux-shell/` | Custom Stremio derivation with source patching, runtime wrapping, and GUI/library integration. | [pkgs/stremio-linux-shell/codemap.md](pkgs/stremio-linux-shell/codemap.md) |

## Integration Points

- **NixOS**: `nixpkgs.lib.nixosSystem`, NixOS module system, systemd services/timers, hardware profiles, boot/network/audio/graphics/user-account options.
- **Home Manager**: `home-manager.nixosModules.home-manager` for NixOS-integrated user environments and `home-manager.lib.homeManagerConfiguration` for standalone remote use.
- **External flakes**: `nixos-wsl`, `spicetify-nix`, `firefox-addons`, `nix-gaming`, `opencode-flake`, `llm-agents`, `handy`, `mex`, and NUR-derived packages.
- **Desktop runtime**: Hyprland/Wayland ecosystem, Waybar, Hyprlock/Hypridle, Ghostty/Kitty, Rofi, Firefox, Spotify/Spicetify, GTK/Qt theming.
- **Operational tooling**: Install automation, Pi rsync backup service, Nix GC/store optimization, Docker/dev tooling, SSH, and local package patches.
