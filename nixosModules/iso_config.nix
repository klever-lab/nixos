{ pkgs, modulesPath, lib, ... }:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];

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
