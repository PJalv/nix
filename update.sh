# Add NixOS unstable channel
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos

# Add Home Manager master channel
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

# Update both channels
sudo nix-channel --update
