{ config, pkgs, ... }:
let
  pnvim = import ./programs/nvim.nix pkgs;
  common_packages = import ./platforms/common-packages.nix pkgs;
  isDarwin = builtins.currentSystem == "x86_64-darwin";
  platformSetup =
    if isDarwin then ./platforms/darwin else ./platforms/linux;
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "pn";
  home.homeDirectory =
    if isDarwin then "/Users/pn" else "/home/pn";

  imports = [
    # Platform specific config
    platformSetup
    ./programs/zsh
    ./programs/git.nix
  ];

  home.packages = with pkgs; [
    # Basic
    gnupg
    pnvim
    nur.repos.pn.larbs-mail

    # Misc
    browserpass
    spotifyd
    spotify-tui
    # gimp
    slack-dark
    pandoc
    texlive.combined.scheme-basic
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
