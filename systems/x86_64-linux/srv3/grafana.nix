{ config, lib, ... }:
{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        domain = "grafana.srv3.niedzwiedzinski.cyou";
      };
    };

    provision = {
      enable = true;
      dashboards.settings.providers = [
        {
          name = "Homelab Dashboards";
          options.path = "/etc/grafana/dashboards";
        }
      ];
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://127.0.0.1:9090";
          isDefault = true;
          uid = "prometheus-default";
        }
      ];

      alerting = {
        contactPoints.settings.contactPoints = [
          {
            name = "Telegram";
            receivers = [
              {
                type = "telegram";
                uid = "telegram-receiver";
                settings = {
                  bottoken = "$TELEGRAM_BOT_TOKEN";
                  chatid = "$TELEGRAM_CHAT_ID";
                };
              }
            ];
          }
        ];

        policies.settings.policies = [
          {
            receiver = "Telegram";
            group_by = [ "grafana_folder" "alertname" ];
          }
        ];

        rules.settings.groups = [
          {
            name = "Homelab Alerts";
            orgId = 1;
            folder = "Infrastructure";
            interval = "1m";
            rules = [
              {
                uid = "systemd_failed";
                title = "Systemd Unit Failed";
                condition = "A";
                data = [
                  {
                    refId = "A";
                    datasourceUid = "prometheus-default";
                    model = {
                      expr = "node_systemd_unit_state{state=\"failed\"} == 1";
                      refId = "A";
                    };
                  }
                ];
                noDataState = "NoData";
                execErrState = "Error";
                for = "5m";
                annotations = {
                  summary = "Systemd unit failed on {{ $labels.instance }}";
                  description = "Unit {{ $labels.name }} is in failed state.";
                };
              }
              {
                uid = "borg_backup_stale";
                title = "Borg Backup Stale or Failed";
                condition = "A";
                data = [
                  {
                    refId = "A";
                    datasourceUid = "prometheus-default";
                    model = {
                      expr = "(time() - backup_last_success_time{job=\"backup_borg\"}) > 86400 or job_executed_successful{job=\"backup_borg\"} == 0";
                      refId = "A";
                    };
                  }
                ];
                noDataState = "Alerting"; # If pushgateway dies or we lose data, trigger alert
                execErrState = "Error";
                for = "5m";
                annotations = {
                  summary = "Borg backup failed or is stale on {{ $labels.instance }}";
                  description = "The borg backup hasn't run successfully in over 24 hours or the last run failed.";
                };
              }
            ];
          }
        ];
      };
    };
  };

  # Link our pre-created dashboards into the location Grafana expects
  environment.etc."grafana/dashboards/homelab.json".source = ./dashboards/homelab.json;

  # Load Telegram Bot secrets from environment file
  systemd.services.grafana.serviceConfig.EnvironmentFile = [ "-/persist/telegram-bot.env" ];
}
