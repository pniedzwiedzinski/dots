{
  pkgs,
  lib,
  config,
  ...
}:
let
  domain = "niedzwiedzinski.cyou";
in
{
  imports = [
    ./disko-config.nix

    ./network.nix
    ./persist.nix
    ./docker.nix
    ./backup.nix
  ];

  disko.devices.disk.main.device = "/dev/sdb";

  srv = {
    enable = true;
    machineId = "srv3";
  };

  services.openssh = {
    enable = true;
    ports = lib.mkForce [ 19 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "pn" ];
    };
  };

  services.sshguard = {
    enable = true;
    whitelist = [
      "192.168.1.0/24"
    ];
  };

  networking.firewall.allowedTCPPorts = [
    19
    80
    443
    8123
  ];

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8"; # Less confusing locale than polish one
  console.keyMap = "pl";

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
  };

  environment.systemPackages = with pkgs; [
    ripgrep
    curl
    wget
    htop
    git
    vim
    lm_sensors
  ];

  services = {
    tailscale = {
      enable = true;
      permitCertUid = "traefik";
    };

    traefik = {
      enable = true;
      staticConfigOptions = {
        certificatesResolvers = {
          tailscale.tailscale = { };
          letsencrypt = {
            acme = {
              email = "patryk@niedzwiedzinski.cyou";
              storage = "/persistent/letsencrypt.json";
              dnsChallenge = {
                provider = "cloudflare";
              };
            };
          };
        };

        entryPoints = {
          web = {
            address = "0.0.0.0:80";
            # http.redirections.entryPoint = {
            #   to = "websecure";
            #   scheme = "https";
            #   permanent = true;
            # };
          };

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
            loadBalancer.servers = [ { url = "http://localhost:" + service.port; } ];
          };
          generateRouter = service: {
            entryPoints = [ "web" ];
            rule = "Host(`" + service.name + ".${config.srv.machineId}.${domain}`)";
            service = service.name;
          };
          makeServices = servicesList: {
            services = lib.listToAttrs (
              map (s: {
                inherit (s) name;
                value = generateService s;
              }) servicesList
            );
            routers = lib.listToAttrs (
              map (s: {
                inherit (s) name;
                value = generateRouter s;
              }) servicesList
            );
          };
        in
        {
          http = {
            routers = {
              freshrss = {
                entryPoints = [ "websecure" ];
                tls.certResolver = "tailscale";
              };
            };
          }
          // makeServices [
            {
              name = "home-assistant";
              port = "8123";
            }
            {
              name = "paperless";
              port = "8000";
            }
            {
              name = "paperless-gpt";
              port = "8001";
            }
            {
              name = "changedetection";
              port = "5000";
            }
            {
              name = "rss";
              port = "8081";
            }
            {
              name = "immich";
              port = "2283";
            }
            {
              name = "n8n";
              port = "5678";
            }
            {
              name = "ai";
              port = "1111";
            }
            {
              name = "research";
              port = "3001";
            }
          ];
        };
    };
  };
}
