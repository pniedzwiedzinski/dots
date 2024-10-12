{ pkgs, ... }:
{




	users.users.pn = {
		isNormalUser = true;
		description = "Patryk Niedźwiedziński";
		extraGroups = [ "lp" "scanner" "networkmanager" "wheel" ];
	};
	


}
