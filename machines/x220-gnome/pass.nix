{ pkgs, ... }:
{
	environment.systemPackages = with pkgs; [
		pkgs.pass-wayland
	];
	
	programs.browserpass.enable = true;

	environment.variables = {
		PASSWORD_STORE_DIR = "$HOME/.local/share/password-store";
	};
}
