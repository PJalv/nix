{
 config,
 pkgs,
 lib,
 username ? "remote",
 inputs,
 ...
}:
let

in
{

 home.username = username;
 home.homeDirectory = "/home/${username}";
 home.packages = with pkgs; [
   lazygit
   zoxide
   neovim
 ];

 imports = [
   ../../hm/zsh.nix
   ../../hm/starship.nix
 ];

 programs.direnv = {
   enable = true;
   enableZshIntegration = true;
   nix-direnv.enable = true;
 };

 programs.git.extraConfig.init.defaultBranch = "main";
 programs.git.extraConfig.pull.rebase = false;
 programs.git = {
   enable = true;
   userName = "PJalv";
   userEmail = "pjalvbusiness@gmail.com";
 };
 programs.gh.enable = true;
 # The state version is required and should stay at the version you
 # originally installed.


 programs.home-manager.enable = true;
 home.sessionVariables = { };
  home.stateVersion = "24.11"; # Please read the comment before changing.
}


