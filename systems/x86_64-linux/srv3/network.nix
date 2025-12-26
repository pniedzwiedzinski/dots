{
  lib,
  pkgs,
  config,
  ...
}: {
  services.vnstat.enable = true;
  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/vnstat";
      user = "vnstatd";
      group = "vnstatd";
    }
  ];

  networking = {
    interfaces.enp1s0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.1.136";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = "192.168.1.1";
    nameservers = ["1.1.1.1" "8.8.8.8"];
    hostName = "srv3";


    firewall = {
      enable = true;
    };
  };

  };
}
