{ config, lib, pkgs, ... }:

{
  services.nginx = {
    enable = true;
    defaultListen = [
      {
        addr = "127.0.0.1";
        port = 8888;
      }
    ];

    virtualHosts = {
      "niedzwiedzinski.cyou" = {
        root = "/srv/www/niedzwiedzinski.cyou";
      };
      "pics.niedzwiedzinski.cyou" = {
        root = "/srv/www/pics.niedzwiedzinski.cyou";
      };
    };
  };
}
