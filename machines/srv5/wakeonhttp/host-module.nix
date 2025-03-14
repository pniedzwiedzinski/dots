{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.wakeonhttp;
  pythonEnv = pkgs.python3.withPackages (ps:
    with ps; [
      flask
    ]);
in {
  options = {
    services.wakeonhttp = {
      enable = mkEnableOption "wakeonhttp Manager";

      port = mkOption {
        type = types.port;
        default = 5000;
        description = "Reverse proxy port";
      };

      shutdownTimeout = mkOption {
        type = types.ints.positive;
        default = 600;
        description = "Timeout in seconds for shutdown";
      };

      forwardUrl = mkOption {
        type = types.str;
        default = "http://localhost:8000";
        description = "Service to pass requests";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.shutdown-manager = {
      description = "Shutdown Manager Service";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = ''
          ${pythonEnv.interpreter} ${./host_proxy.py} \
            --port=${toString cfg.port} \
            --timeout=${toString cfg.shutdownTimeout} \
            --forward-url=${cfg.forwardUrl}
        '';
        Restart = "always";
        User = "root";
      };
    };
  };
}
