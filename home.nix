{ config, pkgs, ... }:
let
  secrets = import ./secrets.nix;
  # wywozik = pkgs.nur.repos.pn.wywozik-todo.override {
  #   configFile = ''
  #     CITY = "Poznań"
  #     STREET = "${secrets.street}"
  #     NUMBER = "${secrets.number}"
  #     HOUSING = "zamieszkana"
  #     TOKEN = "${secrets.todoist}"
  #   '';
  # };

  common_packages = import ./platforms/common-packages.nix pkgs;
  isDarwin = builtins.currentSystem == "x86_64-darwin";
  platformSetup =
    if isDarwin then [
      ./platforms/darwin
    ] else [
      # ./platforms/linux
      # ./programs/rclone.nix
    ];
in
{
  # Errors on linux
  manual.manpages.enable = if isDarwin then true else false;
  dconf.enable = if isDarwin then true else false;

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs; [ obs-wlrobs obs-v4l2sink ];
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "pn";
  home.homeDirectory =
    if isDarwin then "/Users/pn" else "/home/pn";

  imports = [
    # Platform specific config
    # ./programs/zsh
    ./programs/newsboat
    ./programs/git.nix
    ./programs/mpv.nix
    ./programs/sent
  ] ++ platformSetup;

  home.packages = with pkgs; [
    # wywozik
    # Basic
    slop
    xlibs.xdpyinfo
    amfora
    translate-shell
    nix-index
    fzf

    # Handy tools
    skanlite
    imagemagick


    # Misc
    weechat
    todoist
    browserpass
    #minecraft
    spotify-tui
    spotifyd
    # gimp
    pandoc
    texlive.combined.scheme-medium
    zathura
  ]
  ++ common_packages;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";
}
