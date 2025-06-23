{ config, pkgs, lib, machine ? "desktop", username ? "jorge.suarez", inputs, ... }:
let


in {

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
    sassc
    zoxide
    tmux
    apacheHttpd
    xdg-utils
    opencode
  ];

  imports = [
    ../../hm/zsh.nix
    ../../hm/starship.nix
  ];

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };


  programs.git.extraConfig.init.defaultBranch = "main";
  programs.git.extraConfig.safe.directory = "/etc/nixos";
  programs.git.extraConfig.pull.rebase = false;
  programs.git = {
    enable = true;
    userName = "jorge.suarez";
    userEmail = "jorge.suarez@tp-link.com";
  };

  programs.gh.enable = true;
  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.05";



  home.sessionVariables = { };
}

