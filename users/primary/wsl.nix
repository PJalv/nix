{
  config,
  lib,
  pkgs,
  machine ? "wsl",
  username ? "user",
  inputs,
  ...
}: let
  # Define base packages that are common to both laptop and desktop
  basePackages = with pkgs; [
    vim
    neovim
    wget
    gnumake
    basedpyright
    clang
    clang-tools
    git
    gopls
    lua-language-server
    nixd
    compiledb
    btop
    home-manager
    eza
    bc
    unzip
    direnv
    gcc
    killall
    fzf
    zoxide
    ripgrep
    gnupg
    pinentry-all
    pinentry-all
  ];
  # Define laptop-specific packages
in {
  # We'll use the passed-in parameters instead of defining options
  config = lib.mkMerge [
    # Common configuration
    {
      networking.hostName = lib.mkDefault machine;
      networking.networkmanager.enable = true;

      time.timeZone = "America/Los_Angeles";
      i18n.defaultLocale = "en_US.UTF-8";

      programs = {
        zsh.enable = true;
        gnupg.agent = {
          enable = true;
          pinentryPackage = pkgs.pinentry-curses;
        };
      };

      users.users.${username} = {
        isNormalUser = true;
        extraGroups = ["docker" "wheel" "input" "network" "dialout" "networkmanager" "ydotool"];
        shell = pkgs.zsh;
      };
      users.defaultUserShell = pkgs.zsh;
      virtualisation.docker.enable = true;

      nix.settings.experimental-features = ["nix-command" "flakes"];
      nixpkgs.config.allowUnfree = true;

      services.openssh.enable = true;
      networking.firewall.allowedUDPPorts = [51820];

      environment.systemPackages = basePackages;

      system.stateVersion = "24.05";
    }
  ];
}
