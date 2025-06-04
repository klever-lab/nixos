{ pkgs, modulesPath, lib, ... }:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

  environment.etc."auto-install.sh" = {
  mode = "0755";
  text = ''
    #!/usr/bin/env bash
    set -euo pipefail
    set -x

    # --- Detect the first non‑removable block device of type "disk" -----------
    DISK_DEVICE=$(
      lsblk -dnpo NAME,TYPE,RM |
      awk '$2=="disk" && $3==0 {print $1; exit}'
    )

    if [ -z ''${DISK_DEVICE:-} ]; then
      echo "❌  Could not find a suitable disk device" >&2
      exit 1
    fi
    export DISK_DEVICE
    echo "▶  Using ''${DISK_DEVICE} as install target"

    # -------------------------------------------------------------------------
    # Partition, format and mount – **DESTROYS** the content of $DISK_DEVICE
    disko --mode destroy,format,mount /etc/nixos/disk-config.nix

    # Copy configuration into the new system
    git clone https://github.com/klever-lab/nixos /mnt/etc/nixos

    # If the repo lacks hardware‑configuration.nix, uncomment:
    # nixos-generate-config --root /mnt

    nixos-install --no-root-passwd --flake /mnt/etc/nixos
    poweroff -f
  '';
  };

  systemd.services."symlink-auto-install" = {
  description = "Symlink /etc/auto-install.sh to nixos home directory";
  after = [ "home-nixos.mount" ]; # Wait for the home dir to be mounted
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    Type = "oneshot";
    User = "root";
    RemainAfterExit = true;
  };
  script = ''
    # Symlink, overwriting if it exists
    ln -sf /etc/auto-install.sh /home/nixos/auto-install.sh
    chown nixos:nixos /home/nixos/auto-install.sh
  '';
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
    lsof
    age-plugin-yubikey
    fastfetch
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

  services.pcscd.enable = true;

  nix.settings.experimental-features = [
    "flakes"
  ];
}
