{
  description = "PJalv";

  inputs = {
    nixpkgs.url        = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    ghostty.url = "github:ghostty-org/ghostty";
  };

  outputs = { self, nixpkgs, nix, nixos-hardware, home-manager }: {

    nixosConfigurations = {
      pjalv-desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./users/pjalv/user.nix
          home-manager.nixosModules.home-manager {
            home-manager.useUserPackages = true;
            home-manager.users.pjalv = import ./users/pjalv/hm.nix;
          }
        ];
      };
      pjalv-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
           ./users/pjalv/user.nix
          home-manager.nixosModules.home-manager {
            home-manager.useUserPackages = true;
            home-manager.users.pjalv = import ./users/pjalv/hm.nix;
          }
        ];
      };
    };
  };
}
