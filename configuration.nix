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

  # This will add secrets.yml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  # sops.defaultSopsFile = "/root/.sops/secrets/secrets.yaml";
  sops.defaultSopsFile = ./secrets/secrets.yaml;

  # This is the actual specification of the secrets.
  sops.secrets."tailscale/auth_key" = {
    owner = config.users.users.klever.name;
  };

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale/auth_key".path;
  };

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

  users.users.klever = {
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
    knownHosts.klever_lab_pem.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEARczdeyItpeaHYdBGOS3YA6rTXPF6YZYtOq1grh+Vq";
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
      cd /etc/nixos/
      local_head_hash=$(git rev-parse HEAD)
      remote_head_hash=$(git ls-remote https://github.com/klever-lab/nixos HEAD)
      if [[ $remote_head_hash != $local_head_hash ]]; then
        git pull
        # TODO add error catching if pull fails
        nixos-rebuild switch --upgrade --flake /etc/nixos/#klever-nixos
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
    age
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
