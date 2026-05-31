# users/

## Responsibility

User-scoped Nix modules for this repository. This subtree assembles per-user system and Home Manager configuration for the primary workstation profiles and the lightweight `remote` Home Manager profile.

## Design Patterns/Structure

- Profile-oriented layout: the primary profile contains a shared system module plus machine-specific hardware/module fragments.
- Home Manager is split from NixOS system config: `hm.nix` files define user environment, while `user.nix` / `wsl.nix` define system-level state.
- Declarative composition via `lib.mkMerge` and `lib.mkIf` to layer common, desktop, and laptop settings.
- Generated hardware config files are kept alongside the profile that consumes them.

## Data & Control Flow

- The primary profile module imports the selected hardware configuration based on `machine`.
- Common packages/services are applied first, then desktop- or laptop-specific overlays are conditionally merged.
- Home Manager files consume repo-local dotfiles and shared HM modules, then add user packages and desktop integration.
- The `remote` profile only wires minimal shell/dev tooling and user-session settings.

## Integration Points

- NixOS system services: boot loader, networking, hardware, PipeWire, X11/Wayland, OpenSSH, Docker, firewall, and user accounts.
- Desktop integration: Hyprland, greetd, SDDM, xdg-desktop-portal, Wayland utilities, and GUI apps.
- Dev tooling: Home Manager, direnv, Git/GH, compilers, language servers, and Nix flakes.
- External inputs: flake inputs for `spicetify-nix`, `llm-agents`, `mex`, and `opencode-flake` packages.
