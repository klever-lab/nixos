# nixos
os config for klever lab machines

To configure over ssh, run nixosanywhere.sh from your machine
To configure locally, install nixos on the machine then run bootstrap.sh


```
curl --silent https://raw.githubusercontent.com/klever-lab/nixos/refs/heads/main/bootstrap.sh | sudo sh
```


ways to decrypt sops secrets:
1. `&primary`: password which decrypts sops-nix_primary_key.age
2. `&kian_yubikey`: slot 1 on my personal Yubikey 
