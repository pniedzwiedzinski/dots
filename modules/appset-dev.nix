{ pkgs, ... }:
{
	environment.systemPackages = with pkgs; [
		vscode
		vim
		jq
		python3
		nodejs
	];
}
