{ config, pkgs, ... }:
let
  screen-orient = pkgs.writeScriptBin "screen-orient" ''
    #!${pkgs.stdenv.shell}
    xrandr --output DSI1 --primary --mode 800x1280 --pos 0x0 --rotate left --output DP1 --off --output HDMI1 --off

xinput set-prop "SIS0457:00 0457:113D" "Coordinate Transformation Matrix" 0 -1 1 1 0 0 0 0 1
  '';
in
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
    screen-orient
  ];

  services.usbmuxd.enable = true;

  services.acpid.enable = true;

  # Battery
  services.tlp.enable = true;

  services.xserver = {
    videoDrivers = [ "intel" ];
    deviceSection = ''
      Option "Backlight" "intel_backlight"
      Option "DIR" "2"
      Option "TearFree" "true"
    '';
  };

}
