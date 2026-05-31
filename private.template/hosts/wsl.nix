{lib, username ? "user", ...}: {
  wsl.defaultUser = lib.mkDefault username;

  users.users.${username}.description = lib.mkDefault "WSL user";
}
