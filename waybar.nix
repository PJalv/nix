{ config, pkgs, lib, ... }:

let
  machine = "laptop";
  username = "pjalv";
  # Define the Git repository URL and revision (e.g., branch, commit hash, etc.)
  dotfilesRepo = pkgs.fetchgit {
    url = "https://github.com/PJalv/dotfiles.git"; # Replace with your repo URL
    rev = "4acfbbf7255deabe4438bd2d1f07782dbfbb4f47";
    # Or specify the commit hash/branch/tag
    sha256 = "sha256-KLguT+Ggy/z9shEcTKgWxU/0OlUoFguSqQHh25sLpvg="; # This will be automatically replaced when you run `nixos-rebuild`
  };

  # Define the location of your dotfiles directory
  dotfilesDir = dotfilesRepo;
in

{

  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    });
    systemd.enable = false;
    style = ''
      ${builtins.readFile "${dotfilesDir}/.config/waybar/styles/style.css"}
    '';
    settings = [{
      height = 20;
      layer = "top";
      position = "top";
      tray = { spacing = 10; };
      modules-center = [ "hyprland/window" ];
      modules-left = [
        "hyprland/workspaces"
        "custom/media"
      ];
      modules-right = [
        "pulseaudio"
        "network"
        "cpu"
        "memory"
        "backlight"
      ] ++ (if machine == "laptop" then [ "power-profiles-daemon" "battery" ] else [ ])
      ++ [
        "clock"
        "tray"
      ];
      battery = {
        format = "{capacity}% {icon} ";
        format-alt = "{time} {icon}";
        format-charging = "{capacity}%  ";
        format-icons = [ " " " " " " " " " " ];
        format-plugged = "{capacity}%  ";
        states = {
          critical = 15;
          warning = 30;
        };
      };
      power-profiles-daemon = {
        format = "{icon}";
        # format = "Power profile: {profile}\nDriver: {driver}";
        tooltip = true;
        format-icons = {
          default = " ";
          performance = " ";
          balanced = " ";
          power-saver = " ";
        };
      };
      backlight = {
        format = "{percent}% {icon}";
        format-icons = [ " " " " " " " " " " " " " " " " " " ];
      };
      clock = {
        tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
        format = "{:%I:%M:%S}";
        format-alt = " {:%d/%m/%Y  %H:%M:%S}";
        interval = 1;
      };
      cpu = {
        format = "{usage}%  ";
        tooltip = false;
        interval = 2;
      };
      memory = {
        interval = 5;
        format = "{}%  ";
      };
      network = {
        interval = 1;
        format-alt = "{ifname}: {ipaddr}/{cidr}";
        format-disconnected = "Disconnected ⚠";
        format-ethernet = "{ipaddr}/{cidr}";
        format-linked = "{ifname} (No IP) ";
        format-wifi = "{essid} ({signalStrength}%)  ";
      };
      "custom/media" = {

        exec = "playerctl --follow metadata --format '{\"text\": \"{{ artist }} - {{ title }}\", \"class\": \"custom-spotify\", \"alt\": \"spotify\"}' --player=spotify";
        format = "{}  ";
        return-type = "json";
        on-click = "playerctl --player=spotify,vlc play-pause";
        on-scroll-up = "playerctl --player=spotify,vlc next";
        on-scroll-down = "playerctl --player=spotify,vlc previous";
      };
      pulseaudio = {
        scroll-step = 2;
        format = "{volume}% {icon} {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-icons = {
          car = "";
          default = [ "" " " " " ];
          handsfree = " ";
          headphones = " ";
          headset = " ";
          phone = " ";
          portable = " ";
        };
        format-muted = "  {format_source}";
        format-source = "{volume}% ";
        format-source-muted = " ";
        on-click = "pavucontrol";
        on-click-middle = "pactl set-sink-mute 0 toggle";
      };
      "hyprland/mode" = { format = ''<span style="italic">{}</span>''; };
      temperature = {
        critical-threshold = 80;
        format = "{temperatureC}°C {icon}";
        format-icons = [ "" "" "" ];
      };
    }];
  };
}


