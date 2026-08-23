{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./disko-config.nix
    ./network.nix
    ./persist.nix
    ./nginx.nix
  ];

  disko.devices.disk.main.device = "/dev/sda";

  srv = {
    enable = true;
    machineId = "srv3";
  };

  dots = {
    docker = {
      enable = true;
      storageDriver = "btrfs";
      users = [ "pn" ];
    };
    watchdog.enable = true;
    remoteLogging.enable = true;
    nixGc.enable = true;
    traefik = {
      enable = true;
      services = [
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
        {
          name = "grafana";
          port = "3000";
        }
        {
          name = "workspace";
          port = "3002";
        }
        {
          name = "hermes";
          port = "9119";
        }
      ];
    };
    telemetry.enable = true;
    grafana.enable = true;
    cloudflared.enable = true;
    backup.enable = true;
    hermes.enable = true;
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
    whitelist = [ "192.168.1.0/24" ];
  };

  networking.firewall.allowedTCPPorts = [
    19
    80
    443
    8123
  ];

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 3000 ];

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "pl";

  environment.systemPackages = with pkgs; [
    ripgrep
    curl
    wget
    htop
    git
    vim
    lm_sensors
  ];
}
