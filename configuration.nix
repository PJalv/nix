{ config, lib, pkgs, ... }:
let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  session = "${pkgs.hyprland}/bin/Hyprland";  # Fixed typo here

  # Define base packages that are common to both laptop and desktop
  basePackages = with pkgs;
    [
      vim
      neovim
      wget
      networkmanagerapplet
      wireguard-tools
      lxqt.lxqt-policykit
      liberation_ttf
      basedpyright
      clang
      clang-tools
      git
      ghostty
      gnumake
      gopls
      lua-language-server
      btop
      home-manager
      minicom
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
      kitty
      waybar
      vesktop
      rofi-wayland
      rofi
      pavucontrol
      pulseaudio
      obs-studio
      spotify
      xfce.thunar
      xfce.tumbler
      libreoffice
      vlc
      (import ./macropad.nix)
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
    stm32cubemx
    openocd
    kdePackages.kdeconnect-kde
    # stm32cubemx
    # openocd
    # kdePackages.kdeconnect-kde
  ];
in
{
  imports = [
    ./hardware-configuration.nix
    ./home.nix
  ];
  options = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "pjalv";
      description = "Primary user of the system";
    };

    machine = lib.mkOption {
      type = lib.types.str;
      default = "laptop";
      description = "Machine identifier";
    };
  };

  config = lib.mkMerge [
    # Common configuration
    {
      networking.hostName = "pjalv-${config.machine}";
      networking.networkmanager.enable = true;

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
            efiSysMountPoint = "/boot";
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
      };

      users.users.${config.username} = {
        # Access username option
        isNormalUser = true;
        extraGroups = [ "wheel" "input" "network" "dialout" "networkmanager" ];
        shell = pkgs.zsh;
      };

      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nixpkgs.config.allowUnfree = true;
      hardware.pulseaudio.enable = false;
      security = {
        rtkit.enable = true;
        polkit.enable = true;
      };

      fonts.packages = with pkgs; 
        [
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
    (lib.mkIf (config.machine == "desktop") {
      # Access machine option
      services.greetd = {
        enable = true;
        settings = {
          initial_session = {
            command = "${session}";
            user = "${config.username}"; # Access username option
          };
          default_session = {
            command = "${tuigreet} --greeting 'Welcome to Desktop' --asterisks --remember --remember-user-session --time -d -cmd Hyprland";
            user = "greeter";
          };
        };
      };

      # services.xserver.enable = true;
      # services.displayManager.sddm.enable = true;
      # services.desktopManager.plasma6.enable = true;
      networking.interfaces = {
        enp8s0 = {
          wakeOnLan.enable = true;
          useDHCP = true;
        };
      };

      environment.systemPackages = desktopPackages;
    })

    # Laptop-specific configuration
    (lib.mkIf (config.machine == "laptop") {
      # Access machine option
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

