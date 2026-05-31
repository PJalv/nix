{ config, lib, pkgs, ... }:

let
  # Custom ds4drv package with Python 3.13 patches
  ds4drv-patched = pkgs.python3Packages.ds4drv.overridePythonAttrs (oldAttrs: {
    postPatch = ''
      # Fix Python 3.13 compatibility: SafeConfigParser -> ConfigParser
      substituteInPlace ds4drv/config.py \
        --replace "configparser.SafeConfigParser" "configparser.ConfigParser"
      
      # Fix evdev API change: device.fn -> device.fd
      substituteInPlace ds4drv/actions/input.py \
        --replace "joystick.device.device.fn" "joystick.device.device.fd"
      
      # Fix evdev API change: device.fn -> device.path
      substituteInPlace ds4drv/actions/binding.py \
        --replace ".fn" ".path"
    '';
  });
in
{
  options.gaming.enable = lib.mkEnableOption "Enable gaming configuration";

  config = lib.mkIf config.gaming.enable {
    # Steam with Proton support
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    # nix-ld for non-Steam Proton execution
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      # X11 libraries
      xorg.libX11
      xorg.libXcursor
      xorg.libXrandr
      xorg.libXi
      xorg.libXext
      xorg.libXfixes
      xorg.libXrender
      xorg.libXxf86vm
      xorg.libXinerama
      xorg.libXScrnSaver
      
      # Graphics libraries
      libglvnd
      vulkan-loader
      
      # Font libraries
      freetype
      fontconfig
      
      # Input libraries
      libxkbcommon
      libinput
      
      # Audio libraries
      libpulseaudio
      alsa-lib
      
      # C libraries
      stdenv.cc.cc.lib
      glib
      glibc
      
      # Other dependencies
      dbus
      expat
      libxml2
      libpng
      libjpeg
      libtiff
      zlib
      bzip2
      libogg
      libvorbis
      openal
      libtheora
      libvpx
      libva
      libdrm
      mesa
      libxslt
      libgcrypt
      libgpg-error
      libunistring
      libidn
      libtasn1
      nettle
      gnutls
      p11-kit
      libffi
      xorg.libxcb
      xorg.libXau
      xorg.libXdmcp
      xorg.libICE
      xorg.libSM
      libuuid
      xorg.libpciaccess
      libelf
      libselinux
      libsepol
      pcre
      pcre2
      zstd
      lz4
      brotli
      libcap
      libcap_ng
      attr
      acl
      e2fsprogs
      keyutils
      krb5
      libverto
      libtirpc
      libnsl
      libxcrypt
      libpsl
      libidn2
      libssh2
      nghttp2
      rtmpdump
      curl
      libssh
      libassuan
      libksba
      libudev0-shim
    ];

    # Hardware acceleration with 32-bit support (critical for games)
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    programs.gamemode = {
      enable = true;
      settings = {
        general = {
          renice = 10;
        };
      };
    };

    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    boot.kernelModules = [ "uinput" "hid_sony" "sony" "joydev" ];
    
    services.udev.extraRules = ''
      # DualShock 4 over Bluetooth
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ba0", MODE="0666", TAG+="uaccess"
      # DualShock 4 over USB
      SUBSYSTEM=="input", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0666", TAG+="uaccess"
      # DS4 over USB (additional)
      SUBSYSTEM=="usb", ATTR{idVendor}=="054c", ATTR{idProduct}=="05c4", MODE="0666", TAG+="uaccess"
      # DS4 2nd gen
      SUBSYSTEM=="usb", ATTR{idVendor}=="054c", ATTR{idProduct}=="09c4", MODE="0666", TAG+="uaccess"
      # Enable DS4 xpad emulation
      SUBSYSTEM=="input", ATTR{name}=="*Wireless Controller*", MODE="0666", TAG+="uaccess"
      # uinput for virtual gamepads
      KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
    '';

    environment.systemPackages = with pkgs; [
      heroic
      wineWowPackages.stagingFull
      mangohud
      dualsensectl
      ds4drv-patched  # Custom patched ds4drv
      protonup-qt     # GUI to manage Proton-GE
      protontricks    # For winetricks/fixes
      steam-run       # To run any .exe in Steam's environment
    ];

    # ds4drv systemd service for automatic Xbox 360 emulation
    systemd.services.ds4drv = {
      description = "ds4drv - DS4 to Xbox 360 Controller Emulator";
      wantedBy = [ "multi-user.target" ];
      after = [ "bluetooth.target" ];
      path = [ pkgs.bluez ];
      serviceConfig = {
        ExecStart = "${ds4drv-patched}/bin/ds4drv --emulate-xpad --led 0000FF";
        Restart = "on-failure";
        RestartSec = "5";
        User = "root";
      };
    };
  };
}
