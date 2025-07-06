{ config, pkgs, lib, machine ? "desktop", username ? "pjalv", inputs, ... }:
let
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

in
{
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
      "x-scheme-handler/http" = [ "chromium-browser.desktop" ];
      "x-scheme-handler/https" = [ "chromium-browser.desktop" ];
      "text/html" = [ "chromium-browser.desktop" ];
      "application/pdf" = [ "chromium-browser.desktop" ];
    };
    defaultApplications = {
      "x-scheme-handler/http" = [ "chromium-browser.desktop" ];
      "x-scheme-handler/https" = [ "chromium-browser.desktop" ];
      "text/html" = [ "chromium-browser.desktop" ];
      "application/pdf" = [ "chromium-browser.desktop" ];
    };
  };

  home.packages = with pkgs; [
    lazygit
    swww
    sassc
    gtk-engine-murrine
    gtk_engines
    gnome-themes-extra
    zoxide
    jq
    syspower
  ];

  imports = [
    ../../hm/zsh.nix
    ../../hm/rofi.nix
    ../../hm/hyprland.nix
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

  programs.chromium = {
    enable = true;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "ghmbeldphafepmbegfdlkpapadhbakde"; } # proton pass
    ];
    commandLineArgs = [ "--force-dark-mode" ];
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
    "org/gnome/desktop/interface" = { color-scheme = "prefer-dark"; };
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

  home.sessionVariables = { };
}

