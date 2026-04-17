{ config, lib, ... }:
let
  cfg = config.srv;
in
{
  config = lib.mkIf (cfg.enable && cfg.monitoring) {
    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [ "systemd" ];
      port = 9100;
      listenAddress = "0.0.0.0"; # Note: Binding directly to tailscale interface is tricky as it might not be up initially, but we can restrict via firewall
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 9100 ];
  };
}
