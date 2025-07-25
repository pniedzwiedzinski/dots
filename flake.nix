{
  description = "Nixos config flake";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://srv2.cachix.org"
      "https://cache.garnix.io"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "srv2.cachix.org-1:GzCcwjhuc/lUbBQ7ARcdiUXeQxgmTeK/NZMfAuA1+Ps="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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
    zen.url = "github:0xc000022070/zen-browser-flake";

    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
    raspberry-pi-nix.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = {
    nixpkgs,
    self,
    ...
  } @ inputs: let
    nixosSystem = system: name: nixosModules:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules =
          nixosModules
          ++ [
            (
              {pkgs, ...}: let
                rebuild = pkgs.writeShellScriptBin "rebuild" (builtins.readFile ./rebuild.sh);
              in {
                networking.hostName = name;
                environment.systemPackages = [rebuild];
                nix = {
                  extraOptions = "extra-experimental-features = nix-command flakes";
                };
              }
            )
            ./machines/${name}
          ];
      };
    server = options:
      nixpkgs.lib.nixosSystem {
        system = options.system or "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = with inputs;
          [
            agenix.nixosModules.default
            ./srv
            ./machines/${options.name}/configuration.nix
            {srv.machineId = options.name;}
          ]
          ++ (options.modules or []);
      };

    deployPkgs = system: let
      pkgs = import nixpkgs {inherit system;};
    in
      import nixpkgs {
        inherit system;
        overlays = [
          inputs.deploy-rs.overlay # or deploy-rs.overlays.default
          (_: super: {
            deploy-rs = {
              inherit (pkgs) deploy-rs;
              inherit (super.deploy-rs) lib;
            };
          })
        ];
      };
  in {
    nixosConfigurations = {
      t14 = nixosSystem "x86_64-linux" "t14" (with inputs; [
        nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen2
        home-manager.nixosModules.default
        nix-index-database.nixosModules.nix-index
        agenix.nixosModules.default
        disko.nixosModules.disko
        # inputs.nix-ld.nixosModules.nix-ld
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.pn = import ./home.nix;
          };
          environment.systemPackages = [
            ronvim.packages.x86_64-linux.default
            pnvf.packages.x86_64-linux.default
            zen.packages.x86_64-linux.default
          ];
        }
      ]);
      srv2 = server {
        name = "srv2";
        system = "aarch64-linux";
        modules = with inputs; [
          raspberry-pi-nix.nixosModules.raspberry-pi
          raspberry-pi-nix.nixosModules.sd-image
        ];
      };
      srv3 = server {
        name = "srv3";
        modules = with inputs; [
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
        ];
      };
      # srv4 = server {
      #   name = "srv4";
      #   modules = (
      #     with inputs;
      #     [
      #       disko.nixosModules.disko
      #       impermanence.nixosModules.impermanence
      #     ]
      #   );
      # };
      srv5 = server {
        name = "srv5";
        modules = with inputs; [
          disko.nixosModules.disko
          # impermanence.nixosModules.impermanence
        ];
      };
    };
    deploy = {
      user = "root";
      nodes = {
        srv2 = {
          hostname = "srv2";
          profiles.system.path = (deployPkgs "aarch64-linux").deploy-rs.lib.activate.nixos self.nixosConfigurations.srv2;
        };
        srv3 = {
          hostname = "srv3";
          profiles.system.path = (deployPkgs "x86_64-linux").deploy-rs.lib.activate.nixos self.nixosConfigurations.srv3;
        };
        # srv4 = {
        #   hostname = "srv4";
        #   profiles.system.path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.srv4;
        # };
        srv5 = {
          hostname = "srv5";
          profiles.system.path = (deployPkgs "x86_64-linux").deploy-rs.lib.activate.nixos self.nixosConfigurations.srv5;
        };
      };
    };
  };
}
