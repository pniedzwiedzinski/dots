{ lib, pkgs, ... }: {
  # Hermes Agent — AI coding assistant (Nous Research)
  virtualisation.oci-containers = {
    backend = "docker";
    containers.hermes = {
      autoStart = true;
      image = "nousresearch/hermes-agent:latest";
      cmd = [ "gateway" "run" ];
      ports = [ "127.0.0.1:8642:8642" ];
      volumes = [ "/srv/hermes/data:/opt/data" ];
      environment = {
        HERMES_HOME = "/opt/data";
        API_SERVER_ENABLED = "true";
        API_SERVER_HOST = "0.0.0.0";
      };
      extraOptions = [
        "--pull=always"
        "--network=hermes-net"
        "--network-alias=hermes"
      ];
    };
  };

  # Docker network for Hermes containers
  systemd.services."docker-network-hermes-net" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.docker}/bin/docker network rm -f hermes-net";
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect hermes-net || ${pkgs.docker}/bin/docker network create hermes-net
    '';
    partOf = [ "docker-hermes.service" ];
    wantedBy = [ "docker-hermes.service" ];
    before = [ "docker-hermes.service" ];
  };

  # Traefik routing: hermes.srv3.niedzwiedzinski.cyou → localhost:8642
  services.traefik.dynamicConfigOptions = lib.mkAfter {
    http.services.hermes = {
      loadBalancer.servers = [{ url = "http://localhost:8642"; }];
    };
    http.routers.hermes = {
      entryPoints = [ "websecure" ];
      rule = "Host(`hermes.srv3.niedzwiedzinski.cyou`)";
      service = "hermes";
      tls.certResolver = "letsencrypt";
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 8642 ];
}
