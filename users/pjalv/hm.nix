{
  config,
  pkgs,
  lib,
  machine ? "desktop",
  username ? "pjalv",
  inputs,
  ...
}: let
  # Define the Git repository URL and revision (e.g., branch, commit hash, etc.)
  dotfilesRepo = pkgs.fetchgit {
    url = "https://github.com/PJalv/dotfiles.git"; # Replace with your repo URL
    rev = "296e0a345840c58e8b8e28eb9e564a283adc003e";
    # Or specify the commit hash/branch/tag
    sha256 = "sha256-Xc0bu3me8YuHwt4xZ8+juOndO0sS4IUwU0ql60s5GNc="; # This will be automatically replaced when you run `nixos-rebuild`
  };

  # Define the location of your dotfiles directory
  dotfilesDir = dotfilesRepo;

  spicetify-nix = inputs.spicetify-nix.homeManagerModules.default;
in {
  xdg.configFile = {
    wallpaper.source = "${dotfilesDir}/.config/wallpaper"; # Neovim config
    fusuma.source = "${dotfilesDir}/.config/fusuma"; # Neovim config
    mako.source = "${dotfilesDir}/.config/mako"; # Neovim config
    styles.source = "${dotfilesDir}/.config/waybar"; # Neovim config
  };
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "x-scheme-handler/http" = ["chromium-browser.desktop"];
      "x-scheme-handler/https" = ["chromium-browser.desktop"];
      "text/html" = ["chromium-browser.desktop"];
      "application/pdf" = ["chromium-browser.desktop"];
    };
    defaultApplications = {
      "x-scheme-handler/http" = ["chromium-browser.desktop"];
      "x-scheme-handler/https" = ["chromium-browser.desktop"];
      "text/html" = ["chromium-browser.desktop"];
      "application/pdf" = ["chromium-browser.desktop"];
    };
  };

  home.packages = with pkgs; [
    lazygit
    bat
    hyperfine
    swww
    sassc
    alejandra
    gtk-engine-murrine
    gtk_engines
    gnome-themes-extra
    ghostty
    hyprlock
    zoxide
    nwg-displays

    tree-sitter

    jq
    syspower
    easyeffects
    inputs.opencode-flake.packages.${pkgs.system}.default
  ];

  imports = [
    ../../hm/zsh.nix
    ../../hm/rofi.nix
    ../../hm/hyprland.nix
    ../../hm/hyprlock.nix
    ../../hm/waybar.nix
    ../../hm/ghostty.nix
    ../../hm/entries.nix
    ../../hm/starship.nix
    ../../hm/firefox.nix
    ../../hm/spicetify.nix

    spicetify-nix
  ];

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

programs.hyprlock = {
enable = true;
extraConfig = ''


# BACKGROUND
background {
    monitor =
    #path = screenshot
    path = /home/${username}/Downloads/andrea.png
    #color = $background
    blur_passes = 2
    contrast = 1
    brightness = 0.5
    vibrancy = 0.2
    vibrancy_darkness = 0.2
}

# GENERAL
general {
    no_fade_in = true
    no_fade_out = true
    hide_cursor = false
    grace = 0
    disable_loading_bar = true
}

# INPUT FIELD
input-field {
    monitor =
    size = 250, 60
    outline_thickness = 2
    dots_size = 0.2 # Scale of input-field height, 0.2 - 0.8
    dots_spacing = 0.35 # Scale of dots' absolute size, 0.0 - 1.0
    dots_center = true
    outer_color = rgba(0, 0, 0, 0)
    inner_color = rgba(0, 0, 0, 0.2)
    font_color = $foreground
    fade_on_empty = false
    rounding = -1
    check_color = rgb(204, 136, 34)
    placeholder_text = <i><span foreground="##cdd6f4">Input Password...</span></i>
    hide_input = false
    position = 0, -200
    halign = center
    valign = center
}

# DATE
label {
  monitor =
  text = cmd[update:1000] echo "$(date +"%A, %B %d")"
  color = rgba(242, 243, 244, 0.75)
  font_size = 22
  font_family = JetBrains Mono
  position = 0, 300
  halign = center
  valign = center
}

# TIME
label {
  monitor = 
  text = cmd[update:1000] echo "$(date +"%-I:%M")"
  color = rgba(242, 243, 244, 0.75)
  font_size = 95
  font_family = JetBrains Mono Extrabold
  position = 0, 200
  halign = center
  valign = center
}



# Profile Picture
image {
    monitor =
    path = /home/${username}/demi.jpg 
    size = 100
    border_size = 2
    border_color = $foreground
    position = 0, -100
    halign = center
    valign = center
}

# Desktop Environment
image {
    monitor =
    size = 75
    border_size = 2
    border_color = $foreground
    position = -50, 50
    halign = right
    valign = bottom
}

# CURRENT SONG
label {
    monitor =
    color = $foreground
    #color = rgba(255, 255, 255, 0.6)
    font_size = 18
    font_family = Metropolis Light, Font Awesome 6 Free Solid
    position = 0, 50
    halign = center
    valign = bottom
}

label {
    monitor =
    color = $foreground
    font_size = 14
    font_family = JetBrains Mono
    position = 0, -10
    halign = center
    valign = top
}

label {
    monitor =
    color = $foreground
    font_size = 24
    font_family = JetBrains Mono
    position = -90, -10
    halign = right
    valign = top
}

label {
    monitor =
    color = $foreground
    font_size = 24
    font_family = JetBrains Mono
    position = -20, -10
    halign = right
    valign = top
}
'';
  };



  programs.chromium = {
    package = pkgs.ungoogled-chromium;
    # package = pkgs.chromium;
    enable = true;
    extensions = [
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # ublock origin
      {id = "ghmbeldphafepmbegfdlkpapadhbakde";} # proton pass
      {id = "bapeomcobggcdleohggighcjbeeglhbn";} # proton pass
    ];
    commandLineArgs = ["--force-dark-mode"];
  };

  programs.git.extraConfig.init.defaultBranch = "main";
  programs.git.extraConfig.safe.directory = "/etc/nixos";
  programs.git.extraConfig.pull.rebase = false;
  programs.git = {
    enable = true;
    userName = "PJalv";
    userEmail = "pjalvbusiness@gmail.com";
  };

  programs.gh.enable = true;
  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.05";
  dconf.settings = {
    "org/gnome/desktop/interface" = {color-scheme = "prefer-dark";};
  };

  gtk = {
    enable = true;
    theme = {
      name = "Tokyonight-Dark";
      package = pkgs.tokyonight-gtk-theme;
    };

    font = {
      name = "Nunito";
      size = 10;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    gtk3.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
      gtk-application-prefer-dark-theme = 1;
    };

    gtk2.extraConfig = ''
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle="hintslight"
      gtk-xft-rgba="rgb"
      gtk-application-prefer-dark-theme=1
    '';
    cursorTheme = {
      name = "catppuccin-macchiato-dark-cursors";
      package = pkgs.catppuccin-cursors.macchiatoDark;
    };
  };

  home.pointerCursor = {
    name = "catppuccin-macchiato-dark-cursors";
    package = pkgs.catppuccin-cursors.macchiatoDark;
    size = 30;
    gtk.enable = true;
    x11.enable = true;
  };

  home.sessionVariables = {};
}
