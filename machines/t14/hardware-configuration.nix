# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  #  boot.resumeDevice = "/dev/disk/by-uuid/5f31e34f-75d3-415a-9ed2-88d2c2d630b7";

  # fileSystems."/" =
  #   { device = "/dev/disk/by-uuid/a8ba9580-b089-4cbb-98e3-52faa0a2dca8";
  #     fsType = "btrfs";
  #     options = [ "subvol=@" ];
  #   };

  #fileSystems."/newroot/persist" = {
  #device = "/dev/disk/by-uuid/a8ba9580-b089-4cbb-98e3-52faa0a2dca8";
  ##neededForBoot = true;
  #fsType = "btrfs";
  #options = [ "subvol=persist" ];
  #};
  #
  # fileSystems."/boot" =
  #   { device = "/dev/disk/by-uuid/05C1-F939";
  #     fsType = "vfat";
  #     options = [ "fmask=0022" "dmask=0022" ];
  #   };

  # swapDevices = [ { device = "/dev/disk/by-uuid/5f31e34f-75d3-415a-9ed2-88d2c2d630b7"; } ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0f0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp7s0f3u2.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp3s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  system.stateVersion = "24.05"; # Did you read the comment?
}
