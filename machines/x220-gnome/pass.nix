{ pkgs, ... }:
{
	environment.systemPackages = with pkgs; [
		pkgs.pass-wayland
	];

	environment.variables = {
		PASSWORD_STORE_DIR = "'$XDG_DATA_HOME/password-store'";
	};
}
