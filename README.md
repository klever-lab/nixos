# nixos
a multipurpose base nixos image

## recommended usage
### headless
```
# switch to root
cd /etc/nixos
rm configuration.nix
wget stuff
nixos-rebuild switch
```

### personal machine
put configuration.nix into /etc/nixos

use a standalone instaallation of home-manager to setup graphical env and etc.

https://nix-community.github.io/home-manager/index.xhtml#sec-install-standalone
