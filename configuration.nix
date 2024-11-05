# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      #./home.nix
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  networking.hostName = "desktop-nixos"; # Define your hostna    boot.loader.systemd-boot.enable = false;

boot.loader.grub.enable = true;
boot.loader.grub.device = "nodev";
boot.loader.grub.useOSProber = true; 
  boot.loader.grub.efiSupport = true;
boot.loader.efi.canTouchEfiVariables = true;
boot.loader.efi.efiSysMountPoint = "/boot";


boot.kernelPackages = pkgs.linuxPackages_latest;
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.displayManager.sddm = {
  enable = true;
  theme = "catppuccin-sddm-corners";
};
  services.xserver.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  programs.zsh.enable = true;

  users.users.pjalv.shell = pkgs.zsh;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

# services.envfs.enable = true;


  # Enable sound.
  # sound.enable = true;
  hardware.pulseaudio.enable = false;
  # OR
  #

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  services.power-profiles-daemon.enable = true;
  # services.auto-cpufreq.enable = true;
  # services.auto-cpufreq.settings = {
  #   battery = {
  #     governor = "powersave";
  #     turbo = "never";
  #   };
  #   charger = {
  #     governor = "performance";
  #     turbo = "auto";
  #   };
  # };
  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

security.polkit.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pjalv = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" "network"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
      tree
      fusuma
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Editors
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    neovim
    chromium
    libreoffice

    # Networking
    wget
    networkmanagerapplet
    wireguard-tools
    lxqt.lxqt-policykit

    liberation_ttf


    # Development Tools
    clang
    clang-tools
    cargo
    git
    gnumake
    go
    templ
    stm32cubemx
    openocd
    zig

    (python312.withPackages (pypkgs: with pypkgs;[
      compiledb
    ]))
    # Utilities
    btop
    home-manager
    minicom
    acpi
    mako
    libnotify
    wl-clipboard
    gwenview
    grim
    copyq
    bc
    unzip
    slurp
    gcc
    playerctl
    fzf
    zoxide
    ripgrep
    brightnessctl

    # Appearance
    kitty
    waybar
    vesktop
    rofi-wayland
    rofi
    catppuccin-sddm-corners

    # Audio
    pavucontrol
    pulseaudio
    spotify
    # File Management
    xfce.thunar
    xfce.tumbler
  ];
  fonts.packages = with pkgs; [ 
    #nerdfonts
  #(nerdfonts.override { fonts = [ "FiraCode" ]; })
    font-awesome
    noto-fonts-cjk-sans
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall = {
    allowedUDPPorts = [ 51820 ]; # Clients and peers can use the same port, see listenport
  };


  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}
