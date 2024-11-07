{ config, pkgs, ... }:

{
  imports = [
      <home-manager/nixos>
  ];
  users.users.pjalv.isNormalUser = true;


home-manager.users.pjalv = { pkgs, ... }: {

  home.packages = with pkgs; [
      lazygit
      swww
      sassc
      gtk-engine-murrine
      gtk_engines
      gnome-themes-extra
      zoxide
  ];

imports = [
./zsh.nix
./rofi.nix
./kitty.nix
];

  programs.chromium = {
    enable = true;
    extensions = [
  "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
  "ghmbeldphafepmbegfdlkpapadhbakde" # proton pass 
  ];
    commandLineArgs = [
      "--force-dark-mode"
    ];
  };

  # programs.bash.enable = true;
  programs.git.extraConfig.init.defaultBranch = "main";
  programs.git = {
    enable = true;
    userName  = "PJalv";
    userEmail = "pjalvbusiness@gmail.com";
  };
  programs.gh.enable = true;
  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.05";
gtk = {
    enable = true;
    theme = {
      name = "Tokyonight-Dark";
      package = pkgs.tokyonight-gtk-theme;
      
    };

    font = {
      name = "Nunito";
      size = 10;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    gtk3.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
    };

    gtk2.extraConfig = ''
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle="hintslight"
      gtk-xft-rgba="rgb"
    '';

    cursorTheme = {
    name = "catppuccin-macchiato-dark-cursors";
    package = pkgs.catppuccin-cursors.macchiatoDark;
    };
  };

  home.pointerCursor = {
    name = "catppuccin-macchiato-dark-cursors";
    package = pkgs.catppuccin-cursors.macchiatoDark;
    size = 30;
    gtk.enable = true;
    x11.enable = true;
  };

  home.sessionVariables = {
  };




};



}
