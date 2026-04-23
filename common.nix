# https://tailscale.com/docs/solutions/set-up-nixos-minecraft
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    htop
    tailscale
  ];
  services.tailscale.enable = true;
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
};
