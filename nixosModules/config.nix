{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = lib.mkDefault null;
  boot.loader.grub.useOSProber = true;
}
