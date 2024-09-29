{
	description = "Nixos config flake";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

		home-manager = {
			url = "github:nix-community/home-manager/release-24.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nixos-hardware.url = "github:NixOS/nixos-hardware/master";
	};

	outputs = { self, nixpkgs, ... }@inputs: {
		nixosConfigurations = {
			nixos = nixpkgs.lib.nixosSystem {
				specialArgs = {inherit inputs;};
				modules = [
					./machines/x220-gnome/configuration.nix
	
						inputs.home-manager.nixosModules.default
						{
							home-manager.useGlobalPkgs = true;
							home-manager.useUserPackages = true;
							home-manager.users.pn = import ./home.nix;
						}
	
				];
			};
			t14 = nixpkgs.lib.nixosSystem {
				specialArgs = {inherit inputs;};
				modules = [
					./machines/t14/configuration.nix
					./modules/gnome.nix
					inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen2
					inputs.home-manager.nixosModules.default
						{
							home-manager.useGlobalPkgs = true;
							home-manager.useUserPackages = true;
							home-manager.users.pn = import ./home.nix;
						}
	
				];
			};
		};
	};
}
