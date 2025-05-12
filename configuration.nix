{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];
  system.stateVersion = "24.11";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Toronto";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };

  users.users.nix-user = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
  };

  virtualisation.docker.enable = true;
  services.fail2ban.enable = true;
  services.openssh = {
    enable = true;
    knownHosts.kian.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjHDfwYFZ2Il4jorG3WGQ6kjDOeEEJsdOfpyL5h6yKN";
  };

  systemd.timers."auto-update" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "auto-update.service";
    };
  };
  systemd.services."auto-update" = {
    script = ''
      set -eu
      cd /etc/nixos
      if [[ `git status --porclein` ]]; then
        git pull
        nixos-rebuild switch --upgrade
      fi
      "
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  environment.systemPackages = with pkgs; [
    tree
    btop
    wget
    nixfmt
    git
    gh
    rclone
    docker-compose
    lolcat
    ((vim_configurable.override { }).customize {
      name = "vim";
      vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
        start = [
          vim-nix
          vim-lastplace
        ];
        opt = [ ];
      };
      vimrcConfig.customRC = ''
        syntax on
        set number
        set tabstop=2
        set shiftwidth=2
        set expandtab
        set smarttab
        set autoindent
        " ...
      '';
    })
  ];
}
