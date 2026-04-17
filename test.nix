let
  pkgs = import <nixpkgs> {};
  eval = pkgs.lib.evalModules {
    modules = [
      (import "${pkgs.path}/nixos/modules/services/monitoring/prometheus/pushgateway.nix")
      {
        services.prometheus.pushgateway.enable = true;
        system.stateVersion = "23.11";
      }
    ];
  };
in
eval.config.systemd.services.pushgateway.serviceConfig.DynamicUser
