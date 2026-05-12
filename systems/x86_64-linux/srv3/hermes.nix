{ lib, ... }: {
  # Hermes Agent — AI coding assistant (Nous Research)
  # Docker container managed manually via docker-compose
  # Traefik reverse proxy: hermes.srv3.niedzwiedzinski.cyou → localhost:8642

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
