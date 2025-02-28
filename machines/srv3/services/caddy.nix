let
  root = "srv3";
in {
  services.jellyfin.enable = true;

  services.caddy = {
    enable = true;
    globalConfig = ''
      auto_https off
    '';
    virtualHosts = {
      "http://test.app".extraConfig = ''
        reverse_proxy http://localhost:8096
      '';
      "http://img.${root}" = {
        # useACMEHost = root;
        extraConfig = ''
          reverse_proxy http://localhost:2283
        '';
      };
      "http://home.${root}" = {
        # useACMEHost = root;
        extraConfig = ''
          reverse_proxy http://localhost:8123
        '';
      };
      "http://docs.${root}" = {
        # useACMEHost = root;
        extraConfig = ''
          reverse_proxy http://localhost:8000
        '';
      };
      "http://changedetection.${root}" = {
        # useACMEHost = root;
        extraConfig = ''
          reverse_proxy http://localhost:5000
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443] ++ [2283 8123 8000 5000];
}
