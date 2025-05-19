# nixos
os config for klever lab machines

just run bootstrap.sh from anywhere
```
curl --silent https://raw.githubusercontent.com/klever-lab/nixos/refs/heads/main/bootstrap.sh | sudo sh
```
ways to decrypt secrets:
1. `&primary`: password which decrypts sops-nix_primary_key.age
2. `&kian_yubikey`: slot 1 on my personal Yubikey 
