{ lib, ... }: {
  # Hermes Agent — AI coding assistant (Nous Research)
  # Traefik reverse proxy: hermes.srv3.niedzwiedzinski.cyou → localhost:8642

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
      };
      extraOptions = [ "--pull=always" ];
    };
  };

  # --- Traefik routing ---
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

  # Allow direct Tailscale access for CLI usage
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 8642 ];
}
