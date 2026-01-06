{
  config,
  pkgs,
  lib,
  username ? "remote",
  inputs,
  ...
}: let
in {
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.packages = with pkgs; [
    lua
    eza
    lazygit
    zoxide
    neovim
    fzf
    nixd
    ripgrep
    deno
    xdg-utils
    llvmPackages_20.clang-tools
    btop
    bat
    nodejs
    jq
    tmux
    pay-respects
    mosh
    alejandra
    tree-sitter
    inputs.opencode-flake.packages.${pkgs.system}.default
    inputs.opencode-flake.packages.${pkgs.system}.opencode-google-antigravity-auth
  ];
  imports = [../../hm/zsh.nix ../../hm/starship.nix];

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  programs.command-not-found.enable = true;

  programs.git.extraConfig.init.defaultBranch = "main";
  programs.git.extraConfig.pull.rebase = false;
  programs.git = {
    enable = true;
    userName = "Jorge Luis Suarez";
    userEmail = "jorge.suarez@tp-link.com";
  };
  programs.gh.enable = true;
  # The state version is required and should stay at the version you
  # originally installed.

  programs.home-manager.enable = true;
  home.sessionVariables = {};
  home.stateVersion = "24.11"; # Please read the comment before changing.
}
