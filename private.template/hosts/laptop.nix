{lib, username ? "user", ...}: {
  networking.hostName = lib.mkDefault "laptop";

  users.users.${username}.description = lib.mkDefault "Laptop user";
}
