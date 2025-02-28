{
  description = "Flake for building a Raspberry Pi Zero 2 SD image";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = {
    self,
    nixpkgs,
    agenix,
    deploy-rs,
  }: rec {
    nixosConfigurations = {
      zero2w = nixpkgs.lib.nixosSystem {
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ./zero2w.nix
          agenix.nixosModules.default
        ];
      };
    };

    deploy = {
      user = "root";
      nodes = {
        zero2w = {
          hostname = "zero2w";
          profiles.system.path =
            deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.zero2w;
        };
      };
    };
  };
}
