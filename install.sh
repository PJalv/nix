#!/usr/bin/env bash

#
# NixOS Configuration Installation Script
# Automates installation of this NixOS configuration from a fresh minimal install
#
# Usage: curl -sSL https://raw.githubusercontent.com/OWNER/nixos-config/main/install.sh | bash
#        Or: ./install.sh (after cloning)
#

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_URL="https://github.com/OWNER/nixos-config.git"
CONFIG_DIR="/etc/nixos"
USERNAME="user"

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo ""
}

print_kv() {
    printf "  - %-22s %s\n" "$1:" "$2"
}

print_install_plan() {
    print_header "Installation Plan"
    print_info "This installer will perform the following actions in order:"
    echo ""
    echo "  1) Verify this script is running as root"
    echo "  2) Enable flakes in /etc/nix/nix.conf"
    echo "  3) Clone or update the configuration repository"
    echo "  4) Ask which machine profile to install"
    echo "  5) Generate hardware-configuration.nix for this machine"
    echo "  6) Run nixos-rebuild switch with the selected flake target"
    echo "  7) Verify the configured user exists and set its password"
    echo ""
    print_info "Installer variables:"
    print_kv "Repository" "$REPO_URL"
    print_kv "Config directory" "$CONFIG_DIR"
    print_kv "Target username" "$USERNAME"
    echo ""
}

# Check if running as root
check_root() {
    print_info "Checking privileges..."
    print_kv "Current EUID" "$EUID"

    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
    print_success "Running as root"
}

enable_flakes() {
    print_header "Enabling Nix Flakes"

    local nix_conf="/etc/nix/nix.conf"

    print_kv "Config file" "$nix_conf"

    if grep -q "experimental-features = nix-command flakes" "$nix_conf" 2>/dev/null; then
        print_success "Flakes already enabled"
        return 0
    fi

    print_info "Flakes line not found; updating nix configuration"

    mkdir -p "$(dirname "$nix_conf")"

    if [[ -f "$nix_conf" ]]; then
        print_info "nix.conf already exists"
        if ! grep -q "experimental-features" "$nix_conf"; then
            print_info "No experimental-features entry found; appending flakes line"
            echo "experimental-features = nix-command flakes" >> "$nix_conf"
        else
            print_warning "Found an existing experimental-features entry that does not include flakes"
            print_warning "Leaving the existing entry unchanged; update it manually if needed"
        fi
    else
        print_info "nix.conf does not exist yet; creating file"
        echo "experimental-features = nix-command flakes" > "$nix_conf"
    fi

    print_success "Flakes enabled in $nix_conf"
}

clone_repo() {
    print_header "Cloning Configuration Repository"

    print_kv "Repository URL" "$REPO_URL"
    print_kv "Target path" "$CONFIG_DIR"

    if [[ -d "$CONFIG_DIR/.git" ]]; then
        print_info "Repository already exists. Pulling latest changes..."
        cd "$CONFIG_DIR"
        print_info "Trying to pull from 'main' first, then 'master' as fallback"
        git pull origin main || git pull origin master || {
            print_warning "Could not pull updates. Continuing with local version..."
        }
        print_success "Repository updated"
    else
        print_info "Cloning repository from $REPO_URL"

        if [[ -d "$CONFIG_DIR" ]] && [[ $(ls -A "$CONFIG_DIR" 2>/dev/null) ]]; then
            local backup_dir="${CONFIG_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
            print_warning "Backing up existing configuration to $backup_dir"
            mv "$CONFIG_DIR" "$backup_dir"
        fi

        git clone "$REPO_URL" "$CONFIG_DIR"
        print_success "Repository cloned to $CONFIG_DIR"
    fi
}

