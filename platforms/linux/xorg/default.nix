{ pkgs, ... }:
let
  pndwmblocks = pkgs.nur.repos.pn.dwmblocks.override {
    patches = [
      ./dwmblocks.diff
      ./dwmblocks-todo.diff
    ];
  };
  pndwm = pkgs.nur.repos.pn.dwm.override {
    patches = [
      ./dwm-systray.diff
      ./dwm-center.diff
      ./dwm-autostart.diff
      ./dwm-mediakeys.diff # Patch for slock mediakeys
      # ./dwm-rounded.diff - Resize dont work
    ];
    header_config_file = ./config.h;
  };

  todos = pkgs.writeScriptBin "todos" ''
    #!${pkgs.stdenv.shell}
    case $BLOCK_BUTTON in
      1) notify-send "Tasks" "\n$(todoist l | cut -d\  -f5- | sed 's/^/* /')" ;;
	    6) "$TERMINAL" -e "$EDITOR" "$0" ;;
    esac

    echo "✅$(todoist list | wc -l)"
  '';
in
  {
    imports = [
      ./dunst
    ];

    home.packages = with pkgs; [
      mpd
      xcompmgr
      dunst
      nur.repos.pn.dockd
      pndwmblocks
      pndwm
      todos
      playerctl
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
  }
