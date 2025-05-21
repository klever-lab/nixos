set -eu

if [[ $(id --user) != 0 ]]
then
  echo run as root!
  exit 1
fi

if [[ -s "$HOME/.config/sops/age/keys.txt" ]]
then
  echo Detected that "$HOME/.config/sops/age/keys.txt" is present, skipping step
else
  mkdir -p "$HOME/.config/sops/age" 

  # check if yubikey is plugged in
  if nix-shell -p usbutils --run 'lsusb | grep Yubikey' # TODO select serial and slot
  then
    # check if decryption failed
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


if [[ $# -eq 4 ]]
then
  config_name="$1"
  user="$2"
  host="$3"
  ssh_key_path="$4"

  # TODO use extrafiles to move over sops nix secrets
  nixos-anywhere -- --generate-hardware-config nixos-generate-config \
              ./nixosModules/hardware-configuration.nix --flake .#$config_name \
              --target-host $user@$host -i "$ssh_key_path"
else
  echo
  echo "Usage: ${0##*/} <config_name> <user> <host> <ssh_key_path>"
  echo "e.g.   ${0##*/} digitalocean root 192.168.0.1 ~/.ssh/klever-lab.pem"
  echo
  echo Available Configs: digitalocean, aws-ec2, generic-cloud
  exit 1
fi








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

