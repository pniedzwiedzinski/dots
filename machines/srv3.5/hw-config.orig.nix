# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sr_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  # fileSystems."/data" = {
  #   device = "/dev/disk/by-uuid/f5a131d0-aaec-4129-8f46-9136abef4f1a";
  #   fsType = "btrfs";
  #   options = [ "subvol=data" ];
  # };
  #
  # fileSystems."/snapshots" = {
  #   device = "/dev/disk/by-uuid/f5a131d0-aaec-4129-8f46-9136abef4f1a";
  #   fsType = "btrfs";
  #   options = [ "subvol=snapshots" ];
  # };
  #
  # fileSystems."/" =
  #   { device = "/dev/disk/by-uuid/6be0c826-51c9-40dd-9210-6d79f329e6e6";
  #     fsType = "ext4";
  #   };
  #
  # fileSystems."/boot" =
  #   { device = "/dev/disk/by-uuid/B286-49E0";
  #     fsType = "vfat";
  #   };
  #
  # swapDevices =
  #   [ { device = "/dev/disk/by-uuid/fb2864f9-5274-42ff-b34e-9b04a13d2576"; }
  #   ];
  #
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
