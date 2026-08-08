{inputs, pkgs, config, username ? "user", ...}:

{
  programs.firefox = {
      enable = true;
      package = inputs.browser-nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.firefox;
      profiles.${username} = {
          settings = {
            # Browser settings go here
          };
          extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
            ublock-origin
            tree-style-tab
            proton-pass
          ];
	  # userChrome = builtins.readFile ./userChrome.css;
      };
  };
}
