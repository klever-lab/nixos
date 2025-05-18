{
  description = "klever-lab nixos config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      sops-nix
    }:
    {
      nixosConfigurations.klever-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
    };
}
