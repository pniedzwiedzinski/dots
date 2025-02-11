{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:serokell/deploy-rs";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = {
    nixpkgs,
    disko,
    deploy-rs,
    impermanence,
    self,
    ...
  }: {
    # Use this for all other targets
    # nixos-anywhere --flake .#srv3 --generate-hardware-config nixos-generate-config ./hardware-configuration.nix <hostname>
    nixosConfigurations.srv3 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
        ./configuration.nix
        ./hardware-configuration.nix
      ];
    };

    deploy = {
      user = "root";
      nodes = {
        srv3 = {
          hostname = "srv5"; #TODO FIX
          profiles.system.path =
            deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.srv3;
        };
      };
    };
  };
}
