{ config, lib, pkgs, ... }:

{
  # Enable the hardware watchdog
  # The systemd watchdog module will ping the hardware watchdog device
  # every RuntimeWatchdogSec/2. If the system completely hangs and fails
  # to ping the watchdog for 60 seconds, the hardware will reboot the system.
  systemd.watchdog = {
    runtimeTime = "60s";
    rebootTime = "10m";
  };

  # Make sure the kernel panic automatically reboots after 10 seconds
  boot.kernelParams = [
    "panic=10"
    "nmi_watchdog=1" # Ensure NMI watchdog is enabled
  ];
}
