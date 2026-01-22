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

  # Raspberry Pi 3 configuration via nixos-hardware
  # Note: Firmware settings (config.txt) like BOOT_UART and dt-overlays
  # are not managed declaratively by nixos-hardware in the same way as raspberry-pi-nix.
  # If you need specific config.txt settings (like dtoverlay=disable-bt),
  # you may need to apply them manually to /boot/config.txt or use a custom boot loader module.

  # Disable Bluetooth software stack matching previous configuration
  hardware.bluetooth.enable = false;

  security.rtkit.enable = true;
}
