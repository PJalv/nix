# NixOS Configuration for User `pjalv`

Welcome to the NixOS configuration repository for user **`pjalv`**. This repository contains the system configurations, Home Manager settings, and dotfiles tailored for both desktop and laptop setups. It's designed to provide a cohesive and modular approach to managing NixOS systems using flakes.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Directory Structure](#directory-structure)
- [Key Components](#key-components)
  - [Flakes](#flakes)
  - [Home Manager](#home-manager)
  - [Hyprland Window Manager](#hyprland-window-manager)
  - [Ghostty Terminal](#ghostty-terminal)
  - [Wayland and Waybar](#wayland-and-waybar)
  - [Zsh Configuration](#zsh-configuration)
  - [Additional Tools](#additional-tools)
- [Usage](#usage)
- [Updating the System](#updating-the-system)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This repository serves as a comprehensive NixOS configuration for both desktop and laptop environments under the user `pjalv`. It leverages the power of Nix flakes for reproducible builds and Home Manager for user-specific configurations.

By organizing configurations into reusable modules, this setup allows for easy customization and scalability, catering to different machines while maintaining a shared base configuration.

## Features

- **Modular Configuration**: Separate configurations for desktop and laptop with shared modules.
- **Flake Support**: Uses Nix flakes for modern and reproducible Nix expressions.
- **Home Manager Integration**: Manages user-specific settings and dotfiles.
- **Hyprland Window Manager**: Configured for a tiling Wayland compositor.
- **Custom Terminal and Shell**: Includes configurations for Ghostty terminal and Zsh with Powerlevel10k theme.
- **Wayland Support**: Waybar and other Wayland-specific configurations.
- **Package Management**: Manages system and user packages declaratively.

## Getting Started

### Prerequisites

- **Nix Package Manager**: Ensure Nix is installed on your system.
- **NixOS**: This configuration is intended for NixOS installations.
- **Flakes Enabled**: Flakes must be enabled in your Nix configuration.

To enable flakes, add the following to your `/etc/nix/nix.conf`:

```nix
experimental-features = nix-command flakes
```

### Installation

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/PJalv/nixos-config.git
   cd nixos-config
   ```

2. **Switch to Configuration**:

   Use the NixOS `flake` command to switch to the desired configuration.

   For **desktop**:

   ```bash
   sudo nixos-rebuild switch --flake .#pjalv-desktop
   ```

   For **laptop**:

   ```bash
   sudo nixos-rebuild switch --flake .#pjalv-laptop
   ```

3. **Set User Password**:

   After the rebuild, set the password for the user `pjalv` if not already set:

   ```bash
   sudo passwd pjalv
   ```

## Directory Structure

```
├── users/
│   └── pjalv/
│       ├── desktop/
│       │   └── hardware-configuration.nix
│       ├── laptop/
│       │   └── hardware-configuration.nix
│       ├── hm/
│       │   ├── dots/
│       │   │   └── starship.toml
│       │   ├── entries.nix
│       │   ├── ghostty.nix
│       │   ├── gtk.nix
│       │   ├── hyprland.nix
│       │   ├── kitty.nix
│       │   ├── macropad.nix
│       │   ├── rofi.nix
│       │   ├── starship.nix
│       │   ├── waybar.nix
│       │   └── zsh.nix
│       ├── hm.nix
│       ├── misc.nix
│       ├── test.nix
│       └── user.nix
├── .gitignore
├── configuration.nix
├── flake.nix
├── flake.lock
├── hardware-configuration.nix
└── update.sh
```

- **users/**: Contains user-specific configurations.
  - **pjalv/**: Configurations for the user `pjalv`.
    - **desktop/** and **laptop/**: Hardware configurations for respective machines.
    - **hm/**: Home Manager modules and dotfiles.
    - **hm.nix**: Home Manager entry point.
    - **user.nix**: Primary NixOS configuration module for the user.

- **configuration.nix**: Entry point for NixOS configuration (default, may be overridden by flakes).
- **flake.nix**: Defines the flake with NixOS configurations.
- **update.sh**: Script to update Nix channels (deprecated with flakes).

## Key Components

### Flakes

The configuration uses Nix flakes for reproducibility and ease of managing dependencies. The `flake.nix` file defines the outputs, including NixOS configurations for desktop and laptop:

```nix
{
  description = "PJalv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    ghostty.url = "github:ghostty-org/ghostty";
  };

  outputs = { ... }:
  {
    nixosConfigurations = {
      pjalv-desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./users/pjalv/user.nix
          home-manager.nixosModules.home-manager
          # Additional modules...
        ];
      };
      # Similar for pjalv-laptop...
    };
  };
}
```

### Home Manager

Home Manager is used to manage user-specific configurations and dotfiles declaratively. The entry point is `hm.nix`:

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./hm/zsh.nix
    ./hm/rofi.nix
    ./hm/hyprland.nix
    # Additional modules...
  ];
}
```

### Hyprland Window Manager

[Hyprland](https://hyprland.org/) is configured as the window manager. The module `hyprland.nix` sets up the environment, keybindings, and aesthetics.

Features include:

- Custom keybindings using `$mainMod` (typically `ALT`).
- Workspace management.
- Gestures and touchpad settings.
- Integration with Wayland-specific applications.

### Ghostty Terminal

[Ghostty](https://github.com/ghostty-org/ghostty) is a fast and minimal terminal emulator. Configuration is in `ghostty.nix`, which sets custom styles, fonts, and behavior.

Key settings:

- Font: FiraCode Nerd Font Mono
- Background opacity and theme.
- Custom keybindings for scrolling and tab navigation.

### Wayland and Waybar

Support for Wayland compositors and the status bar [Waybar](https://github.com/Alexays/Waybar) is included. The `waybar.nix` module configures the modules, style, and custom scripts.

Highlights:

- Modules for CPU, memory, network, battery, and media controls.
- Custom styling using Catppuccin theme.
- Integration with Hyprland and media players.

### Zsh Configuration

The `zsh.nix` module sets up Zsh with plugins and themes:

- **Plugins**:
  - `fzf-tab`: Enhanced tab completion.
  - `powerlevel10k`: A fast and customizable theme.
- **Features**:
  - Syntax highlighting.
  - Autosuggestions.
  - Custom keybindings and aliases.

### Additional Tools

- **Macropad**: Custom Go-based macro pad tool (`macropad.nix`).
- **Entry Points**: Application entries configured via `entries.nix`.
- **Dotfiles**: Managed under `dots/` for easy portability.

## Usage

- **Switching Configurations**: Use the `nixos-rebuild` command with flakes to switch between desktop and laptop configurations.
- **Home Manager**: Manage user environments declaratively. Changes in `hm.nix` and its modules can be applied with:

  ```bash
  home-manager switch
  ```

- **Custom Scripts**: Some modules reference custom scripts located in external repositories (e.g., dotfiles). Ensure these are fetched or adjust paths accordingly.

## Updating the System

To update the NixOS system and flakes:

1. **Pull Latest Changes**:

   ```bash
   git pull
   ```

2. **Update Flake Inputs**:

   ```bash
   nix flake update
   ```

3. **Rebuild System**:

   ```bash
   sudo nixos-rebuild switch --flake .#pjalv-desktop
   ```

   Replace `pjalv-desktop` with `pjalv-laptop` if applicable.

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests. When contributing, please follow the existing code style and structure.

## License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and distribute this software.

---

Thank you for exploring this NixOS configuration. If you have any questions or need assistance, feel free to reach out!
