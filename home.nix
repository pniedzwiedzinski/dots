{ config, pkgs, ... }:
let
  pnvim = import ./programs/nvim.nix pkgs;
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "pn";
  home.homeDirectory = "/Users/pn";

  imports = [
    ./programs/git.nix
  ];

  home.packages = with pkgs; [
    gnupg
    pnvim
    nur.repos.pn.larbs-mail
  ];

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
