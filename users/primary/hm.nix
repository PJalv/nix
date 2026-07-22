{
  config,
  pkgs,
  lib,
  machine ? "desktop",
  username ? "user",
  inputs,
  dotfilesDir,
  ...
}: let
  spicetify-nix = inputs.spicetify-nix.homeManagerModules.default;
in {
  xdg.configFile = {
    wallpaper.source = "${dotfilesDir}/.config/wallpaper";
    fusuma.source = "${dotfilesDir}/.config/fusuma";
    mako.source = "${dotfilesDir}/.config/mako";
    styles.source = "${dotfilesDir}/.config/waybar";
  };

  home.file.".config/hypr/load-wallpaper.sh" = {
    source = ../../hm/scripts/load-wallpaper.sh;
    executable = true;
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
    wtype
    tmux
    zoxide
    nwg-displays
    nodejs
    wezterm
    obsidian

    deskflow
    tree-sitter

    jq
    git-repo
    syspower
    easyeffects
    inputs.llm-agents.packages.${pkgs.system}.opencode
    inputs.t3code-nightly.packages.${pkgs.system}.t3code
    inputs.llm-agents.packages.${pkgs.system}.rtk
    inputs.llm-agents.packages.${pkgs.system}.omp
    inputs.llm-agents.packages.${pkgs.system}.codex
    inputs.mex.packages.${pkgs.system}.default
  ];

  imports = [
    ../../hm/zsh.nix
    ../../hm/rofi.nix
    ../../hm/hypridle.nix
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
  services.kdeconnect.enable = true;


  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.chromium = {
    #package = pkgs.ungoogled-chromium;
    package = pkgs.google-chrome;
    enable = true;
    extensions = [
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # ublock origin
      {id = "ghmbeldphafepmbegfdlkpapadhbakde";} # proton pass
      {id = "bapeomcobggcdleohggighcjbeeglhbn";} # proton pass
    ];
    commandLineArgs = ["--force-dark-mode"];
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = lib.mkDefault "NixOS User";
      user.email = lib.mkDefault "user@example.invalid";
      init.defaultBranch = "main";
      pull.rebase = true;
      rebase.autoStash = true;
    };
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

  home.sessionVariables = lib.mkForce {
    NIX_XDG_DESKTOP_PORTAL_DIR = "/run/current-system/sw/share/xdg-desktop-portal/portals";
  };
}
