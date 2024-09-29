{ pkgs, ... }:
{




	users.users.pn = {
		isNormalUser = true;
		description = "Patryk Niedźwiedziński";
		extraGroups = [ "networkmanager" "wheel" ];
		packages = with pkgs; [
			gnomeExtensions.gsconnect
		];
	};
	


}
