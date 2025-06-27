{
  description = "PJalv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty.url = "github:ghostty-org/ghostty?ref=v1.1.3";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs =
    { ghostty
    , self
    , nixpkgs
    , nix
    , nixos-hardware
    , home-manager
    , spicetify-nix
    , nixos-wsl
    ,
    }@inputs: {
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
          ./users/pjalv/wsl.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.pjalv = import ./users/remote/hm.nix;
            home-manager.extraSpecialArgs = {
              machine = "wsl";
              username = "pjalv";
              inherit inputs;
            };
          }
        ];
      };
      };
      homeConfigurations =
        let
          username = "pjalv";
          #pkgs = import nixpkgs { system = "x86_64-linux"; };
          pkgs = import nixpkgs { system = "aarch64-linux"; }; # For ARM-based systems
        in
        {
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
