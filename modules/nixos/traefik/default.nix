{
  config,
  lib,
  ...
}:
let
  cfg = config.dots.traefik;
  domain = cfg.domain;
in
{
  options.dots.traefik = {
    enable = lib.mkEnableOption "Traefik reverse proxy";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "niedzwiedzinski.cyou";
      description = "Primary domain for certificates and routing.";
    };
    letsencryptEmail = lib.mkOption {
      type = lib.types.str;
      default = "patryk@niedzwiedzinski.cyou";
      description = "Email for LetsEncrypt certificate registration.";
    };
    services = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption { type = lib.types.str; };
            port = lib.mkOption { type = lib.types.str; };
          };
        }
      );
      default = [ ];
      description = ''
        Internal services to expose through Traefik.
        Each entry produces a router at `<name>.<machineId>.<domain>`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.permitCertUid = "traefik";

    services.traefik = {
      enable = true;
      staticConfigOptions = {
        accessLog = { };
        certificatesResolvers = {
          tailscale.tailscale = { };
          letsencrypt = {
            acme = {
              email = cfg.letsencryptEmail;
              storage = "/persistent/letsencrypt.json";
              dnsChallenge.provider = "cloudflare";
            };
          };
        };
        entryPoints = {
          web.address = "0.0.0.0:80";
          websecure = {
            address = "0.0.0.0:443";
            http.tls = {
              certResolver = "letsencrypt";
              domains = [
                {
                  main = domain;
                  sans = [ "*.${domain}" ];
                }
              ];
            };
          };
        };
      };
      dynamicConfigOptions =
        let
          generateService = service: {
            loadBalancer.servers = [ { url = "http://localhost:${service.port}"; } ];
          };
          generateRouter = service: {
            entryPoints = [ "web" ];
            rule = "Host(`${service.name}.${config.srv.machineId}.${domain}`)";
            service = service.name;
          };
        in
        {
          http = {
            routers.freshrss = {
              entryPoints = [ "websecure" ];
              tls.certResolver = "tailscale";
            };
          }
          // {
            services = lib.listToAttrs (
              map (s: {
                inherit (s) name;
                value = generateService s;
              }) cfg.services
            );
            routers = lib.listToAttrs (
              map (s: {
                inherit (s) name;
                value = generateRouter s;
              }) cfg.services
            );
          };
        };
    };
  };
}
