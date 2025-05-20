{
  config,
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  boot.loader.grub = {
    enable = true;
    devices = "/dv/vda";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
}
