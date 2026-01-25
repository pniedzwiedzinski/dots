{ pkgs, ... }: {
  # Enable Hyprland
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    # Core
    kitty       # Terminal
    waybar      # Status bar
    wofi        # Launcher
    mako        # Notification daemon

    # Utilities
    hyprpaper   # Wallpaper utility
    hypridle    # Idle daemon
    hyprlock    # Screen locker
    grim        # Screenshot tool
    slurp       # Screenshot region selector
    wl-clipboard # Clipboard manager
    networkmanagerapplet # Network manager applet
  ];
}
