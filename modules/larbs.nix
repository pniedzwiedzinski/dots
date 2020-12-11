{ pkgs, ... }:
let
  pnvim = import ../pkgs/nvim.nix pkgs;
  larbs-packages = with pkgs.nur.repos.pn; [
    pnvim
    larbs-mail
    larbs-news
    larbs-music
    dmenu
    dwm
    dwmblocks
    larbs-scripts
    st
  ];
in
{
  imports = [
    ./audio.nix
    ./slock.nix
  ];

  environment.systemPackages = with pkgs; [
    brave
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
