pkgs:
{
  home.packages = with pkgs; [
    nur.repos.pn.pndwm
    mpd
    xcompmgr
    picom
    dunst
    unclutter
    nur.repos.pn.dockd
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
      picom &
      dunst &			# dunst for notifications
      xset r rate 300 50 &	# Speed xrate up
      unclutter &		# Remove mouse when idle
      #sxhkd &
      dockd --daemon &
      screen-orient &
      for app in `ls ~/.config/autostart/*.desktop`; do
        $(grep '^Exec' $app | sed 's/^Exec=//') &
      done
    '';
    scriptPath = ".xinitrc";
  };
}
