{ inputs, pkgs, ... }:
let spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in {
  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      beautifulLyrics
      hidePodcasts
      shuffle # shuffle+ (special characters are sanitized out of extension names)
  ({
      # The source of the extension
      # make sure you're using the correct branch
      # It could also be a sub-directory of the repo
      src = (pkgs.fetchFromGitHub {
  owner = "spikerko";
  repo = "spicy-lyrics";
  rev = "71d78660557708bae0b1d68d225a06a72d9c524a";
  hash = "sha256-LuuHtk3ebkPLnbc9qtKm/iN5B2WrtVwNDuRhENLHspM=";
})+ /src;
      # The actual file name of the extension usually ends with .js
      name = "app.tsx";
  })
    ];
    alwaysEnableDevTools = true;
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";
  };
}
