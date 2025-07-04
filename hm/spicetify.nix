{ inputs, pkgs, ... }:
let
  # With flakes:
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{
  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle # shuffle+ (special characters are sanitized out of extension names)
      ({
        src = pkgs.fetchFromGitHub
          {
            owner = "spikerko";
            repo = "spicy-lyrics";
            rev = "71d78660557708bae0b1d68d225a06a72d9c524a";
            hash = "sha256-LuuHtk3ebkPLnbc9qtKm/iN5B2WrtVwNDuRhENLHspM=";
          } + /src;
        name = "app.tsx";

      })
    ];
    theme = spicePkgs.themes.catppuccin;
    alwaysEnableDevTools = true;
    colorScheme = "mocha";
  };
}
