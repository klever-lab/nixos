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
      nixosConfigurations.bare-metal = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixosModules/b_config.nix
          ./nixosModules/common.nix
          sops-nix.nixosModules.sops
        ];
      };
      nixosConfigurations.virtual-machine = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixosModules/vm_config.nix
          ./nixosModules/common.nix
          sops-nix.nixosModules.sops
        ];
      };


      # use only with nixos-anywhere
      nixosConfigurations.generic-cloud = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixosModules/vm_config.nix
          ./nixosModules/hardware-configuration.nix
          ./nixosModules/common.nix
          ./nixosModules/vm_disk-config.nix
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
        ];
      };
     nixosConfigurations.digitalocean = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixosModules/vm_config.nix
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
