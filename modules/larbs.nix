{ pkgs, ... }:
let
  pnvim = import ../pkgs/nvim.nix pkgs;
in
{
  environment.systemPackages = with pkgs.nur.repos.pn; [
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

  services.xserver = {
    displayManager.startx.enable = true;
    libinput.enable = true;
  };
}
