{ pkgs, ... }:
{
  home.packages = with pkgs; [
    spotify
    discord
    python37Packages.pywal
  ];

  imports = [
    ./xorg
    ./user-dirs.nix
    ./gtk.nix
  ];


}
