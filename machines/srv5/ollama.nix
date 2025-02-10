{
  # services.open-webui = {
  #   enable = true;
  #   openFirewall = true;
  #   host = "0.0.0.0";
  # };

  services.nginx = {
    enable = true;

    virtualHosts."_" = {
      # "_" is a catch-all for requests without a domain name
      locations = {
        "/" = {
          proxyPass = "http://localhost:8080";
          proxyWebsockets = true;
        };
        "/api/" = {
          proxyPass = "http://127.0.0.1:11434/";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header  Host "127.0.0.1";
            proxy_set_header  X-Real-IP "127.0.0.1";
            proxy_set_header  X-Forwarded-For "127.0.0.1";
            proxy_set_header  Origin "";
            proxy_set_header  Referer "";
            proxy_set_header  X-Forwarded-Proto $scheme;
          '';
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 11434];
}
