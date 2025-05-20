{
  description = "klever-lab nixos config";

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
      nixosConfigurations.generic-bm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixosModules/baremetal_config.nix
          ./nixosModules/hardware-configuration.nix
          ./nixosModules/common.nix
          ./nixosModules/disk-config.nix
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
        ];
      };
      nixosConfigurations.generic-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixosModules/cloud_config.nix
          ./nixosModules/hardware-configuration.nix
          ./nixosModules/common.nix
          ./nixosModules/disk-config.nix
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
          { disko.devices.disk.disk1.device = "/dev/vda"; }
        ];
      };
     nixosConfigurations.digitalocean = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixosModules/cloud_config.nix
          ./nixosModules/hardware-configuration.nix
          ./nixosModules/common.nix
          ./nixosModules/disk-config.nix
          sops-nix.nixosModules.sops
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
