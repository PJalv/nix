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
    browser-previews = {
      url = "github:nix-community/browser-previews";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    browser-nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
    mex = {
      url = "github:PJalv/mex";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    t3code-nightly.url = "github:PJalv/t3code-nightly-flake";
    ketch = {
      url = "github:PJalv/ketch/nix-flake";
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
      home-manager.users.${username} = {
        imports = [homeModule privateHomeModule];
      };
      home-manager.extraSpecialArgs = mkSpecialArgs {inherit machine username;};
    };

    privateNixosModules = private.nixosModules or {};
    privateHomeModules = private.homeManagerModules or {};
    privateSystemModule = privateNixosModules.default or (_: {});
    privateHomeModule = privateHomeModules.default or (_: {});
    privateUsernames = private.usernames or {};

    usernameFor = machine: privateUsernames.${machine} or "user";

    mkNixosSystem = {
      machine,
      extraModules ? [],
      homeModule,
      username ? usernameFor machine,
    }:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = mkSpecialArgs {inherit machine username;};
        modules =
          extraModules
          ++ [
            ./users/primary/user.nix
            privateSystemModule
            home-manager.nixosModules.home-manager
            (mkHomeManager {inherit machine username homeModule;})
          ];
      };
  in {
    nixosConfigurations = {
      desktop = mkNixosSystem {
        machine = "desktop";
        homeModule = ./users/primary/hm.nix;
        extraModules = [
          ./modules/dotfiles.nix
          ./modules/optimization.nix
          ./modules/gaming.nix
          ./modules/pi-backup.nix
          ./modules/work-ip-publisher.nix
          {networking.hostName = "desktop";}
        ];
      };

      laptop = mkNixosSystem {
        machine = "laptop";
        homeModule = ./users/primary/hm.nix;
        extraModules = [
          ./modules/dotfiles.nix
          ./modules/optimization.nix
          ./modules/gaming.nix
          {networking.hostName = "laptop";}
        ];
      };

      wsl = let
        machine = "wsl";
        username = usernameFor machine;
      in nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = mkSpecialArgs {inherit machine username;};
        modules = [
          nixos-wsl.nixosModules.default
          {
            system.stateVersion = "24.05";
            wsl.enable = true;
            wsl.defaultUser = username;
          }
          ./users/primary/wsl.nix
          privateSystemModule
          home-manager.nixosModules.home-manager
          (mkHomeManager {inherit machine username; homeModule = ./users/remote/hm.nix;})
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
