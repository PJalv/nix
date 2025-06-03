{
  config,
  pkgs,
  lib, 
  machine ? "desktop",
  username ? "pjalv",
  ...
}:
{

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # autostart
      exec-once = [
        "copyq --start-server"
        "wl-paste --type text --watch cliphist store # Stores only text data"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "wl-paste --type image --watch cliphist store # Stores only image data"
        "mako"
        "macro_go 'chromium' '.spotify-wrapped'"
        "[workspace 1 silent] chromium-browser --autoplay-policy=no-user-gesture-required"
        "sleep 1 && waybar"

      ];

      input = {
        kb_layout = "us";
        kb_options = "caps:swapescape";
        follow_mouse = 2;
        scroll_factor = 3;
        accel_profile = "flat";

        touchpad = { natural_scroll = true; };
        repeat_delay = 250;
        repeat_rate = 50;
      };
      gestures = { workspace_swipe = true; };
      general = {
        "$fileManager" = "thunar";
        "$terminal" = "ghostty";
        "$menu" = "rofi";
        "$mainMod" = "ALT";
        layout = "dwindle";
        gaps_in = 1;
        gaps_out = 0;
        border_size = 1;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
      };

      cursor = { inactive_timeout = 5; };
      misc = {
        disable_hyprland_logo = true;
        always_follow_on_dnd = true;
        middle_click_paste = false;
      };

      dwindle = { preserve_split = true; };

      decoration = {
        rounding = 4;
        active_opacity = 1.0;
        inactive_opacity = 1.0;

        blur = {
          enabled = false;
          size = 3;
          passes = 1;
        };
      };

      animations = {
        enabled = true;

        bezier = [ "myBezier, 0.05, 0.9, 0.1, 1.05" ];

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      bind = [
        # show keybinds list
        "$mainMod, F1, exec, show-keybinds"
        "SUPER, v, exec, copyq show"
        # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
        "SUPER, D, exec, vesktop"
        "SUPER, S, exec, spotify"
        "SUPER, period, exec, emote"
        "$mainMod, RETURN, exec, $terminal"
        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating,"
        "$mainMod, SPACE, exec, $menu -show drun -show-icons"
        "$mainMod, P, pseudo" # dwindle
        "$mainMod, B, togglesplit"

        # Move focus with mainMod + arrow keys
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # media and volume controls
        ",XF86AudioPlay,exec, playerctl play-pause"
        ",XF86AudioNext,exec, playerctl next"
        ",XF86AudioPrev,exec, playerctl previous"
        ",XF86AudioStop,exec, playerctl stop"
        # Example special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # SCREENSHOT
        "$mainMod,code:117, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
      ];

      # mouse binding
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];


      # windowrulev2
      windowrulev2 = [
        "pin,class:^(rofi)$"
        "float,class:org.pulseaudio.pavucontrol"
        "size 900 450,class:org.pulseaudio.pavucontrol"
        "float,class:com.github.hluk.copyq"
        "size 422 652,class:com.github.hluk.copyq"

        "suppressevent maximize, class:.*" # You'll probably like this.
      ];
    };

    extraConfig = let
      laptopConfig = ''
        monitor = eDP-1,2240x1400,0x0,1
        input {
          sensitivity = 0.9
        }
      '';
      desktopConfig = ''
        monitor=DP-3,1920x1080@144,0x0,1
        monitor=HDMI-A-1,1920x1080,-1080x-200,1,transform,3
        monitor=desc:Sharp Corporation LC40LB601U,HDMI-A-1,1920x1080,-1920x0,1
        workspace=9, monitor:HDMI-A-1
        exec-once=[workspace 9 silent] vesktop & hyprctl dispatch workspace 9
      '';
    in ''
      ${if machine == "laptop" then laptopConfig else desktopConfig}

      exec-once = swww-daemon
      exec-once = nm-applet --indicator
      exec-once = fusuma
      exec-once = swww img "$(find -L .config/wallpaper -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | shuf -n 1)"
      exec-once = cd $($HOME)/.config/waybar && nix-shell --run "uv run python main.py" 
      exec-once = /home/${username}/.config/styles/setup.sh 

      xwayland {
        force_zero_scaling = true
      }

      env = XCURSOR_SIZE,24
      env = HYPRCURSOR_SIZE,24
      device {
        name = epic-mouse-v1
        sensitivity = -0.5
      }
      bind = SUPER_SHIFT, S, exec, grim -g "$(slurp -d)" - | wl-copy
      bind = ALT, R, submap, resize
      # will start a submap called "resize"
      submap = resize
      # sets repeatable binds for resizing the active window
      binde = , l, resizeactive, 50 0
      binde = , h, resizeactive, -50 0
      binde = , k, resizeactive, 0 -40
      binde = , j, resizeactive, 0 40 # use reset to go back to the global submap
      bind = , escape, submap, reset
      # will reset the submap, meaning end the current one and return to the global one
      submap = reset
      bind = $mainMod,code:117, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle
      bindl=, XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle
      bindel=, XF86AudioLowerVolume, exec, pactl -- set-sink-volume 0 -5%
      bindel=, XF86AudioRaiseVolume, exec, pactl -- set-sink-volume 0 +5%
      bindel=, XF86MonBrightnessDown, exec, brightnessctl s 5%-
      bindel=, XF86MonBrightnessUp, exec, brightnessctl s 5%+
    '';
  };
}

