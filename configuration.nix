{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  # networking.hostName = "nixos";
  # networking.networkmanager.enable = true;

  time.timeZone = "America/Toronto";

  # internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  users.users.techbro = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  # packages
  environment.systemPackages = with pkgs; [
    tree
    btop
    rclone
    wget
    docker-compose
    git
    vim
  ];
  
  # services
  virtualisation.docker.enable = true;
  services.fail2ban.enable = true;
  services.openssh = {
    enable = true;
    knownHosts.kian.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjHDfwYFZ2Il4jorG3WGQ6kjDOeEEJsdOfpyL5h6yKN";
  };

  # networking.firewall.allowedTCPPorts = [ 22 ];

  system.stateVersion = "24.11";
  # Do NOT change this value
  # (unless you have manually inspected all the changes it would make to your configuration)
  # For more information, see https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
}

