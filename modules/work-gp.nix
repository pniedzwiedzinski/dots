{ pkgs, inputs, ... }:
{
	environment.systemPackages = with pkgs; [
		vesktop
		discord
	];
	home-manager.users.pn.xdg.configFile = {
		"discord/settings.json" = {
			text = ''{
				"SKIP_HOST_UPDATE": true
			}'';
			enable = true;
		};
	};
}
