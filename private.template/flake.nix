{
  description = "Public-safe private configuration template";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {...}: {
    usernames = {
      desktop = "pjalv";
      laptop = "pjalv";
      wsl = "pjalv";
    };

    nixosModules.default = {lib, machine ? "desktop", username ? "user", ...}: {
      imports = [./hosts/${machine}.nix];

      users.users.${username}.description = lib.mkDefault "PJalv";
    };

    homeManagerModules.default = {lib, ...}: {
      programs.git.settings = {
        user.name = lib.mkForce "Jorge Luis Suarez";
        user.email = lib.mkForce "jorge.suarez@tp-link.com";
      };
    };
  };
}
