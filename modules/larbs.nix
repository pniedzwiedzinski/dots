{ pkgs, ... }:
let
  xwallpaper = (import (pkgs.fetchzip {
    url = "https://github.com/nixos/nixpkgs/archive/7138a338b58713e0dea22ddab6a6785abec7376a.zip";
    sha256 = "sha256:1asgl1hxj2bgrxdixp3yigp7xn25m37azwkf3ppb248vcfc5kil3";
  }) { }).xwallpaper;
  pnvim = import ../pkgs/nvim.nix pkgs;
  pndwm = import ../pkgs/dwm pkgs;
  pndwmblocks = import ../pkgs/dwmblocks pkgs;
  todos = import ../pkgs/dwmblocks/todos.nix pkgs;
  larbs-packages = with pkgs.nur.repos.pn; [
    pnvim
    larbs-mail
    larbs-news
    (larbs-music.override { musicDir = "~/music"; })
    dmenu
    pndwm
    pndwmblocks
    larbs-scripts
    (st.override { conf = ../pkgs/st.config.h; } )
  ];
in
{
  imports = [
    ./personal.nix
    ./audio.nix
    ./slock.nix
  ];

  gtk.iconCache.enable = true;

  environment.shellAliases = {
    cmus = "screen -q -r -D cmus || screen -S cmus /run/current-system/sw/bin/cmus";
  };

  environment.systemPackages = with pkgs; [
    ## Scripts utils
    #TODO: move to larbs-scripts
    maim
    xclip
    xdotool
    lm_sensors
    mpc_cli
    python3Packages.pywal
    xwallpaper
    xcompmgr
    screen

    cmus

    nur.repos.pn.groff

    hicolor-icon-theme
    gnome3.adwaita-icon-theme

    playerctl

    todos
    brave
    tdesktop
  ] ++ larbs-packages;

  environment.variables = {
    TERM = "st";
    TERMINAL = "st";
    BROWSER = "brave";
    GTK_THEME = "Adwaita:dark";
  };

  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    libinput.enable = true;
  };

}
