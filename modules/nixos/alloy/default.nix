{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.dots.services.alloy;
in {
  options.dots.services.alloy = {
    enable = mkEnableOption "Enable Grafana Alloy for log collection";

    lokiEndpoint = mkOption {
      type = types.str;
      default = "http://srv3:3100/loki/api/v1/push";
      description = "The endpoint of the Loki server to send logs to.";
    };
  };

  config = mkIf cfg.enable {
    services.alloy = {
      enable = true;
      configPath = pkgs.writeText "alloy-config.alloy" ''
        loki.source.journal "read" {
          forward_to = [
            loki.relabel.journal.receiver,
          ]
          labels = {
            component = "loki.source.journal",
          }
        }

        loki.relabel "journal" {
          forward_to = [
            loki.write.endpoint.receiver,
          ]

          rule {
            source_labels = ["__journal__systemd_unit"]
            target_label  = "unit"
          }
          rule {
            source_labels = ["__journal__hostname"]
            target_label  = "host"
          }
        }

        loki.write "endpoint" {
          endpoint {
            url = "${cfg.lokiEndpoint}"
          }
        }
      '';
    };
  };
}
