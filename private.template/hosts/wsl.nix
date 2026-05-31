{lib, username ? "user", ...}: {
  wsl.defaultUser = lib.mkDefault username;
}
