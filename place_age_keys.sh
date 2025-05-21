#!/usr/bin/env nix-shell
#!nix-shell -p usbutils pcsclite ccid age-plugin-yubikey age -i bash

set -eu

if [[ -s "$HOME/.config/sops/age/keys.txt" ]]
then
  echo Detected that "$HOME/.config/sops/age/keys.txt" is present, skipping step
else
  mkdir -p "$HOME/.config/sops/age" 

  # check if yubikey is plugged in
  if lsusb | grep Yubikey
  then
    # setup pcscd for reading yubikey
    sudo ln -sf "$(nix eval --raw nixpkgs#ccid)/pcsc/" /var/lib/
    sudo pcscd --auto-exit

    # check if decryption failed
    if ! age-plugin-yubikey -i > "$HOME/.config/sops/age/keys.txt"
    then
      echo accessing yubikey for age private key failed!!!
      exit 1
    fi
  else
    echo "(Passphrase for decrypting age private key from file)"
    # check if decryption failed
    if ! age -d sops-nix_primary_key.age > "$HOME/.config/sops/age/keys.txt"
    then
      echo decrypting age private key failed!!!
      exit 1
    fi
  fi
fi

