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

    extraHosts = let
      services = lib.attrsToList config.services.caddy.virtualHosts;
      servicesNames = lib.map (el: el.name) services;
      withSpaces = lib.concatMap (x: [x] ++ [" "]) servicesNames;
      servicesString = lib.concatStrings withSpaces;
      # servicesString = "srv3.niedzwiedzinski.cyou";
    in
      ''
        192.168.1.136 ${servicesString}
        192.168.1.144 srv2.niedzwiedzinski.cyou
      ''
      + lib.readFile (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/StevenBlack/hosts/d2be343994aacdec74865ff8d159cf6e46359adf/alternates/fakenews-gambling-porn/hosts";
        sha256 = "1la5rd0znc25q8yd1iwbx22zzqi6941vyzmgar32jx568j856s8j";
      });
    firewall = {
      enable = true;
      allowedTCPPorts = [53];
      allowedUDPPorts = [53];
    };
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      server = ["1.1.1.1" "8.8.8.8"];
      address = "/.app/192.168.1.136";
    };
  };
}