detect_machine_type() {
    print_header "Machine Type Selection"

    local has_laptop_features=0
    local has_desktop_features=0

    if ls /sys/class/power_supply/ | grep -q "BAT" 2>/dev/null; then
        has_laptop_features=1
    fi

    if ls /sys/class/input/ | grep -i "touchpad" 2>/dev/null; then
        has_laptop_features=1
    fi

    if lspci 2>/dev/null | grep -iq "nvidia\|amd\|radeon"; then
        has_desktop_features=1
    fi

    local default_choice="desktop"
    local detected=""

    if [[ $has_laptop_features -eq 1 ]]; then
        default_choice="laptop"
        detected=" (auto-detected as laptop)"
    fi

    print_info "Detected hardware hints:"
    if [[ $has_laptop_features -eq 1 ]]; then
        print_kv "Laptop indicators" "found"
    else
        print_kv "Laptop indicators" "not found"
    fi
    if [[ $has_desktop_features -eq 1 ]]; then
        print_kv "Discrete GPU hint" "found"
    else
        print_kv "Discrete GPU hint" "not found"
    fi
    print_kv "Default profile" "$default_choice"
    echo ""

    echo "Which configuration would you like to install?"
    echo ""
    echo "  1) desktop    - Desktop configuration with GPU support, Steam, etc."
    echo "  2) laptop    - Laptop configuration with power management, touchpad support"
    echo "  3) wsl       - WSL2 configuration"
    echo ""
    read -p "Select configuration [${default_choice}]$detected: " choice

    case "$choice" in
        1|desktop|"")
            MACHINE="desktop"
            ;;
        2|laptop)
            MACHINE="laptop"
            ;;
        3|wsl)
            MACHINE="wsl"
            ;;
        *)
            print_error "Invalid choice. Please select 1, 2, or 3."
            exit 1
            ;;
    esac

    print_success "Selected configuration: $MACHINE"
}

generate_hardware_config() {
    print_header "Generating Hardware Configuration"

    local hardware_dir="$CONFIG_DIR/users/$USERNAME/$MACHINE"

    print_kv "Machine" "$MACHINE"
    print_kv "Hardware dir" "$hardware_dir"

    if [[ ! -d "$hardware_dir" ]]; then
        print_error "Hardware configuration directory not found: $hardware_dir"
        exit 1
    fi

    print_info "Generating hardware configuration for this machine..."
    print_info "Command: nixos-generate-config --root / --no-hardware-config --dir $hardware_dir"

    nixos-generate-config --root / --no-hardware-config --dir "$hardware_dir" || {
        print_error "Failed to generate hardware configuration"
        exit 1
    }

    print_success "Hardware configuration generated at $hardware_dir/hardware-configuration.nix"
}

apply_config() {
    print_header "Applying NixOS Configuration"

    local flake_target="${USERNAME}-${MACHINE}"

    print_info "Building and switching to configuration: $flake_target"
    print_info "Working directory: $CONFIG_DIR"
    print_info "Command: nixos-rebuild switch --flake .#$flake_target"
    print_info "This may take a while..."

    cd "$CONFIG_DIR"

    if nixos-rebuild switch --flake ".#$flake_target"; then
        print_success "Configuration applied successfully!"
    else
        print_error "Failed to apply configuration"
        print_info "Check the error messages above for details"
        exit 1
    fi
}

setup_user() {
    print_header "User Setup"

    print_kv "Expected user" "$USERNAME"

    if ! id "$USERNAME" &>/dev/null; then
        print_error "User '$USERNAME' does not exist after configuration"
        print_info "The configuration should have created this user automatically"
        exit 1
    fi

    print_success "User '$USERNAME' exists"

    echo ""
    print_info "Setting password for user '$USERNAME'"
    passwd "$USERNAME"

    print_success "Password set successfully"
}

print_next_steps() {
    print_header "Installation Complete!"
    print_success "Your NixOS system has been configured successfully!"
    echo ""
    echo "Next Steps:"
    echo ""
    echo "  1. Reboot your system:"
    echo "     $ sudo reboot"
    echo ""
    echo "  2. After reboot, log in as '$USERNAME'"
    echo ""
    echo "  3. To update your system in the future:"
    echo "     $ cd $CONFIG_DIR"
    echo "     $ git pull"
    echo "     $ nix flake update"
    echo "     $ sudo nixos-rebuild switch --flake .#${USERNAME}-${MACHINE}"
    echo ""
    echo "  4. To rebuild with changes:"
    echo "     $ cd $CONFIG_DIR"
    echo "     $ sudo nixos-rebuild switch --flake .#${USERNAME}-${MACHINE}"
    echo ""
    echo "  5. Home Manager changes:"
    echo "     $ home-manager switch"
    echo ""
    echo "Documentation:"
    echo "  - View README.md in $CONFIG_DIR for more details"
    echo "  - View INSTALL.md for detailed installation troubleshooting"
    echo ""
}

# Main installation flow
main() {
    clear
    cat << "EOF"

    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║        NixOS Configuration Installer                      ║
    ║        NixOS configuration                                 ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝

EOF

    print_install_plan
    check_root
    enable_flakes
    clone_repo
    detect_machine_type
    generate_hardware_config
    apply_config
    setup_user
    print_next_steps

    print_header "All Done!"
}

main "$@"
