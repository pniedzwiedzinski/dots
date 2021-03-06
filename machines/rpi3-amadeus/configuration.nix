{ config, pkgs, lib, ... }:
{
  imports = [
    ./hyperion.nix
  ];
  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  boot.loader.raspberryPi = {
    enable = true;
    version = 3;
    uboot.enable = true;
    firmwareConfig = ''
      gpu_mem=256
    '';
  };
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  #  !!! If your board is a Raspberry Pi 3, select not latest (5.8 at the time)
  #  !!! as it is currently broken (see https://github.com/NixOS/nixpkgs/issues/97064)
  boot.kernelPackages = pkgs.linuxPackages;

  # !!! Needed for the virtual console to work on the RPi 3, as the default of 16M doesn't seem to be enough.
  # If X.org behaves weirdly (I only saw the cursor) then try increasing this to 256M.
  # On a Raspberry Pi 4 with 4 GB, you should either disable this parameter or increase to at least 64M if you want the USB ports to work.
  boot.kernelParams = ["cma=32M"];

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [ raspberrypifw ];

  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";

  # !!! Adding a swap file is optional, but strongly recommended!
  swapDevices = [ { device = "/swapfile"; size = 1024; } ];

  environment.systemPackages = with pkgs; [
    vim git curl wget
    libraspberrypi
  ];

  users.users.pi = {
    isNormalUser = true;
    home = "/home/pi";
    extraGroups = [ "wheel" "networkmanager" ];
  };
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    libinput.enable = true;
  };

}
