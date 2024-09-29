{ pkgs, ... }:
let
	switch-theme = pkgs.writeShellScriptBin "switch-theme" (builtins.readFile ./switch-theme.sh);
in
{
# Enable the X11 windowing system.
	services.xserver.enable = true;

# Enable the GNOME Desktop Environment.
	services.xserver.displayManager.gdm.enable = true;
	services.xserver.desktopManager.gnome.enable = true;
	services.xserver.desktopManager.xterm.enable = false;
	services.xserver.excludePackages = [ pkgs.xterm ];

	environment.gnome.excludePackages = with pkgs.gnome; [
		pkgs.epiphany
		baobab totem yelp file-roller seahorse gnome-clocks pkgs.gnome-connections
			pkgs.gnome-tour
	];

	programs.dconf = {
		enable = true;
		profiles.user.databases = [
			{
				settings = {
					"org/gnome/shell" = {
						favorite-apps = [ "brave-browser.desktop" "org.gnome.Geary.desktop" "org.gnome.Nautilus.desktop" ];
					};

					"org/gnome/desktop/interface" = {
						enable-hot-corners = false;
					};

					"org/gnome/desktop/wm/keybindings" = {
						close = ["<Super>q"];
					};
					
            				"org/gnome/settings-daemon/plugins/media-keys" = {
              					custom-keybindings = [
                					"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
                					"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
             					 ];
					};

            				"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
              					binding = "<Super>Return";
              					command = "kgx";
              					name = "GNOME Console";
            				};

					"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
              					binding = "TaskPane";
              					command = "switch-theme";
              					name = "Switch Theme";
            				};

				};
			}
		];
	};

# Configure keymap in X11
	services.xserver = {
		xkb.layout = "pl";
		xkb.variant = "";
	};

# Configure console keymap
	console.keyMap = "pl2";

# Enable CUPS to print documents.
	services.printing.enable = true;

# Enable sound with pipewire.
	hardware.pulseaudio.enable = false;
	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
# If you want to use JACK applications, uncomment this
#jack.enable = true;


# use the example session manager (no others are packaged yet so this is enabled by default,
# no need to redefine it in your config for now)
#media-session.enable = true;
	};

	boot.plymouth.enable = true;

	environment.systemPackages = with pkgs; [
		switch-theme
		libnotify
		gnome.gnome-boxes
		gnome.file-roller
		brave
		newsflash
		spotify
		fragments
	];

	nixpkgs.config.allowUnfree = true;

	documentation.nixos.enable = false;
}
