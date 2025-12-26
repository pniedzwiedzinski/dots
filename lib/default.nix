{ inputs, lib, ... }:
let
  inherit (inputs) deploy-rs nixpkgs;

  mkDeployPkgs =
    system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    import nixpkgs {
      inherit system;
      overlays = [
        deploy-rs.overlays.default
        (_: super: {
          deploy-rs = {
            inherit (pkgs) deploy-rs;
            inherit (super.deploy-rs) lib;
          };
        })
      ];
    };
in
{
  mkNodes =
    nixosConfigurations:
    let
      validConfigs = lib.filterAttrs (
        _: config: builtins.hasAttr "system" config.config.nixpkgs
      ) nixosConfigurations;
    in
    builtins.mapAttrs (
      hostname: nixosConfig:
      let
        system = nixosConfig.config.nixpkgs.system;
        pkgs = mkDeployPkgs system;
      in
      {
        inherit hostname;

        profiles.system = {
          path = pkgs.deploy-rs.lib.activate.nixos nixosConfig;

        };
      }
    ) validConfigs;
}
