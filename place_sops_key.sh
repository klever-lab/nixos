# this file will only run on a personal computer or the installation ISO
# thus, we dont worry about pre-installing services, just do a quick check 

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

if have_yubikey; then
  echo "🔑  YubiKey detected."
  echo Enter PIN and touch the device
  if ! sopsKeyValue=$(age -i yubikey_identity -d sops-nix_primary_key.age_yubikey); then
    echo "ERROR: accessing YubiKey for age private key failed!" >&2
    exit 1
  fi

else
  echo "🔓  No YubiKey detected – falling back to .age_password."
  if ! sopsKeyValue=$(age -d sops-nix_primary_key.age_password); then
    echo "ERROR: decrypting age private key failed!" >&2
    exit 1
  fi
fi

# Persist the key
printf '%s\n' "$sopsKeyValue" >> "$KEYFILE"
chmod 600 "$KEYFILE"
echo "✅  Saved private key to $KEYFILE"

