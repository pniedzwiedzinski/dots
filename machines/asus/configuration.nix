{ config, pkgs, ... }:

{

  imports = [
    ../base.nix
    ../pl.nix
    ../../modules/larbs.nix
    ../../modules/trackpad.nix
  ];

  networking = {
    hostName = "asus-t100";

    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
  };


  environment.systemPackages = with pkgs; [
    libimobiledevice
  ];

  services.usbmuxd.enable = true;

  services.acpid.enable = true;

  # Battery
  services.tlp.enable = true;

  services.xserver = {
    videoDrivers = [ "intel" ];
    deviceSection = ''
      Option      "Backlight"  "intel_backlight"
      Option "DIR" "2"
      Option "TearFree" "true"
    '';
  };

}
