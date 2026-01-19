# NixOS Installation Guide

Complete step-by-step guide for installing NixOS and setting up PJalv's configuration from scratch.

## Table of Contents

- [System Requirements](#system-requirements)
- [Preparation](#preparation)
- [Installation](#installation)
  - [Boot NixOS ISO](#boot-nixos-iso)
  - [Network Configuration](#network-configuration)
  - [Disk Partitioning](#disk-partitioning)
  - [Filesystem Creation](#filesystem-creation)
  - [Mounting Filesystems](#mounting-filesystems)
  - [Base System Installation](#base-system-installation)
  - [Configuration](#configuration)
  - [System Installation](#system-installation)
- [Post-Installation Setup](#post-installation-setup)
  - [Boot into New System](#boot-into-new-system)
  - [Apply Configuration](#apply-configuration)
  - [User Setup](#user-setup)
- [Automated Installation](#automated-installation)
- [Troubleshooting](#troubleshooting)

## System Requirements

### Hardware

- **CPU**: x86_64 (64-bit)
- **RAM**: Minimum 4GB, 8GB+ recommended
- **Storage**: 40GB+ minimum, 80GB+ recommended
- **UEFI**: UEFI firmware with Secure Boot support (recommended)
- **Network**: Ethernet or WiFi card

### System Types

This configuration supports:
- **Desktop**: Full-featured with GPU support, Steam, desktop applications
- **Laptop**: Optimized for battery life, power management, touchpad support
- **WSL**: Windows Subsystem for Linux configuration

## Preparation

### 1. Download NixOS Minimal ISO

Visit [nixos.org/download](https://nixos.org/download.html) and download:
- **Graphical ISO**: For systems with UEFI and graphical boot
- **Minimal ISO**: For command-line installation (smaller download)

Recommended: Use the latest stable release.

### 2. Create Bootable USB

**On Linux:**
```bash
# Find your USB device (e.g., /dev/sdX)
lsblk

# Flash ISO to USB (replace /dev/sdX with your device)
sudo dd if=nixos-minimal.iso of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

**On macOS:**
```bash
# Find your USB device (e.g., /dev/disk2)
diskutil list

# Unmount the disk
diskutil unmountDisk /dev/disk2

# Flash ISO to USB
sudo dd if=nixos-minimal.iso of=/dev/disk2 bs=4m status=progress
sync
```

**On Windows:**
Use [Rufus](https://rufus.ie/) or [BalenaEtcher](https://www.balena.io/etcher/)

### 3. Boot from USB

1. Insert USB drive
2. Restart computer
3. Press boot menu key (F2, F12, F10, Del, etc.)
4. Select USB drive from boot menu
5. Boot NixOS

## Installation

### Boot NixOS ISO

After booting, you'll see a command prompt as root.

### Network Configuration

#### Wired Connection (DHCP)
```bash
# Usually auto-configured
ip addr show

# If not, enable DHCP
sudo dhclient
```

#### WiFi Connection
```bash
# Scan for networks
sudo wpa_supplicant -B -i wlp2s0 -c<(wpa_passphrase "SSID" "password")

# Or use nmtui for interactive setup
sudo nmtui
```

#### Verify Connection
```bash
ping -c 3 nixos.org
```

### Disk Partitioning

**IMPORTANT**: All data on the target disk will be destroyed!

First, identify your disk:
```bash
lsblk
fdisk -l
```

#### For Desktop (Separate /home partition)

This is recommended for desktop systems to keep user data separate from system files.

```bash
sudo fdisk /dev/nvme0n1
```

Interactive fdisk commands:
```
g               # Create GPT partition table
n               # New partition
1               # Partition 1 (EFI)
<Enter>         # Default start
+512M           # 512MB size
t               # Change type
1               # EFI System type
n               # New partition
2               # Partition 2 (Root)
<Enter>         # Default start
<Enter>         # Rest of disk
n               # New partition
3               # Partition 3 (Home)
<Enter>         # Default start
<Enter>         # Rest of disk
p               # Print partition table
w               # Write and exit
```

Partition layout:
- `/dev/nvme0n1p1` - EFI System Partition (512MB)
- `/dev/nvme0n1p2` - Root partition (Btrfs)
- `/dev/nvme0n1p3` - Home partition (Btrfs)

#### For Laptop (Single partition)

Simpler layout for laptops, all data on single partition.

```bash
sudo fdisk /dev/nvme0n1
```

Interactive fdisk commands:
```
g               # Create GPT partition table
n               # New partition
1               # Partition 1 (EFI)
<Enter>         # Default start
+512M           # 512MB size
t               # Change type
1               # EFI System type
n               # New partition
2               # Partition 2 (Root)
<Enter>         # Default start
<Enter>         # Rest of disk
p               # Print partition table
w               # Write and exit
```

Partition layout:
- `/dev/nvme0n1p1` - EFI System Partition (512MB)
- `/dev/nvme0n1p2` - Root partition (Btrfs)

### Filesystem Creation

#### Desktop Layout
```bash
# Format EFI partition (FAT32)
sudo mkfs.fat -F32 /dev/nvme0n1p1

# Format root partition (Btrfs)
sudo mkfs.btrfs -L nixos /dev/nvme0n1p2

# Format home partition (Btrfs)
sudo mkfs.btrfs -L home /dev/nvme0n1p3

# Optional: Create swap file
sudo btrfs subvolume create /mnt/@swap
sudo truncate -s 0 /swap/swapfile
sudo chattr +C /swap/swapfile
sudo btrfs property set /swap/swapfile compression none
sudo fallocate -l 8G /swap/swapfile
sudo chmod 600 /swap/swapfile
sudo mkswap /swap/swapfile
```

#### Laptop Layout
```bash
# Format EFI partition (FAT32)
sudo mkfs.fat -F32 /dev/nvme0n1p1

# Format root partition (Btrfs)
sudo mkfs.btrfs -L nixos /dev/nvme0n1p2
```

### Mounting Filesystems

#### Desktop Mount
```bash
# Mount root partition
sudo mount /dev/nvme0n1p2 /mnt

# Create mount points
sudo mkdir -p /mnt/home /mnt/boot

# Mount home partition
sudo mount /dev/nvme0n1p3 /mnt/home

# Mount EFI partition
sudo mount /dev/nvme0n1p1 /mnt/boot
```

#### Laptop Mount
```bash
# Mount root partition
sudo mount /dev/nvme0n1p2 /mnt

# Create mount points
sudo mkdir -p /mnt/boot

# Mount EFI partition
sudo mount /dev/nvme0n1p1 /mnt/boot
```

### Base System Installation

```bash
# Generate hardware configuration
sudo nixos-generate-config --root /mnt
```

This creates `/mnt/etc/nixos/configuration.nix` and `hardware-configuration.nix`

Review the generated configuration:
```bash
cat /mnt/etc/nixos/configuration.nix
cat /mnt/etc/nixos/hardware-configuration.nix
```

### Configuration

Edit the minimal configuration:
```bash
sudo nano /mnt/etc/nixos/configuration.nix
```

Add essential settings:
```nix
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # For desktop with separate EFI mount:
  # boot.loader.grub.efiSupport = true;
  # boot.loader.efi.efiSysMountPoint = "/boot";

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Timezone and locale
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  # User account (will be replaced by configuration)
  users.users.pjalv = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Enable sudo
  security.sudo.wheelNeedsPassword = false;

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System version
  system.stateVersion = "24.11";
}
```

### System Installation

```bash
# Install NixOS
sudo nixos-install

# This will take 15-30 minutes depending on hardware
```

Set root password when prompted.

After completion:
```bash
# Reboot
sudo reboot

# Remove USB when prompted
```

## Post-Installation Setup

### Boot into New System

After reboot, log in as `root` or the user you created.

### Apply Configuration

Now apply PJalv's NixOS configuration:

#### Option 1: Automated Installation (Recommended)

```bash
curl -sSL https://raw.githubusercontent.com/PJalv/nixos-config/main/install.sh | sudo bash
```

This will:
- Enable flakes
- Clone the repository
- Detect your machine type
- Generate hardware configuration
- Apply the full configuration
- Set up user `pjalv`

#### Option 2: Manual Installation

```bash
# Clone repository
sudo git clone https://github.com/PJalv/nixos-config.git /etc/nixos
cd /etc/nixos

# Generate hardware configuration for your machine type
sudo nixos-generate-config --root / --no-hardware-config --dir /etc/nixos/users/pjalv/desktop

# Or for laptop:
# sudo nixos-generate-config --root / --no-hardware-config --dir /etc/nixos/users/pjalv/laptop

# Apply configuration (desktop)
sudo nixos-rebuild switch --flake .#pjalv-desktop

# Or for laptop:
# sudo nixos-rebuild switch --flake .#pjalv-laptop
```

### User Setup

After configuration is applied:

```bash
# Set password for pjalv user
sudo passwd pjalv

# Reboot into final system
sudo reboot
```

## Automated Installation

For completely hands-free installation from a fresh NixOS minimal ISO:

```bash
curl -sSL https://raw.githubusercontent.com/PJalv/nixos-config/main/install.sh | sudo bash
```

The script will guide you through:
1. Machine type selection (desktop/laptop/WSL)
2. Hardware configuration generation
3. Configuration application
4. User setup

## Troubleshooting

### Boot Issues

**System won't boot after installation:**

1. Boot into live USB
2. Mount partitions
3. Check bootloader configuration:
   ```bash
   sudo fdisk -l /dev/nvme0n1
   lsblk
   ```

4. Reinstall bootloader:
   ```bash
   sudo mount /dev/nvme0n1p2 /mnt
   sudo mount /dev/nvme0n1p1 /mnt/boot
   sudo nixos-install --root /mnt
   ```

### Network Issues

**No internet connection:**

```bash
# Check network interfaces
ip link show

# Bring up interface
sudo ip link set eth0 up

# Try DHCP
sudo dhclient eth0

# Or manual configuration
sudo ip addr add 192.168.1.100/24 dev eth0
sudo ip route add default via 192.168.1.1
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

### Installation Fails

**nixos-install fails:**

Check logs:
```bash
journalctl -xe
cat /var/log/nixos-install
```

Common fixes:
- Ensure sufficient disk space
- Check network connectivity
- Verify filesystem types are correct
- Try installing without swap

### Configuration Errors

**nixos-rebuild switch fails:**

```bash
# Enable verbose output
sudo nixos-rebuild switch --flake .#pjalv-desktop --show-trace

# Check configuration syntax
nix flake check

# Try dry-run
sudo nixos-rebuild dry-build --flake .#pjalv-desktop
```

### Hardware Detection Issues

**Hardware not detected:**

```bash
# List all hardware
lspci
lsusb
lsblk

# Check kernel messages
sudo dmesg | less

# Regenerate hardware configuration
sudo nixos-generate-config --root / --no-hardware-config --dir /etc/nixos/users/pjalv/desktop
```

### Flakes Not Working

**Error: experimental feature 'flakes' is disabled:**

```bash
# Check nix.conf
cat /etc/nix/nix.conf

# Should contain:
# experimental-features = nix-command flakes

# Add if missing:
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
```

## Additional Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Options Search](https://search.nixos.org/options)
- [NixOS Wiki](https://nixos.wiki/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)

## Getting Help

If you encounter issues not covered here:

1. Check the main [README.md](README.md)
2. Search the [NixOS Discourse](https://discourse.nixos.org/)
3. Ask in #nixos on Libera.chat IRC
4. Check GitHub issues for this repository

## Next Steps

After successful installation:

1. Customize your configuration in `/etc/nixos`
2. Add additional software to your configuration
3. Set up backups
4. Configure your desktop environment (Hyprland, Waybar, etc.)
5. Explore Home Manager for user-specific settings

Happy hacking!
