{
  description = "PJalv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    ghostty.url = "github:ghostty-org/ghostty";
  };

  outputs =
    {
      ghostty,
      nixpkgs,
      home-manager,
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
                username = "pjalv"; 
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
            }
          ];
        };
      };
    };
}
