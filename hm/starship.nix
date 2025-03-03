{ config, pkgs, ... }: {
  home.sessionVariables.STARSHIP_CACHE = "${config.xdg.cacheHome}/starship";

  programs.starship = {

    enable = true;
    enableZshIntegration = true;
    settings = pkgs.lib.importTOML ./dots/starship.toml;

  };

}
