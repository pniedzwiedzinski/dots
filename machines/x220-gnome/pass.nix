{ pkgs, ... }:
{
	environment.systemPackages = with pkgs; [
		pkgs.pass-wayland
	];
	
	programs.browserpass.enable = true;

	programs.gnupg.agent = {
		enable = true;
		pinentryPackage = pkgs.pinentry-gnome3;
		enableSSHSupport = true;
	};

	environment.variables = {
		PASSWORD_STORE_DIR = "$HOME/.local/share/password-store";
	};
}
