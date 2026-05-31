{
  description = "NixOS and Home Manager configurations";

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
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
    handy.url = "github:cjpais/Handy";
    mex = {
      url = "github:PJalv/mex";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    private = {
      # Public-safe defaults live in private.template. Override this input with a
      # private flake for real host names, network topology, backup targets, and
      # identity values:
      #   nixos-rebuild switch --flake .#desktop --override-input private github:OWNER/nix-private
      url = "path:./private.template";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    nixos-wsl,
    handy,
    private,
    ...
  } @ inputs: let
    dotfilesDir = nixpkgs.legacyPackages.x86_64-linux.fetchgit {
      url = "https://github.com/PJalv/dotfiles.git";
      rev = "26cf90d1e388e03578bc63f951d6a5e4a1c6d660";
      sha256 = "sha256-mKiG0RJNh72+ppyz7q/5TiC1APVPjvgnhv/yLqXH30I=";
    };

    mkSpecialArgs = {machine, username}: {
      inherit machine username dotfilesDir inputs;
    };

    mkHomeManager = {machine, username, homeModule}: {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${username} = import homeModule;
      home-manager.extraSpecialArgs = mkSpecialArgs {inherit machine username;};
    };

    privateNixosModules = private.nixosModules or {};
    privateHomeModules = private.homeManagerModules or {};
    privateSystemModule = privateNixosModules.default or (_: {});
    privateHomeModule = privateHomeModules.default or (_: {});
  in {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = mkSpecialArgs {machine = "desktop"; username = "user";};
        modules = [
          ./modules/dotfiles.nix
          ./modules/optimization.nix
          ./modules/gaming.nix
          ./modules/pi-backup.nix
          ./users/primary/user.nix
          privateSystemModule
          home-manager.nixosModules.home-manager
          handy.nixosModules.default
          {
            networking.hostName = "desktop";
            programs.handy.enable = true;
          }
          (mkHomeManager {machine = "desktop"; username = "user"; homeModule = ./users/primary/hm.nix;})
        ];
      };

      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = mkSpecialArgs {machine = "laptop"; username = "user";};
        modules = [
          ./modules/dotfiles.nix
          ./modules/optimization.nix
          ./modules/gaming.nix
          ./users/primary/user.nix
          privateSystemModule
          home-manager.nixosModules.home-manager
          {networking.hostName = "laptop";}
          (mkHomeManager {machine = "laptop"; username = "user"; homeModule = ./users/primary/hm.nix;})
        ];
      };

      wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = mkSpecialArgs {machine = "wsl"; username = "user";};
        modules = [
          nixos-wsl.nixosModules.default
          {
            system.stateVersion = "24.05";
            wsl.enable = true;
            wsl.defaultUser = "user";
          }
          ./users/primary/wsl.nix
          privateSystemModule
          home-manager.nixosModules.home-manager
          (mkHomeManager {machine = "wsl"; username = "user"; homeModule = ./users/remote/hm.nix;})
        ];
      };
    };

    homeConfigurations = let
      username = "ubuntu";
      pkgs = import nixpkgs {system = "x86_64-linux";};
    in {
      ${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [./users/remote/hm.nix privateHomeModule];
        extraSpecialArgs = {
          inherit username dotfilesDir inputs;
        };
      };
    };
  };
}
