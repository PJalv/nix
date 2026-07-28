{
  config,
  pkgs,
  lib,
  ...
}: {
  # Garbage collection and store optimization
  # Automatically cleans up old packages and optimizes store

  options.optimization = {
    enable = lib.mkOption {
      default = true;
      description = "Enable optimization settings";
    };
  };

  config = lib.mkIf config.optimization.enable {
    nix = {
      # Automatic garbage collection
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      # Automatically optimize the Nix store
      settings = {
        auto-optimise-store = true;
        # Binary cache configuration for faster builds
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://cache.numtide.com"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];

        # Maximum number of simultaneous builds/downloads
        max-jobs = "auto";
        cores = 0; # Use all cores

        # Keep builds running even when using cached results
        keep-outputs = true;
        keep-derivations = true;
      };

      # Extra options for optimization
      extraOptions = ''
        min-free = 512M
        max-free = 5120M
      '';
    };
  };
}
