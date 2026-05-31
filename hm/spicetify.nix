{ inputs, pkgs, ... }:
let
  # With flakes:
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};

  spicyLyrics = {
    name = "spicy-lyrics.mjs";
    src = "${pkgs.fetchFromGitHub {
      owner = "Spikerko";
      repo = "spicy-lyrics";
      rev = "5.19.10";
      hash = "sha256-l61QhYAAWymKcilIx5pyeQ1N58Z+Qfy4JhH7DW6CAJ0=";
    }}/builds";
  };
in
{
  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle # shuffle+ (special characters are sanitized out of extension names)
      beautifulLyrics
      spicyLyrics
    ];

    theme = spicePkgs.themes.catppuccin;
    alwaysEnableDevTools = true;
    colorScheme = "mocha";
  };
}
