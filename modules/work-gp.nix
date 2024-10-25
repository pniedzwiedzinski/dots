{ pkgs, ... }:
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

	services.xserver.desktopManager.lxqt = {
		enable = true;
	};

	virtualisation.libvirtd.enable = true;
	programs.virt-manager.enable = true;

	users.users.pn.extraGroups = [ "libvirtd" ];
}
