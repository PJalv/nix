{
  description = "PJalv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty.url = "github:ghostty-org/ghostty";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  };

  outputs = { ghostty, self, nixpkgs, nix, nixos-hardware, home-manager
    , spicetify-nix, }@inputs: {
      nixosConfigurations = {
        pjalv-desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            machine = "desktop";
            username = "pjalv";
          };
          modules = [
            {
              environment.systemPackages =
                [ ghostty.packages.x86_64-linux.default ];
            }
            ./users/pjalv/user.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;
              home-manager.users.pjalv = import ./users/pjalv/hm.nix;
              home-manager.extraSpecialArgs = {
                machine = "desktop";
                username = "pjalv";
                inherit inputs;
              };
            }
          ];
        };
        pjalv-laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            machine = "laptop";
            username = "pjalv";
          };
          modules = [
            {
              environment.systemPackages =
                [ ghostty.packages.x86_64-linux.default ];
            }

            ./users/pjalv/user.nix
            home-manager.nixosModules.home-manager
            {

              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.pjalv = import ./users/pjalv/hm.nix;
              home-manager.extraSpecialArgs = {
                machine = "laptop";
                username = "pjalv";
                inherit inputs;
              };

            }
          ];
        };
      };
      homeConfigurations = let
        system = "x86_64-linux";
        username = "debian";
        pkgs = import nixpkgs { system = "x86_64-linux"; };
      in {
        "${username}" =
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;

            # Specify your home configuration modules here, for example,
            # the path to your home.nix.
            modules = [ ./users/remote/hm.nix ];
            extraSpecialArgs = { inherit username; };

            # Optionally use extraSpecialArgs
            # to pass through arguments to home.nix
          };
      };

    };

}
