#!/usr/bin/env nix-shell
#!nix-shell -p usbutils pcsclite ccid age-plugin-yubikey age -i bash
set -euo pipefail

KEYFILE="$HOME/.config/sops/age/keys.txt"

if [[ -s "$KEYFILE" ]]; then
  echo "Detected existing $KEYFILE – skipping decryption step."
  exit 0
fi

mkdir -p "$(dirname "$KEYFILE")"

have_yubikey() {
  lsusb | grep -qi 'yubikey'
}

enable_pcscd_once() {
  local cfg=/etc/nixos/configuration.nix

  # services.pcscd.enable
  if ! grep -q 'services\.pcscd\.enable.*true' "$cfg"; then
    sudo sed -i '/^}$/i\  services.pcscd.enable = true;' "$cfg"
  fi

  # age‑plugin‑yubikey in systemPackages
  if ! grep -q 'age-plugin-yubikey' "$cfg"; then
    sudo sed -i '/^}$/i\  environment.systemPackages = with pkgs; [ age-plugin-yubikey ];' "$cfg"
  fi
}

if have_yubikey; then
  echo "🔑  YubiKey detected."

  enable_pcscd_once
  sudo nixos-rebuild switch

  if ! sopsKeyValue=$(age-plugin-yubikey -i); then
    echo "ERROR: accessing YubiKey for age private key failed!" >&2
    exit 1
  fi
else
  echo "🔓  No YubiKey detected – falling back to .age file."
  if ! sopsKeyValue=$(age -d sops-nix_primary_key.age); then
    echo "ERROR: decrypting age private key failed!" >&2
    exit 1
  fi
fi

# Persist the key
printf '%s\n' "$sopsKeyValue" >> "$KEYFILE"
chmod 600 "$KEYFILE"
echo "✅  Saved private key to $KEYFILE"

