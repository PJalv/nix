{
  description = "PJalv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opencode-flake = {
      url = "github:PJalv/opencode-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nur,
    firefox-addons,
    spicetify-nix,
    nixos-wsl,
    opencode-flake,
  } @ inputs: let
    # Shared dotfiles repository
    dotfilesRepo = nixpkgs.legacyPackages.x86_64-linux.fetchgit {
      url = "https://github.com/PJalv/dotfiles.git";
      rev = "296e0a345840c58e8b8e28eb9e564a283adc003e";
      sha256 = "sha256-Xc0bu3me8YuHwt4xZ8+juOndO0sS4IUwU0ql60s5GNc=";
    };
    dotfilesDir = dotfilesRepo;
  in {
    nixosConfigurations = {
      pjalv-desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          machine = "desktop";
          username = "pjalv";
          inherit dotfilesDir inputs;
        };
        modules = [
          ./modules/dotfiles.nix
          ./modules/optimization.nix
          ./users/pjalv/user.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.useGlobalPkgs = true;
            home-manager.users.pjalv = import ./users/pjalv/hm.nix;
            home-manager.extraSpecialArgs = {
              machine = "desktop";
              username = "pjalv";
              inherit dotfilesDir inputs;
            };
          }
        ];
      };
      pjalv-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          machine = "laptop";
          username = "pjalv";
          inherit dotfilesDir inputs;
        };
        modules = [
          ./modules/dotfiles.nix
          ./modules/optimization.nix
          ./users/pjalv/user.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.pjalv = import ./users/pjalv/hm.nix;
            home-manager.extraSpecialArgs = {
              machine = "laptop";
              username = "pjalv";
              inherit dotfilesDir inputs;
            };
          }
        ];
      };
      pjalv-wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          machine = "wsl";
          username = "pjalv";
          inherit dotfilesDir inputs;
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
              inherit dotfilesDir inputs;
            };
          }
        ];
      };
    };
    homeConfigurations = let
      username = "ubuntu";
      pkgs = import nixpkgs {system = "x86_64-linux";};
      # pkgs = import nixpkgs {system = "aarch64-linux";}; # For ARM-based systems
    in {
      "${username}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
       # the path to your home.nix.
        modules = [./users/remote/hm.nix];
        extraSpecialArgs = {
          inherit username dotfilesDir inputs;
        };

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
  };
}
