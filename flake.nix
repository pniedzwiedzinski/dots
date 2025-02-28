{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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
  };

  outputs = {nixpkgs, ...} @ inputs: let
    nixosSystem = system: name: nixosModules:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules =
          nixosModules
          ++ [
            ({pkgs, ...}: let
              rebuild = pkgs.writeShellScriptBin "rebuild" (builtins.readFile ./rebuild.sh);
            in {
              networking.hostName = name;
              environment.systemPackages = [rebuild];
              nix = {
                extraOptions = "extra-experimental-features = nix-command flakes";
              };
            })
            ./machines/${name}
          ];
      };
  in {
    nixosConfigurations = {
      x220-gnome = nixosSystem "x86_64-linux" "x220-gnome" [
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x220
        inputs.home-manager.nixosModules.default
        inputs.disko.nixosModules.disko
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.pn = import ./home.nix;
          };
        }
      ];
      t14 = nixosSystem "x86_64-linux" "t14" [
        ./modules/gnome.nix
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen2
        inputs.home-manager.nixosModules.default
        inputs.nix-index-database.nixosModules.nix-index
        inputs.agenix.nixosModules.default
        # inputs.nix-ld.nixosModules.nix-ld
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.pn = import ./home.nix;
          };
          environment.systemPackages = [
            inputs.ronvim.packages.x86_64-linux.default
            inputs.pnvf.packages.x86_64-linux.default
          ];
        }
      ];
      x220 = nixosSystem "x86_64-linux" "x220" [
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x220
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
        inputs.home-manager.nixosModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.pn = import ./home.nix;
          };
        }
      ];
      srv3 = nixosSystem "x86_64-linux" "srv3" [];
    };
  };
}
