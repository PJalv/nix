{ config, lib, pkgs, ... }:

{
  # Persistent binderfs mount for Android container runtimes (redroid).
  #
  # redroid (used by the DPI test suite under helperScripts/dpi_gen/) needs
  # /dev/binderfs exposed to containers for Android's binder IPC. Without a
  # declarative mount the kernel-provided binder filesystem disappears on every
  # reboot and a privileged docker helper has to re-mount it by hand. Declaring
  # it here makes systemd mount it at boot, so containers and the bring-up
  # script can rely on it being present.
  #
  # The binder filesystem is built into the kernel (CONFIG_ANDROID_BINDERFS);
  # the default mount is sufficient (binder + binder-control + features, max
  # transaction size 1 MiB) - no extra options are required for redroid.
  fileSystems."/dev/binderfs" = {
    device = "binder";
    fsType = "binder";
    options = [ "mode=0755" ];
  };
}
