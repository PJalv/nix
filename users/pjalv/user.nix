{
  config,
  lib,
  pkgs,
  machine ? "desktop",
  username ? "pjalv",
  inputs,
  ...
}: let
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
  session = "${pkgs.hyprland}/bin/start-hyprland"; # Fixed typo and use start-hyprland

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
    atftp
    killall
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
    dnsmasq
    nftables
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
    # stremio
    fzf
    zoxide
    ripgrep
    kitty
    waybar
    vesktop
    rofi
    vial
    pavucontrol
    pulseaudio
    hyprlock
    obs-studio
    xdg-desktop-portal
    spotify
    xfce.thunar
    xfce.tumbler
    libreoffice
    vlc
    gnupg
    pinentry-all
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
    soundwireserver
    lutris
    # stm32cubemx
    # openocd
    # kdePackages.kdeconnect-kde
  ];
in {
  # We'll use the passed-in parameters instead of defining options
  imports = [./${machine}/hardware-configuration.nix];
  config = lib.mkMerge [
    # Common configuration
    {
      networking.hostName = "smighty";
      networking.networkmanager.enable = true;
      hardware.keyboard.qmk.enable = true;
      hardware.bluetooth.enable = true;
      hardware.bluetooth.package = pkgs.bluez;
      hardware.bluetooth.input.General.ClassicBondedOnly = false;
      services.blueman.enable = true;
      hardware.bluetooth.powerOnBoot = true;
      services.gvfs.enable = true; # Mount, trash, and other functionalities
      services.tumbler.enable = true; # Thumbnail support for images
      services.udev = {
        packages = with pkgs; [
          qmk
          qmk-udev-rules
          qmk_hid
          via
          vial
        ];
      };
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
              if machine == "laptop"
              then "/boot"
              else "/boot/efi";
          };
        };
        supportedFilesystems = ["ntfs"];
        kernelPackages = pkgs.linuxPackages_latest;
        extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
        extraModprobeConfig = ''
          options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
        '';
        kernelModules = ["v4l2loopback"];
        kernel.sysctl = {
          "net.ipv4.ip_forward" = 1;
        };
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
      services.tftpd = {
        enable = true;
        path = "/var/lib/tftpboot";
      };

      programs = {
        hyprland = {
          enable = true;
          xwayland.enable = true;
        };
        zsh.enable = true;
        gnupg.agent = {
          enable = true;
          pinentryPackage = pkgs.pinentry-curses;
        };
        ydotool = {
          enable = true;
        };
      };

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true; # often helps overall portal reliability

        extraPortals = with pkgs; [
          xdg-desktop-portal-hyprland # fallback / GTK-based, usually has InputCapture
          # If on Plasma: kdePackages.xdg-desktop-portal-kde
          # If on GNOME: xdg-desktop-portal-gnome
        ];

        # Optional: force GTK portal for InputCapture (some compositors need explicit preference)
        config.common = {
          "org.freedesktop.impl.portal.InputCapture" = ["gtk"];
        };
      };
      users.users.${username} = {
        isNormalUser = true;
        extraGroups = ["wheel" "docker" "input" "network" "dialout" "networkmanager" "ydotool"];
        shell = pkgs.zsh;
      };
      virtualisation.docker.enable = true;
      users.defaultUserShell = pkgs.zsh;

      nix.settings.experimental-features = ["nix-command" "flakes"];
      nixpkgs.config.allowUnfree = true;
      # hardware.pulseaudio.enable = true;
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
      networking.firewall.allowedUDPPorts = [51820 69];

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
            command = "${tuigreet} --greeting 'Welcome to Desktop' --asterisks --remember --remember-user-session --time -d -cmd start-hyprland";
            user = "greeter";
          };
        };
      };
      programs = {
        tuxclocker = {
          enable = true;
          useUnfree = false;
        };
      };
      hardware.amdgpu.overdrive.enable = true;
      hardware.graphics.enable32Bit = true;
      virtualisation.waydroid.enable = false;
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };

      networking.interfaces = {
        enp11s0 = {
          wakeOnLan.enable = true;
          useDHCP = true;
          ipv4.addresses = [
            {
              address = "192.0.100.105";
              prefixLength = 24;
            }
          ];
        };
      };

      environment.systemPackages = desktopPackages;
    })

    # Laptop-specific configuration
    (lib.mkIf (machine == "laptop") {
      services = {
        displayManager.sddm = {
          package = pkgs.kdePackages.sddm;
          extraPackages = with pkgs; [
            kdePackages.qt5compat
          ];
          enable = true;
          theme = "catppuccin-sddm-corners";
          wayland.enable = true;
        };
        power-profiles-daemon.enable = true;
        libinput.enable = true;
        logind.settings.Login = {
          HandleLidSwitch = "suspend";
          HandleLidSwitchDocked = "ignore";
        };
        hypridle.enable = true;
      };

      environment.systemPackages = laptopPackages;
    })
  ];
}
