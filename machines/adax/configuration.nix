{ config, pkgs, ... }:

{

  imports = [
    ../base.nix
    ../pl.nix
    ../../modules/larbs.nix
  ];

  networking.hostName = "adax";

  environment.systemPackages = with pkgs; [
  ];

}
