{ pkgs, ... }: {
  home.packages = (with pkgs; [
    rofi
    # Rofi's drun/run icon rendering needs a real icon theme. The previous
    # `icon-theme: "Oranchelo"` pointed at a theme that was never installed,
    # so launcher rows rendered without icons. Papirus ships a large, modern
    # app/generic set with strong coverage of common desktop apps.
    papirus-icon-theme
  ]);

  # NOTE: keep the explanatory lines ABOVE this rasi block. rofi 2.0 silently
  # drops every config key that appears after a `#` comment inside `configuration {}`.
  xdg.configFile."rofi/config.rasi".text = ''
      configuration {
        modes: "run,drun,window,filebrowser";
        icon-theme: "Papirus";
        show-icons: true;
        terminal: "ghostty";

        drun-display-format: "{icon} {name}";
        location: 0;
        disable-history: false;
        hide-scrollbar: true;
        sidebar-mode: true;

        display-drun: "󰀻 Apps";
        display-run: "󰄉 Run";
        display-window: "󰄡 Window";
        display-filebrowser: "󰉋 Files";
    }

    @theme "catppuccin-frappe"
  '';

  xdg.configFile."rofi/catppuccin-frappe.rasi".text = ''
      * {
        /* Catppuccin Frappe palette */
        bg-crust: #232634;
        surface0: #414559;
        surface1: #51576d;
        overlay0: #737994;
        fg:       #c6d0f5;  /* text */
        blue:     #8caaee;
        red:      #e78284;

        font: "JetBrainsMono Nerd Font 14";
        width: 720px;
      }

      window {
        width: 720px;
        border: 1px;
        border-radius: 12px;
        border-color: @surface1;
        background-color: @bg-crust;
        /* Slightly inset so the border reads as a clean frame. */
        padding: 6px;
      }

      mainbox {
        background-color: transparent;
        padding: 6px;
        children: [ inputbar, message, listview ];
        spacing: 0;
      }

      /* --- search bar --- */
      inputbar {
        children: [ prompt, entry ];
        background-color: @surface0;
        border-radius: 10px;
        padding: 10px 14px;
        spacing: 10px;
      }

      prompt {
        background-color: transparent;
        text-color: @blue;
      }

      textbox-prompt-colon {
        str: " ";
      }

      entry {
        background-color: transparent;
        text-color: @fg;
        cursor: text;
      }

      /* --- results list --- */
      listview {
        background-color: transparent;
        padding: 8px 0px 0px 0px;
        spacing: 2px;
        columns: 1;
        lines: 8;
        flow: vertical;
      }

      element {
        background-color: transparent;
        border-radius: 8px;
        padding: 9px 12px;
        spacing: 12px;
        /* rofi's default foreground is dark; without this, rows render
           dark-on-dark over the crust background and look washed out. */
        text-color: @fg;
      }

      element-icon {
        background-color: transparent;
        size: 26px;
        vertical-align: 0.5;
        text-color: @fg;
      }

      element-text {
        background-color: transparent;
        vertical-align: 0.5;
        text-color: @fg;
      }

      element selected {
        /* rasi border-color only takes one colour (no per-side shorthand), so
           the active row is highlighted with a solid surface fill instead of
           the lavender accent bar used on other compositors. */
        background-color: @surface0;
        border-radius: 8px;
      }

      element-icon selected {
        text-color: @blue;
      }

      element-text selected {
        text-color: @fg;
        font-weight: bold;
      }

      /* --- empty / error message --- */
      message {
        background-color: transparent;
        border-radius: 8px;
        margin: 6px 0px 0px 0px;
        padding: 8px 12px;
        text-color: @fg;
      }

      /* Filebrowser and error messages wrap their content in a nested textbox.
         Override rofi's light default so it does not appear as a white bar. */
      textbox {
        background-color: transparent;
        text-color: @fg;
      }

      /* --- mode switcher (sidebar) --- */
      mode-switcher {
        spacing: 4px;
      }

      button {
        padding: 8px 12px;
        border-radius: 8px;
        background-color: transparent;
        text-color: @overlay0;
        horizontal-align: 0.5;
        vertical-align: 0.5;
      }

      button selected {
        background-color: @surface0;
        text-color: @blue;
      }
  '';
}