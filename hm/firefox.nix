{ inputs, pkgs, config, ... }:

{
  programs.firefox = {
      enable = true;
      profiles.pjalv = {
          settings = {
            # Browser settings go here
          };
          extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
            ublock-origin
            tree-style-tab
          ];
	  # userChrome = builtins.readFile ./userChrome.css;
      };
  };
}
