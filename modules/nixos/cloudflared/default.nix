{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dots.cloudflared;
in
{
  options.dots.cloudflared = {
    enable = lib.mkEnableOption "Cloudflare tunnels";
  };

  config = lib.mkIf cfg.enable {
    services.cloudflared = {
      enable = true;
      tunnels = {
        "cyou" = {
          credentialsFile = "/persist/cloudflared-cyou.json";

          ingress = {
            "niedzwiedzinski.cyou" = "http://127.0.0.1:8888";
            "pics.niedzwiedzinski.cyou" = "http://127.0.0.1:8888";
          };

          default = "http_status:404";
        };
        "pl" = {
          credentialsFile = "/persist/cloudflared-pl.json";

          ingress = {
            "niedzwiedzinski.pl" = "http://127.0.0.1:8888";
            "pics.niedzwiedzinski.pl" = "http://127.0.0.1:8888";
          };

          default = "http_status:404";
        };
      };
    };
  };
}
