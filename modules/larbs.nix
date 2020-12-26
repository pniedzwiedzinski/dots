{ pkgs, ... }:
let
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
    st
  ];
in
{
  imports = [
    ./personal.nix
    ./audio.nix
    ./slock.nix
  ];

  environment.systemPackages = with pkgs; [
    ## Scripts utils
    #TODO: move to larbs-scripts
    maim
    xclip
    xdotool
    lm_sensors
    mpc_cli

    todos
    brave
    tdesktop
  ] ++ larbs-packages;

  environment.variables = {
    TERM = "st";
    BROWSER = "brave";
  };

  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    libinput.enable = true;
  };

}
