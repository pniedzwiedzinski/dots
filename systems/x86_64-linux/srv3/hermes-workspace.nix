{ lib, pkgs, ... }: {
  # Hermes Workspace — web UI for Hermes Agent
  virtualisation.oci-containers.containers."hermes-workspace" = {
    autoStart = true;
    image = "ghcr.io/outsourc-e/hermes-workspace:latest";
    ports = [ "127.0.0.1:3001:3000" ];
    environment = {
      HERMES_API_URL = "http://hermes:8642";
      COOKIE_SECURE = "1";
      TRUST_PROXY = "1";
      HERMES_PASSWORD = "changeme123";
    };
    extraOptions = [
      "--pull=always"
      "--network=hermes-net"
    ];
    dependsOn = [ "hermes" ];
  };

  # Traefik routing: workspace.srv3.niedzwiedzinski.cyou → localhost:3001
  services.traefik.dynamicConfigOptions = lib.mkAfter {
    http.services.hermes-workspace = {
      loadBalancer.servers = [{ url = "http://localhost:3001"; }];
    };
    http.routers.hermes-workspace = {
      entryPoints = [ "websecure" ];
      rule = "Host(`workspace.srv3.niedzwiedzinski.cyou`)";
      service = "hermes-workspace";
      tls.certResolver = "letsencrypt";
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 3001 ];
}
