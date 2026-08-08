#!/usr/bin/env bash

set -euo pipefail

readonly nix_config="/etc/nix/nix.conf"
readonly numtide_cache="https://cache.numtide.com"
readonly numtide_key="niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="

sudo mkdir -p /etc/nix
sudo touch "$nix_config"

if ! sudo grep -Fqx "extra-substituters = $numtide_cache" "$nix_config"; then
  printf '\nextra-substituters = %s\n' "$numtide_cache" | sudo tee -a "$nix_config" >/dev/null
fi

if ! sudo grep -Fqx "extra-trusted-public-keys = $numtide_key" "$nix_config"; then
  printf 'extra-trusted-public-keys = %s\n' "$numtide_key" | sudo tee -a "$nix_config" >/dev/null
fi

if systemctl list-unit-files nix-daemon.service >/dev/null 2>&1; then
  sudo systemctl restart nix-daemon.service
fi

echo "The Nix daemon now trusts the Numtide binary cache."
