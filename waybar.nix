{ config, pkgs, lib, ... }:

{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    });
    systemd.enable = false;
    style = ''
      ${builtins.readFile "${config.home.homeDirectory}/.config/waybar/styles/style.css"}
    '';
    settings = [{
      height = 20;
      layer = "top";
      position = "top";
      tray = { spacing = 10; };
      modules-center = [ "hyprland/window" ];
      modules-left = [ "hyprland/workspaces" "custom/media" ];
      modules-right = [
        # ] ++ (if config.machine == "laptop" then [ "battery" ] else [ ])
        # ++ [
        # "idle_inhibitor"
        "pulseaudio"
        "network"
        "cpu"
        "memory"
        "backlight"
        "clock"
        "tray"
      ];
      battery = {
        format = "{capacity}% {icon}";
        format-alt = "{time} {icon}";
        format-charging = "{capacity}%  ";
        format-icons = [ "" "" "" "" "" ];
        format-plugged = "{capacity}% ";
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

      clock = {
        tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
        format = "{:%I:%M:%S}";
        format-alt = " {:%d/%m/%Y  %H:%M:%S}";
        interval = 1;
      };
      cpu = {
        format = "{usage}% ";
        tooltip = false;
        interval = 2;
      };
      memory = {
        interval = 5;
        format = "{}% ";
      };
      network = {
        interval = 1;
        format-alt = "{ifname}: {ipaddr}/{cidr}";
        format-disconnected = "Disconnected ⚠";
        format-ethernet = "{ipaddr}/{cidr}";
        format-linked = "{ifname} (No IP) ";
        format-wifi = "{essid} ({signalStrength}%) ";
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


