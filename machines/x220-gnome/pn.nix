{ pkgs, ... }:
{




	users.users.pn = {
		isNormalUser = true;
		description = "Patryk Niedzwiedzinski";
		extraGroups = [ "networkmanager" "wheel" ];
		packages = with pkgs; [
			gnomeExtensions.gsconnect
		];
	};
	


}
