{lib, username ? "user", ...}: {
  networking.hostName = lib.mkDefault "desktop";

  # Example for a private flake override:
  # networking.hosts = {
  #   "192.0.2.10" = ["internal.example.invalid"];
  # };

  services.piBackup = {
    enable = lib.mkDefault false;
    user = lib.mkDefault username;
    sourceDir = lib.mkDefault "/home/${username}/backup-source";
    piHost = lib.mkDefault "backup-host.local";
    piUser = lib.mkDefault "backup";
    destRoot = lib.mkDefault "/srv/backups/desktop";
    timer.enable = lib.mkDefault false;
  };
}
