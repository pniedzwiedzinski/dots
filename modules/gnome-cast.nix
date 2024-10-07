{ pkgs, ... }:
{
	environment.systemPackages = with pkgs; [
		gnome-network-displays
	];

	networking.firewall.allowedTCPPorts = [ 7236 ];
}
