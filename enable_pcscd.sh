#!/usr/bin/env nix-shell
#!nix-shell -i bash --pure
#!nix-shell -p pcsclite ccid

set -euo pipefail

local cfg=/etc/nixos/configuration.nix
nixos-generate-config --force

# services.pcscd.enable
if ! grep -q 'services\.pcscd\.enable.*true' "$cfg"; then
  sudo sed -i '/^}$/i\  services.pcscd.enable = true;' "$cfg"
fi

# age‑plugin‑yubikey in systemPackages
if ! grep -q 'age-plugin-yubikey' "$cfg"; then
  sudo sed -i '/^}$/i\  environment.systemPackages = with pkgs; [ age-plugin-yubikey ];' "$cfg"
fi
sudo nixos-rebuild switch
