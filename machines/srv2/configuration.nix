{
  pkgs,
  lib,
  ...
}: {
  time.timeZone = "Europe/Warsaw";
  networking = {
    hostName = "srv2";
    useDHCP = false;
    interfaces = {
      wlan0.useDHCP = true;
      eth0.useDHCP = true;
    };
  };
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

  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  networking.firewall.allowedTCPPorts = [22];

  services.tailscale.enable = true;

  security.sudo.wheelNeedsPassword = false;
  nix.settings.trusted-users = ["@wheel"];
  nix.settings.experimental-features = ["flakes" "nix-command"];

  users = {
    users = {
      pn = {
        description = "patryk";
        isNormalUser = true;
        extraGroups = ["wheel"];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqlCe4ovKa/Gwl5xmgu9nvVPmFXMgwdeLRYW7Gg7RWx pniedzwiedzinski19@gmail.com"
        ];
      };
    };
  };
}
