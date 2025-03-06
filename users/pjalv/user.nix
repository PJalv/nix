{ config, lib, pkgs, machine ? "desktop", username ? "pjalv", inputs, ... }:
let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  session = "${pkgs.hyprland}/bin/Hyprland"; # Fixed typo here

  # Define base packages that are common to both laptop and desktop
  basePackages = with pkgs; [
    vim
    neovim
    wget
    networkmanagerapplet
    gnumake
    wireguard-tools
    lxqt.lxqt-policykit
    liberation_ttf
    basedpyright
    clang
    clang-tools
    cargo
    git
    basedpyright
    gopls
    lua-language-server
    nixd
    compiledb
    btop
    home-manager
    minicom
    mako
    libnotify
    wl-clipboard
    swappy
    grim
    copyq
    eza
    bc
    unzip
    slurp
    emote
    direnv
    gcc
    playerctl
    fzf
    zoxide
    ripgrep
    kitty
    waybar
    vesktop
    rofi-wayland
    rofi
    vial
    pavucontrol
    pulseaudio
    obs-studio
    spotify
    stm32cubemx
    xfce.thunar
    xfce.tumbler
    libreoffice
    vlc
    (import ../../hm/macropad.nix pkgs)
  ];

  # Define laptop-specific packages
  laptopPackages = with pkgs; [
    acpi
    brightnessctl
    fusuma
    catppuccin-sddm-corners
  ];

  # Define desktop-specific packages
  desktopPackages = with pkgs; [
    bottles
    steam-rom-manager
    # stm32cubemx
    # openocd
    # kdePackages.kdeconnect-kde
  ];
in {
  # We'll use the passed-in parameters instead of defining options
  imports = [ ./${machine}/hardware-configuration.nix ];
  config = lib.mkMerge [
    # Common configuration
    {

      networking.hostName = "pjalv-${machine}";
      networking.networkmanager.enable = true;
      hardware.keyboard.qmk.enable = true;
      hardware.bluetooth.enable = true;
      hardware.bluetooth.package = pkgs.bluez;
      hardware.bluetooth.input.General.ClassicBondedOnly = false;
      services.blueman.enable = true;
      hardware.bluetooth.powerOnBoot = true;

      boot = {
        loader = {
          systemd-boot.enable = false;
          grub = {
            enable = true;
            device = "nodev";
            useOSProber = true;
            efiSupport = true;
          };
          efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint =
              if machine == "laptop" then "/boot" else "/boot/efi";
          };
        };
        kernelPackages = pkgs.linuxPackages_latest;
      };

      time.timeZone = "America/Los_Angeles";
      i18n.defaultLocale = "en_US.UTF-8";

      services = {
        xserver.enable = true;
        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };
      };

      programs = {
        hyprland = {
          enable = true;
          xwayland.enable = true;
        };
        zsh.enable = true;
        ydotool = {
          enable = true;
          };
      };
      virtualisation.docker.enable = true;

      users.users.${username} = {
        isNormalUser = true;
        extraGroups =
          [ "wheel" "input" "network" "dialout" "docker" "networkmanager" "ydotool" ];
        shell = pkgs.zsh;
      };
      users.defaultUserShell = pkgs.zsh;

      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nixpkgs.config.allowUnfree = true;
      hardware.pulseaudio.enable = false;
      security = {
        rtkit.enable = true;
        polkit.enable = true;
      };

      fonts.packages = with pkgs; [
        font-awesome
        noto-fonts-cjk-sans
        nerd-fonts.fira-code
      ];

      services.openssh.enable = true;
      networking.firewall.allowedUDPPorts = [ 51820 ];

      environment.systemPackages = basePackages;

      system.stateVersion = "24.05";
    }

    # Desktop-specific configuration
    (lib.mkIf (machine == "desktop") {
      services.greetd = {
        enable = true;
        settings = {
          initial_session = {
            command = "${session}";
            user = "${username}";
          };
          default_session = {
            command =
              "${tuigreet} --greeting 'Welcome to Desktop' --asterisks --remember --remember-user-session --time -d -cmd Hyprland";
            user = "greeter";
          };
        };
      };

      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };

      networking.interfaces = {
        enp8s0 = {
          wakeOnLan.enable = true;
          useDHCP = true;
        };
      };

      environment.systemPackages = desktopPackages;
    })

    # Laptop-specific configuration
    (lib.mkIf (machine == "laptop") {
      services = {
        displayManager.sddm = {
          enable = true;
          theme = "catppuccin-sddm-corners";
        };
        power-profiles-daemon.enable = true;
        libinput.enable = true;
      };

      environment.systemPackages = laptopPackages;
    })
  ];
}
