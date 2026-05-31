# users/primary/

## Responsibility

Primary user profile. This folder defines the shared system module, machine-specific hardware configs, and the Home Manager profile used by the desktop/laptop variants.

## Design Patterns/Structure

- Shared system module: `user.nix` parameterizes `machine` and `username` to reuse the same base across machines.
- Variant layering: desktop and laptop behavior is isolated behind `lib.mkIf (machine == ...)` blocks.
- Generated hardware files are separate from policy/config and imported by the shared module.
- Home Manager settings are centralized in `hm.nix` and import smaller feature modules from `../../hm/*`.

## Data & Control Flow

- `user.nix` selects the machine-specific hardware file, establishes shared packages/services, and then merges in machine-specific desktop/laptop settings.
- Desktop mode enables login/session flow through greetd and Hyprland; laptop mode uses SDDM and power-management hooks.
- `hm.nix` layers dotfiles, app defaults, package lists, and imported HM modules into the user environment.
- `wsl.nix` reuses a trimmed-down system configuration for WSL-like environments with the same user account shape.

## Integration Points

- NixOS modules for networking, Bluetooth, printing/media, ports/firewall, and user/group membership.
- Desktop tooling: Hyprland, greetd, SDDM, Wayland portals, Steam/gaming, AMD graphics, and a static NetworkManager profile for a DPI test network.
- Home Manager integration: shell, Git, Chromium, GTK theming, cursor theming, KDE Connect, and shared dotfiles.
- External packages/inputs: `stremio-linux-shell`, `spicetify-nix`, `llm-agents`, `mex`, and `opencode`-related packages.
