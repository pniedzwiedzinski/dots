{ pkgs, ... }:
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
				lockAll = true;
				settings = {
					"org/gnome/shell" = {
						favorite-apps = [ "brave-browser.desktop" "org.gnome.Geary.desktop" "org.gnome.Nautilus.desktop" ];
					};

					"org/gnome/desktop/wm/keybindings" = {
						close = ["<Super>q"];
					};
					
            				"org/gnome/settings-daemon/plugins/media-keys" = {
              					custom-keybindings = [
                					"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
             					 ];
					};

            				"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
              					binding = "<Super>Return";
              					command = "kgx";
              					name = "GNOME Console";

            				};

				};
			}
		];
	};

	##services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
		##[org.gnome.shell]
		##favorite-apps = [ "brave-browser.desktop", "org.gnome.Geary.desktop", "org.gnome.Nautilus.desktop" ]
##
		##[org.gnome.desktop.wm.keybindings]
		##close = ["<Super>q"]
##
		##[org.gnome.settings-daemon.plugins.media-keys]
		##custom-keybindings = ["org/gnome/settings-daemon/plugins/media-keys/custom0/"]
##
		##[org.gnome.settings-daemon.plugins.media-keys.custom0]
		##binding = ["<Super><Enter>"]
		##command = ["kgx"]
		##name = ["GNOME Console"]
	##'';

# Configure keymap in X11
	services.xserver = {
		layout = "pl";
		xkbVariant = "";
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

	environment.systemPackages = with pkgs; [
		libnotify
		gnome.gnome-boxes
		gnome.file-roller
		brave
		newsflash
		spotify
		fragments
	];

# Wallpaper

	nixpkgs.overlays = [
      (self: super: {
        gnome = super.gnome.overrideScope' (selfg: superg: {
          gnome-shell = superg.gnome-shell.overrideAttrs (old: {
            patches = (old.patches or []) ++ [
              (let
                bg = pkgs.fetchurl {
		  url = "https://unsplash.com/photos/fzYFRJREmnQ/download?ixid=M3wxMjA3fDB8MXxzZWFyY2h8MTV8fHBvbGlzaCUyMG1vdW50YWluc3xlbnwwfHx8fDE3MjY0MjkwOTd8MA&force=true&h=1080";
		  sha256 = "sha256-4vK8x7bSm2DogBqb494MondL1q0Q549zc0EgNc33XmQ=";
                };
              in pkgs.writeText "bg.patch" ''
                --- a/data/theme/gnome-shell-sass/widgets/_login-lock.scss
                +++ b/data/theme/gnome-shell-sass/widgets/_login-lock.scss
                @@ -15,4 +15,5 @@ $_gdm_dialog_width: 23em;
                 /* Login Dialog */
                 .login-dialog {
                   background-color: $_gdm_bg;
                +  background-image: url('file://${bg}');
                 }
              '')
            ];
          });
        });
      })
    ];

	nixpkgs.config.allowUnfree = true;

	documentation.nixos.enable = false;
}
