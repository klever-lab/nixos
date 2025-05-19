set -eu

if [[ $(id --user) != 0 ]]
then
  echo run as root!
  exit 1
fi

rm -rf /etc/nixos/
mkdir /etc/nixos/
cd /etc/nixos/
nix-shell -p git --run 'git clone https://github.com/klever-lab/nixos ./'

# check if sops-nix decryption keys already present
if [[ -f "$HOME/.config/sops/age/keys.txt" ]]
then
  echo detected "$HOME/.config/sops/age/keys.txt" exists, delete keys.txt to recreate sops decryption key
else
  mkdir -p "$HOME/.config/sops/age/"

  # check if yubikey is plugged in
  if nix-shell -p lsusb --run 'lsusb | grep Yubikey'
  then
    # check if decryption failed
    # TODO allow for selection of serial and slot
    if ! nix-shell -p age-plugin-yubikey --run 'age-plugin-yubikey -i --serial 30474330 --slot 1 > "$HOME/.config/sops/age/keys.txt"'
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

nixos-generate-config --show-hardware-config > hardware-configuration.nix
nix-shell -p git --run 'nixos-rebuild switch --upgrade --flake /etc/nixos/#klever-nixos'







# :3






cat << END | lolcat --freq=0.2
██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗
██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝
██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗
██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝
╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗
 ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
████████╗ ██████╗ 
╚══██╔══╝██╔═══██╗
   ██║   ██║   ██║
   ██║   ██║   ██║
   ██║   ╚██████╔╝
   ╚═╝    ╚═════╝ 
████████╗██╗  ██╗███████╗
╚══██╔══╝██║  ██║██╔════╝
   ██║   ███████║█████╗  
   ██║   ██╔══██║██╔══╝  
   ██║   ██║  ██║███████╗
   ╚═╝   ╚═╝  ╚═╝╚══════╝
 ██████╗██╗   ██╗███╗   ███╗
██╔════╝██║   ██║████╗ ████║
██║     ██║   ██║██╔████╔██║
██║     ██║   ██║██║╚██╔╝██║
╚██████╗╚██████╔╝██║ ╚═╝ ██║
 ╚═════╝ ╚═════╝ ╚═╝     ╚═╝
███████╗ ██████╗ ███╗   ██╗███████╗
╚══███╔╝██╔═══██╗████╗  ██║██╔════╝
  ███╔╝ ██║   ██║██╔██╗ ██║█████╗  
 ███╔╝  ██║   ██║██║╚██╗██║██╔══╝  
███████╗╚██████╔╝██║ ╚████║███████╗
╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
END
