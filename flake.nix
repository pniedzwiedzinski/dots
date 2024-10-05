{
	description = "Nixos config flake";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

		home-manager = {
			url = "github:nix-community/home-manager/release-24.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nixos-hardware.url = "github:NixOS/nixos-hardware/master";
		disko.url = "github:nix-community/disko";
  		disko.inputs.nixpkgs.follows = "nixpkgs";
		impermanence.url = "github:nix-community/impermanence";
	};

	outputs = { self, nixpkgs, ... }@inputs: 

		let
		nixosSystem = system: name: nixosModules: nixpkgs.lib.nixosSystem {
		inherit system;
		specialArgs = {inherit inputs;};
		modules = nixosModules ++ [
			({ config, pkgs, ... }:
		let rebuild = pkgs.writeShellScriptBin "rebuild" (builtins.readFile ./rebuild.sh); in
			 {
			 networking.hostName = name;
			environment.systemPackages = [ rebuild ];
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
				inputs.home-manager.nixosModules.default
				{
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;
					home-manager.users.pn = import ./home.nix;
				}
			];
			t14 = nixosSystem "x86_64-linux" "t14" [
				./modules/gnome.nix
					inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen2
					inputs.home-manager.nixosModules.default
					{
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.users.pn = import ./home.nix;
					}
			];
			x220 = nixosSystem "x86_64-linux" "x220" [
				inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x220
				inputs.disko.nixosModules.disko
				inputs.impermanence.nixosModules.impermanence
				inputs.home-manager.nixosModules.default
				{
					home-manager.useGlobalPkgs = true;
					home-manager.useUserPackages = true;
					home-manager.users.pn = import ./home.nix;
				}

			];
		};
	};
}
