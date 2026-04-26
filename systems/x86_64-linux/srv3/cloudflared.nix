{ config, lib, pkgs, ... }:

{
  services.cloudflared = {
    enable = true;
    tunnels = {
      "nginx" = {
        credentialsFile = "/persist/cloudflared-nginx.json";

        ingress = {
          "niedzwiedzinski.cyou" = "http://127.0.0.1:8888";
          "pics.niedzwiedzinski.cyou" = "http://127.0.0.1:8888";
        };

        default = "http_status:404";
      };
    };
  };
}
