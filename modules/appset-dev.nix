{ pkgs, ... }:
{
	environment.systemPackages = with pkgs; [
		vscode
		vim
		jq
		python3
		python3Packages.pip
		nodejs
	];

	virtualisation.docker.enable = true;
	users.users.pn.extraGroups = [ "docker" ];
}
