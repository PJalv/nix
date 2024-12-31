
{ pkgs, ... }: 
{
  home.packages = (with pkgs; [ rofi-wayland ]);

  xdg.configFile."ghostty/config".text = ''
  font-family = FiraCode Nerd Font Mono
  font-size = 12.5
  window-padding-color = extend
  background-opacity = 0.92 
  unfocused-split-opacity = 0.90 
  theme = catppuccin-mocha
  window-theme = dark


  gtk-titlebar = false
  confirm-close-surface = false

  keybind = alt+shift+k=goto_split:top
  keybind = alt+shift+j=goto_split:bottom

'';
}
