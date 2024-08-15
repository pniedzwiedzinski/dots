{ pkgs, ... }:
{
	environment.systemPackages = with pkgs; [
		pkgs.pass-wayland
	];

	environment.variables = {
		PASSWORD_STORE_DIR = "'$HOME/.local/share/password-store'";
	};
}
