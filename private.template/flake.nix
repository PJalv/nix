{
  description = "Public-safe private configuration template";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {...}: {
    usernames = {
      desktop = "user";
      laptop = "user";
      wsl = "user";
    };

    nixosModules.default = {lib, machine ? "desktop", username ? "user", ...}: {
      imports = [./hosts/${machine}.nix];

      users.users.${username}.description = lib.mkDefault "NixOS User";
    };

    homeManagerModules.default = {lib, ...}: {
      programs.git.settings = {
        user.name = lib.mkDefault "NixOS User";
        user.email = lib.mkDefault "user@example.invalid";
      };
    };
  };
}
