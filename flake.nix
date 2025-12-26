{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    ronvim.url = "git+https://codeberg.org/veeronniecaw/ronvim.git?ref=main";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    agenix.url = "github:ryantm/agenix";
    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";
    pnvf.url = "github:pniedzwiedzinski/pnvf";
    pnvf.inputs.nixpkgs.follows = "nixpkgs";

    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
    raspberry-pi-nix.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      snowfall = {
        namespace = "dots";
        meta = {
          name = "dots";
          title = "Patryk's configurations";
        };
      };

      deploy = {
        user = "root";
        nodes = builtins.mapAttrs (
          hostname: nixosConfig:
          let
            system = nixosConfig.config.nixpkgs.system;

            pkgs =
              let
                srcPkgs = import inputs.nixpkgs { inherit system; };
              in
              import inputs.nixpkgs {
                inherit system;
                overlays = [
                  inputs.deploy-rs.overlays.default
                  (_: super: {
                    deploy-rs = {
                      inherit (srcPkgs) deploy-rs;
                      inherit (super.deploy-rs) lib;
                    };
                  })
                ];
              };
          in
          {
            hostname = hostname;

            profiles.system = {
              path = pkgs.deploy-rs.lib.activate.nixos nixosConfig;
            };
          }
        ) inputs.self.nixosConfigurations;
      };

      checks = builtins.mapAttrs (
        system: deployLib: deployLib.deployChecks inputs.self.deploy
      ) inputs.deploy-rs.lib;

    };
}
