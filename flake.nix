{
  description = "PJalv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty.url = "github:ghostty-org/ghostty";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs = { ghostty, self, nixpkgs, nix, nixos-hardware, nixos-wsl, home-manager
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
                [ ghostty.packages.x86_64-linux.default 
                ];
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
                [
                ghostty.packages.x86_64-linux.default
                ];
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
      pjalv-wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
          specialArgs = {
            machine = "wsl";
            username = "pjalv";
          };

        modules = [
          nixos-wsl.nixosModules.default
          {
            system.stateVersion = "24.05";
            wsl.enable = true;
            wsl.defaultUser = "pjalv";
          }

            {
              environment.systemPackages =
                [
                ];
            }
            ./users/pjalv/user.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.users.pjalv = import ./users/pjalv/hm.nix;
          }

        ];
      };
      work-wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
          specialArgs = {
            machine = "wsl";
            username = "jorge.suarez";
          };
        modules = [
          nixos-wsl.nixosModules.default
          {
            system.stateVersion = "24.05";
            wsl.enable = true;
            wsl.defaultUser = "jorge.suarez";
          }
        ./users/work/user.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.users."jorge.suarez" = import ./users/work/hm.nix;
          }

        ];
      };
      };
      homeConfigurations = let
        username = "pjalv";
        #pkgs = import nixpkgs { system = "x86_64-linux"; };
        pkgs = import nixpkgs { system = "aarch64-linux"; }; # For ARM-based systems
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
