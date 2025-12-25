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

  # https://www.raspberrypi.com/documentation/computers/linux_kernel.html#native-build-configuration
  raspberry-pi-nix.board = "bcm2711";
  hardware = {
    raspberry-pi = {
      config = {
        all = {
          base-dt-params = {
            BOOT_UART = {
              value = 1;
              enable = true;
            };
            uart_2ndstage = {
              value = 1;
              enable = true;
            };
          };
          dt-overlays = {
            disable-bt = {
              enable = true;
              params = {};
            };
          };
        };
      };
    };
  };
  security.rtkit.enable = true;
}
