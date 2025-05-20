{
  config,
  lib,
  pkgs,
  ...
}:

{
  # This will add secrets.yml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  # sops.defaultSopsFile = "/root/.sops/secrets/secrets.yaml";
  sops.defaultSopsFile = "/root/nixos/secrets/secrets.yaml";
  sops.age.keyFile = "/root/.config/sops/age/keys.txt";

  # This is the actual specification of the secrets.
  sops.secrets."tailscale-auth-key" = { };

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale-auth-key".path;
  };

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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEARczdeyItpeaHYdBGOS3YA6rTXPF6YZYtOq1grh+Vq"
    ];
  };

  virtualisation.docker.enable = true;
  services.fail2ban.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
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
    description = "Pull /etc/nixos from upstream and rebuild if it changed";
    after       = [ "network-online.target" ];
    wants       = [ "network-online.target" ];
    path = with pkgs; [
      git
      nix
      coreutils
    ];
    script = ''
      set -eu

      local_head_hash=$(git rev-parse HEAD)
      remote_head_hash=$(git ls-remote https://github.com/klever-lab/nixos HEAD | cut -f 1)

      echo grabbed local and remote hash
      echo "$local_head_hash"
      echo "$remote_head_hash"

      if [[ $remote_head_hash != $local_head_hash ]]; then
        echo detected upstream change, git pulling now
        git pull
        # TODO add error catching if pull fails
        echo git pull succesful, rebuilding system now
        nixos-rebuild switch --upgrade --flake /etc/nixos/#klever-nixos
      else
        echo no change, nothing to do
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      WorkingDirectory = "/etc/nixos";
    };
  };

  environment.sessionVariables = {
    EDITOR = "vim";
  };

  environment.systemPackages = with pkgs; [
    tree
    btop
    wget
    nixfmt-rfc-style
    git
    gh
    rclone
    docker-compose
    lolcat
    age
    sops
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

  system.stateVersion = "24.11";

  nix.settings.experimental-features = [
    "flakes"
  ];
}
