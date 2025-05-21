if [[ -s "$HOME/.config/sops/age/keys.txt" ]]
then
  echo Detected that "$HOME/.config/sops/age/keys.txt" is present, skipping step
else
  mkdir -p "$HOME/.config/sops/age" 

  # check if yubikey is plugged in
  if nix-shell -p usbutils --run 'lsusb | grep Yubikey'
  then
    # setup pcscd for reading yubikey
    nix-shell -p pcsclite ccid --run '''
    sudo ln -s $(nix eval --raw nixpkgs#ccid)/pcsc/ /var/lib/
    sudo pcscd --auto-exit
    '''
    # check if decryption failed
    if ! nix-shell -p age-plugin-yubikey --run 'age-plugin-yubikey -i > "$HOME/.config/sops/age/keys.txt"'
    then
      echo accessing yubikey for age private key failed!!!
      exit 1
    fi
  else
    echo "(Passphrase for decrypting age private key from file)"
    # check if decryption failed
    if ! nix-shell -p age --run 'cat sops-nix_primary_key.age | age -d > "$HOME/.config/sops/age/keys.txt"'
    then
      echo decrypting age private key failed!!!
      exit 1
    fi
  fi
fi

