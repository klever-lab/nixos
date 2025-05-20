#   1. Ensure we are running as root. Abort if not.
#   2. Guarantee that ~/.config/sops/age/keys.txt exists:
#        a) If a YubiKey is attached, extract the key with age‑plugin‑yubikey.
#        b) Otherwise, decrypt sops-nix_primary_key.age after prompting
#           for its passphrase.
#   3. Decide provisioning mode:
#        • **Remote** (CLI has 4 arguments):
#            – Run nixos‑anywhere, generating a hardware config on‑the‑fly
#              and applying flake `<flake_config>` to <user>@<host>
#              through the supplied SSH key.
#        • **Interactive** (no arguments):
#            – Ask “local or remote?”
#            – If “remote”, print the correct command syntax and exit.
#            – If “local”:
#                · Wipe & recreate /etc/nixos
#                · Clone https://github.com/klever-lab/nixos into it
#                · Generate hardware‑configuration.nix
#                · `nixos-rebuild switch --upgrade --flake /etc/nixos/#klever-nixos`
#   4. Finish with a colourful ASCII‑art welcome via lolcat.

set -eu

if [[ $(id --user) != 0 ]]
then
  echo run as root!
  exit 1
fi

if [[ ! -f "$HOME/.config/sops/age/keys.txt" ]]
then
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

# this triggers if provisioning remote machine
if [[ $# -eq 4 ]]
then
  config_name="$1"
  user="$2"
  host="$3"
  ssh_key_path="$4"

  # TODO use extrafiles to move over sops nix secrets
  nixos-anywhere -- --generate-hardware-config nixos-generate-config \
              ./hardware-configuration.nix --flake .#$config_name \
              --target-host $user@$host -i "$ssh_key_path"
else
  echo 'Are you bootstrapping a local or remote machine? [R|l]'
  read -r remoteType

  if [[ "$remoteType" == "local" || "$remoteType" == "l" ]]
  then
    echo 'Is this a Virtual machine or Bare metal? [v|b]'
    read -r machineType
    if [[ "$machineType" == v ]]
    then
      config_name="virtual-machine"
    else if [[ "$machineType" == b ]]
      config_name="bare-methal"
    fi
  else
    echo for provisioning REMOTE VIRTUAL MACHINES follow these steps
    echo "Usage: ${0##*/} <config_name> <user> <host> <ssh_key_path>"
    echo "e.g.   ${0##*/} digitalocean root 192.168.0.1 ~/.ssh/klever-lab.pem"
    echo
    echo Available Configs: digitalocean, generic
    echo "(check flake.nix for all configs)"
    exit 1
  fi

  rm -rf /etc/nixos/
  mkdir /etc/nixos/
  cd /etc/nixos/
  nix-shell -p git --run 'git clone https://github.com/klever-lab/nixos ./'
  nixos-generate-config --show-hardware-config > hardware-configuration.nix
  nix-shell -p git --run "nixos-rebuild switch --flake /etc/nixos/#$config_name"
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

