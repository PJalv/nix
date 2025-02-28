{
  description = "PJalv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    ghostty.url = "github:ghostty-org/ghostty";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  };

  outputs =
    {
      ghostty,
      self,
      nixpkgs,
      nix,
      nixos-hardware,
      home-manager,
      spicetify-nix,
    }:
    {
      nixosConfigurations = {
        pjalv-desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { 
            machine = "desktop";
            username = "pjalv";
          };
          modules = [
            {
              environment.systemPackages = [
                ghostty.packages.x86_64-linux.default
              ];
            }
            ./users/pjalv/user.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.users.pjalv = import ./users/pjalv/hm.nix;
              home-manager.extraSpecialArgs = { 
                machine = "desktop";
                inherit spicetify-nix;
                username = "pjalv"; 
              };
              home-manager.specialArgs = {
                inherit spicetify-nix;
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
              environment.systemPackages = [
                ghostty.packages.x86_64-linux.default
              ];
            }

            ./users/pjalv/user.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.users.pjalv = import ./users/pjalv/hm.nix;
              home-manager.extraSpecialArgs = { 
                machine = "laptop";
                username = "pjalv"; 
              };
              home-manager.sharedModules = [spicetify-nix.homeManagerModule.default];

            }
          ];
        };
      };
    };
}
