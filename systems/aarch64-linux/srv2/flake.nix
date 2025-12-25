{
  description = "A very basic flake";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://srv2.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "srv2.cachix.org-1:GzCcwjhuc/lUbBQ7ARcdiUXeQxgmTeK/NZMfAuA1+Ps="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
    raspberry-pi-nix.inputs.nixpkgs.follows = "nixpkgs";
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = {
    self,
    nixpkgs,
    raspberry-pi-nix,
    deploy-rs,
  }: {
    nixosConfigurations = {
      srv2 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [raspberry-pi-nix.nixosModules.raspberry-pi raspberry-pi-nix.nixosModules.sd-image ./configuration.nix];
      };
    };

    deploy = {
      user = "root";
      nodes = {
        srv2 = {
          hostname = "srv2";
          profiles.system.path =
            deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.srv2;
        };
      };
    };
  };
}
