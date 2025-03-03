{ pkgs, ... }: {

  xdg.configFile."ghostty/config".text = ''
    font-family = FiraCode Nerd Font Mono
    font-size = 12.5
    window-padding-color = extend
    background-opacity = 0.94 
    unfocused-split-opacity = 0.90 
    theme = catppuccin-mocha
    window-theme = ghostty
    window-decoration = false



    gtk-titlebar = false
    gtk-tabs-location = bottom
    confirm-close-surface = false

    keybind = ctrl+shift+j=scroll_page_fractional:0.7
    keybind = ctrl+shift+k=scroll_page_fractional:-0.7

    keybind = alt+shift+h=previous_tab
    keybind = alt+shift+l=next_tab

  '';
  xdg.configFile."gtk-4.0/gtk.css".text = ''
    /*
    debug: env GTK_DEBUG=interactive ghostty
    https://docs.gtk.org/gtk4/css-overview.html
    https://docs.gtk.org/gtk4/css-properties.html
    */
    tabbar tabbox {
      margin: 0px;
      padding: 0px;
      min-height: 10px;
      background-color: #1a1a1a;
      font-family: monospace;
    }

    tabbar tabbox tab {
      margin: 0px;
      padding: 0px;
      color: #9ca3af;
      border-right: 1px solid #374151;
    }
    window > box > tabbar > revealer > box {
      margin: 0px;
    }

    tabbar tabbox tab.active {
      background-color: #2d2d2d;
      color: #ffffff;
    }

    tabbar tabbox tab label {
     font-size: 13px;
    }
    tabbar {background-color: #0a0a0aC9} RGB+opacity
  '';
}
