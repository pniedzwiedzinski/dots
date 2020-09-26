{
  imports = [
    ./user-dirs.nix
    ./gtk.nix
    ./xorg.nix
  ];

  home.packages = [
    spotify
    discord
    python37Packages.pywal
  ];
}
