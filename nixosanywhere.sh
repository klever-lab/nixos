set -euo pipefail

if [[ $(id --user) != 0 ]]
then
  echo run as root!
  exit 1
fi

./place_age_keys.sh

if [[ $# -ne 4 ]]
then
  echo
  echo "Usage: ${0##*/} <config_name> <user> <host> <ssh_key_path>"
  echo "e.g.   ${0##*/} digitalocean root 192.168.0.1 ~/.ssh/klever-lab.pem"
  echo
  echo Available Configs: digitalocean, aws-ec2, generic-cloud
  exit 1
else
  # https://nix-community.github.io/nixos-anywhere/howtos/secrets.html
  temp=$(mktemp -d)

  cleanup() {
    rm -rf "$temp"
  }
  trap cleanup EXIT

  install -d -m600 "$temp/root/.config/sops/age/"
  cat "$HOME/.config/sops/age/keys.txt" > "$temp/root/.config/sops/age/keys.txt"

  config_name="$1"
  user="$2"
  host="$3"
  ssh_key_path="$4"
  nixos-anywhere -- --generate-hardware-config nixos-generate-config \
              ./nixosModules/hardware-configuration.nix --flake .#$config_name \
              --target-host $user@$host -i "$ssh_key_path" \
              --extra-files "$temp"
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

