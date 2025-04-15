{ config, lib, pkgs, machine ? "wsl", username ? "pjalv", inputs, ... }:
let

  # Define base packages that are common to both laptop and desktop
  basePackages = with pkgs; [
    vim
    neovim
    wget
    wireshark
    networkmanagerapplet
    gnumake
    wireguard-tools
    lxqt.lxqt-policykit
    liberation_ttf
    basedpyright
    clang
    clang-tools
    cargo
    git
    basedpyright
    gopls
    lua-language-server
    nixd
    compiledb
    btop
    home-manager
    minicom
    mako
    libnotify
    wl-clipboard
    swappy
    grim
    copyq
    eza
    bc
    unzip
    slurp
    emote
    direnv
    gcc
    playerctl
    fzf
    zoxide
    ripgrep
    libreoffice
    vlc
  ];

in {
  # We'll use the passed-in parameters instead of defining options
  config = lib.mkMerge [
    # Common configuration
    {

      networking.hostName = "pjalv-${machine}";
      networking.networkmanager.enable = true;
      services.gvfs.enable = true; # Mount, trash, and other functionalities


      time.timeZone = "America/Los_Angeles";
      i18n.defaultLocale = "en_US.UTF-8";


      programs = {
        zsh.enable = true;
      };

      users.defaultUserShell = pkgs.zsh;

      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nixpkgs.config.allowUnfree = true;
      hardware.pulseaudio.enable = false;
      security = {
        rtkit.enable = true;
        polkit.enable = true;
      };


      services.openssh.enable = true;
      networking.firewall.allowedUDPPorts = [ 51820 ];

      environment.systemPackages = basePackages;

      system.stateVersion = "24.05";
    }
  ];
}
