{ pkgs, ... }:
{




	users.users.pn = {
		isNormalUser = true;
		description = "Patryk Niedźwiedziński";
		extraGroups = [ "networkmanager" "wheel" ];
	};
	


}
