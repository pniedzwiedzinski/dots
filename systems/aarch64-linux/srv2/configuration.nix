{ pkgs, lib, ... }:
{
  services.wakeonhttp = {
    enable = true;
    port = 5000;
    gpioPin = 14;
    ollamaUrl = "http://srv5:11434";
  };

  srv.enable = true;
  system.autoUpgrade.enable = false;

  dots.watchdog = {
    enable = true;
    runtimeTime = "20s";
    rebootTime = "30s";
    nmiWatchdog = false;
  };

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
      "nofail"
      "noatime"
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  security.rtkit.enable = true;

  system.stateVersion = "24.11";
}
