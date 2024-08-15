{ pkgs, ... }:
{
	environment.systemPackages = with pkgs; [
		pkgs.pass-wayland
	];
	
	programs.browserpass.enable = true;

	programs.gnupg.agent = {
		enable = true;
		enableSSHSupport = true;
	};

	environment.variables = {
		PASSWORD_STORE_DIR = "$HOME/.local/share/password-store";
	};
}
