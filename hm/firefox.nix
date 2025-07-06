{ inputs, pkgs, config, ... }:

{
  programs.firefox = {
      enable = true;
      profiles.pjalv = {
          settings = {
            # Browser settings go here
          };
          extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
          ];
	  # userChrome = builtins.readFile ./userChrome.css;
      };
  };
}
