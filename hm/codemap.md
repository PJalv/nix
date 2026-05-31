# hm/

Home Manager module set for the user environment. This directory is mostly a collection of focused, per-app Nix modules that are imported into a larger HM configuration.

## Responsibility

- Define the desktop/session experience for the user: Hyprland, Hyprlock/Hypridle, Waybar, Rofi, Kitty, Ghostty, Firefox, GTK/Qt theming, Zsh, Starship, and Spicetify.
- Provide a small amount of glue for external tools and desktop integration:
  - desktop entries (`entries.nix`)
  - terminal / launcher / browser hotkeys
  - wallpaper and theme assets
  - a custom Go utility used by the window manager (`macro_go`)
- Keep the configuration mostly declarative, with a few runtime hooks and external scripts referenced from the dotfiles tree.

## Design

- **One module per concern**: each file owns one app or subsystem, which keeps the configuration easy to enable/disable independently.
- **Declarative HM options first, raw config second**:
  - many modules use Home Manager options directly (`programs.*`, `gtk`, `qt`, `xdg.desktopEntries`)
  - when a program needs custom syntax, the module writes config text into `xdg.configFile.*` or `extraConfig`
- **Shared asset injection**:
  - theme/config assets are pulled from `./dots` or fetched from GitHub via fixed rev/hash
  - this avoids duplicating large config blobs in multiple places
- **Machine-aware branching**:
  - `hyprland.nix` and `waybar.nix` switch behavior based on `machine` (`desktop` vs `laptop`)
  - laptop config adds suspend/idle behavior and battery/power widgets
- **A few embedded behaviors, not a framework**:
  - Hyprland binds launch apps and window actions directly
  - Zsh config bundles completion, fzf-tab, vi-mode, and aliases in one place
  - Waybar uses custom scripts for dynamic modules

## Flow

1. **Module import layer**
   - The parent HM config imports these files and passes in context such as `pkgs`, `inputs`, `config`, `lib`, `dotfilesDir`, `machine`, and `username`.
   - Most modules are thin wrappers around NixOS/HM options with a small amount of local logic.

2. **Asset resolution**
   - `starship.nix` imports TOML from `./dots/starship.toml`.
   - `waybar.nix` reads CSS from `${dotfilesDir}/.config/waybar/styles/style.css` and points custom modules at shell scripts under `${dotfilesDir}/.config/waybar/`.
   - `hyprlock.nix` references a wallpaper from a pinned GitHub fetch of the dotfiles repo.
   - `ghostty.nix` writes both Ghostty config and GTK tabbar CSS.

3. **Session startup and runtime flow**
   - Hyprland starts the Wayland session, sets env vars, sources monitor/workspace files, and launches session services (`copyq`, `wl-paste`, `mako`, `waybar`, `nm-applet`, `fusuma`, wallpaper loader, portal refresh).
   - Hypridle listens for inactivity and locks/suspends through Hyprlock and systemd suspend.
   - Hyprlock presents the wallpaper background, date, time, and password input.

4. **User interaction flow**
   - Hyprland keybinds drive app launch, workspace navigation, media control, screenshots, and window management.
   - Waybar widgets surface media/network/audio/power state and invoke external helpers on click/scroll.
   - Zsh and Starship shape shell behavior: prompt rendering, completion, fzf previews, aliases, and history options.

5. **Theming flow**
   - GTK/Qt, Kitty, Ghostty, Rofi, Starship, and Waybar are all aligned around the same visual style family (Catppuccin/Tokyonight-derived theming).
   - Firefox and Spicetify use extension/theme packages to keep application UI consistent with the desktop theme.

## Integration

- **Hyprland ecosystem**
  - `hyprland.nix` integrates with: `ghostty`, `rofi`, `thunar`, `copyq`, `wl-paste`, `cliphist`, `mako`, `waybar`, `chromium-browser`, `vesktop`, `spotify`, `emote`, `hyprlock`, `fusuma`, `nm-applet`, `grim`, `slurp`, `pactl`, `brightnessctl`, `playerctl`, `hyprctl`.
- **Lock / idle / session management**
  - `hypridle.nix` depends on `hyprlock` and `systemctl suspend-then-hibernate`.
  - `hyprlock.nix` depends on the pinned dotfiles repo for wallpaper assets.
- **Shell experience**
  - `zsh.nix` integrates `fzf-tab`, `zsh-vi-mode`, `zoxide`, `fzf`, and `pay-respects`.
  - `starship.nix` reads `dots/starship.toml` and sets `STARSHIP_CACHE`.
- **Browser / music / theming**
  - `firefox.nix` pulls extensions from `inputs.firefox-addons`.
  - `spicetify.nix` pulls `spicetify-nix` from inputs and adds the custom `spicy-lyrics` extension.
- **Desktop appearance**
  - `gtk.nix` configures GTK themes/icons/cursors and Qt platform theme.
  - `kitty.nix`, `ghostty.nix`, and `rofi.nix` provide terminal/launcher styling and keybindings.
- **Packaging / desktop registration**
  - `macropad.nix` builds `macro_go` helper from a pinned GitHub source.
  - `entries.nix` registers the `stm32cubemx` desktop entry.

## File-level summary

- `entries.nix` — desktop entry for STM32CubeMX.
- `hyprland.nix` — core Wayland compositor config, keybinds, startup, window rules, machine-specific monitor/session setup.
- `hyprlock.nix` — lock screen config with pinned wallpaper and clock/date widgets.
- `hypridle.nix` — idle policy: lock, then suspend/hibernate.
- `waybar.nix` — status bar layout, custom modules, power/battery logic, theme CSS.
- `rofi.nix` — launcher theme and rofi defaults.
- `kitty.nix` — terminal theme, font, tabs, and keybindings.
- `ghostty.nix` — Ghostty terminal config plus GTK CSS tweaks.
- `zsh.nix` — shell plugins, completion, prompt behavior, aliases, and helper tools.
- `starship.nix` — imports TOML prompt config and sets cache location.
- `spicetify.nix` — Spotify theming/extensions.
- `firefox.nix` — Firefox profile and extensions.
- `gtk.nix` — GTK/Qt theme, font, icon, and cursor settings.
- `macropad.nix` — builds `macro_go` utility from source.
- `dots/starship.toml` — prompt layout and module formatting rules used by Starship.
