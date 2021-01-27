{ pkgs, ... }:
{
  hardware.deviceTree = {
    enable = true;
    filter = "*rpi*.dtb";
    overlays = [{
      name = "spi";
      dtsFile = ./spi.dts;
    }];
  };
}
