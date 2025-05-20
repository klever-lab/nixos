{
  description = "klever-lab nixos configs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    disko.url = "github:nix-community/disko";
  };

  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      disko,
    }:
    {
      # use only with nixos-rebuild
      nixosConfigurations.klever-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixosModules/common.nix
          ./nixosModules/hardware-configuration.nix
          sops-nix.nixosModules.sops

          ./nixosModules/bm_config.nix
        ];
      };

      # use only with nixos-anywhere
      nixosConfigurations.generic-cloud = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixosModules/common.nix
          ./nixosModules/hardware-configuration.nix
          sops-nix.nixosModules.sops

          ./nixosModules/vm_config.nix
          ./nixosModules/vm_disk-config.nix
          disko.nixosModules.disko
        ];
      };
     nixosConfigurations.digitalocean = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixosModules/common.nix
          ./nixosModules/hardware-configuration.nix
          sops-nix.nixosModules.sops

          ./nixosModules/vm_config.nix
          ./nixosModules/vm_disk-config.nix
          disko.nixosModules.disko
          { disko.devices.disk.disk1.device = "/dev/vda"; }
          {
            # do not use DHCP, as DigitalOcean provisions IPs using cloud-init
            networking.useDHCP = nixpkgs.lib.mkForce false;
            services.cloud-init = {
              enable = true;
              network.enable = true;
              settings = {
                datasource_list = [ "ConfigDrive" ];
                datasource.ConfigDrive = { };
              };
            };
          }
        ];
      };
    };
}
