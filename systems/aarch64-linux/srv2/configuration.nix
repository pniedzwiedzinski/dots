{
  pkgs,
  lib,
  ...
}: {
  imports = [./wakeonhttp.nix];

  services.wakeonhttp = {
    enable = true;
    port = 5000;
    gpioPin = 14;
    ollamaUrl = "http://srv5:11434";
  };

  srv.enable = true;
  system.autoUpgrade.enable = false;

  # Partition for config.txt and other overlays
  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022" "nofail" "noatime"];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = ["noatime"]; # Extends SD card life
  };

  # Enable U-BOOT
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Reboot after 10 seconds if kernel crashes
  boot.kernelParams = ["panic=10"];

  # Hardware Watchdog: If the kernel freezes entirely (no panic),
  # the hardware will force a reset after 30 seconds.
  systemd.settings.Manager.RuntimeWatchdogSec = "20s";
  systemd.settings.Manager.RebootWatchdogSec = "30s";

  security.rtkit.enable = true;

  system.stateVersion = "24.11";
}
