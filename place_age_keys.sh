#!/usr/bin/env nix-shell
#!nix-shell -p usbutils pcsclite ccid age -i bash

set -euo pipefail

if [[ -s "$HOME/.config/sops/age/keys.txt" ]]
then
  # NO DECRYPTION
  echo Detected that "$HOME/.config/sops/age/keys.txt" is present, skipping step
else
  mkdir -p "$HOME/.config/sops/age" 

  # YUBIKEY DECRYPTION
  if lsusb | grep Yubikey
  then
    # setup pcscd for reading yubikey
    sudo ln -sf "$(nix eval --raw nixpkgs#ccid --extra-experimental-features 'nix-command flakes')/pcsc/" /var/lib/
    sudo pcscd --auto-exit

    if ! age -i yubikey_identity -d sops-nix_primary_key.age_yubikey > "$HOME/.config/sops/age/keys.txt"
    then
      echo accessing yubikey for age private key failed!!!
      exit 1
    fi
  # PASSPHRASE DECRYPTION
  else
    echo "(Passphrase for decrypting age private key from file)"
    if ! age -d sops-nix_primary_key.age > "$HOME/.config/sops/age/keys.txt"
    then
      echo decrypting age private key failed!!!
      exit 1
    fi
  fi
fi

