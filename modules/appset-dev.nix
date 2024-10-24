{ pkgs, ... }:
{
	environment.systemPackages = with pkgs; [
		vscode
		vim
		jq
		python3
		nodejs
	];

	virtualisation.docker.enable = true;
	users.users.pn.extraGroups = [ "docker" ];
}
