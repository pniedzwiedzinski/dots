## My default user
{ pkgs, ... }:

let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-20.09.tar.gz";
    sha256 = "0cxnh7g1nagmdkl40jsg5kvfq6mdpg21k7b9y0i713p6zsgd48jl";
  };
in
  {

    imports = [
      (import "${home-manager}/nixos")
    ];

    users.users.pn = {
      isNormalUser = true;
      extraGroups = [ "wheel" "audio" ];
    };

    home-manager.users.pn = {
      imports = [
        ../home.nix
      ];

      xsession = {
        enable = true;
        windowManager.command = "dbus-run-session -- dwm";
        profileExtra = ''
      # Fix Gnome Apps Slow  Start due to failing services
      # Add this when you include flatpak in your system
          dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

          mpd &			# music player daemon-you might prefer it as a service though
          remaps &		# run the remaps script, switching caps/esc and more; check it for more info
          setbg &			# set the background with the `setbg` script
      #xrdb $\{XDG_CONFIG_HOME:-$HOME/.config}/Xresources &	# Uncomment to use Xresources colors/settings on startup
          xcompmgr &
      # picom &
          dunst &			# dunst for notifications
          xset r rate 300 50 &	# Speed xrate up
      # unclutter &		# Remove mouse when idle
      #sxhkd &
          dockd --daemon &
          for app in `ls ~/.config/autostart/*.desktop`; do
          $(grep '^Exec' $app | sed 's/^Exec=//') &
          done
          sleep .5 && screen-orient &
        '';
        scriptPath = ".xinitrc";
      };

    };

  ## Although it's less secure I tend not to have sensitive data on my machines
  security.sudo.wheelNeedsPassword = false;
}
