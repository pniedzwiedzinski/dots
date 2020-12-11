{ config, pkgs, ... }:

{

  imports = [
	../base.nix
	../pl.nix
	../../modules/larbs.nix
  ];

  networking.hostName = "hp-compaq";

  environment.systemPackages = with pkgs; [
  ];
}

