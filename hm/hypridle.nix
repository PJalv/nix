
{
  config,
  pkgs,
  lib,
  machine ? "desktop",
  username ? "pjalv",
  ...
}:{
  xdg.configFile."hypridle.conf".text = '' 

general {
  lock_cmd = pidof hyprlock || hyprlock       # start hyprlock if not already running
    before_sleep_cmd = hyprlock                 # lock just before sleep (works for lid close too)
    after_sleep_cmd = hyprctl dispatch dpms on  # turn screens back on after resume
}

listener {
  timeout = 300                                 # 5 min idle → lock + suspend
    on-timeout = hyprlock                         # lock when timeout is reached
}

listener {
  timeout = 310                                 # 10 seconds after lock → suspend
    on-timeout = systemctl suspend-then-hibernate # or just "systemctl suspend"
}
  '';
}
