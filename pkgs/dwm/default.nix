pkgs:
  pkgs.nur.repos.pn.dwm.override {
    patches = [
      ./dwm-systray.diff
      ./dwm-center.diff
      ./dwm-autostart.diff
      ./dwm-mediakeys.diff # Patch for slock mediakeys
      # ./dwm-rounded.diff - Resize dont work
    ];
    header_config_file = ./config.h;
  }
