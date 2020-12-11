{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "hp-compaq";

  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;

  environment.systemPackages = with pkgs; [
  ];

}

