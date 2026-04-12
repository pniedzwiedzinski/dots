{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.dots.services.monitoring;
in {
  options.dots.services.monitoring = {
    enable = mkEnableOption "Enable Central Monitoring (Loki and Grafana)";
  };

  config = mkIf cfg.enable {
    services.loki = {
      enable = true;
      configuration = {
        server.http_listen_port = 3100;
        auth_enabled = false;

        common = {
          ring = {
            instance_addr = "0.0.0.0";
            kvstore.store = "inmemory";
          };
          replication_factor = 1;
          path_prefix = "/var/lib/loki";
        };

        schema_config = {
          configs = [
            {
              from = "2020-10-24";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };

        limits_config = {
          retention_period = "120d";
        };

        compactor = {
          working_directory = "/var/lib/loki/compactor";
          retention_enabled = true;
          retention_delete_delay = "2h";
          retention_delete_worker_count = 150;
        };
      };
    };

    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "0.0.0.0";
          http_port = 3000;
        };
      };

      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Loki";
            uid = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://127.0.0.1:3100";
            isDefault = true;
          }
        ];

        alerting = {
          contactPoints = {
            settings.contactPoints = [
              {
                name = "TelegramContact";
                receivers = [
                  {
                    uid = "telegram-receiver-1";
                    type = "telegram";
                    settings = {
                      bottoken = "\${TELEGRAM_BOT_TOKEN}"; # To be replaced by Agenix/Sops
                      chatid = "\${TELEGRAM_CHAT_ID}";
                    };
                  }
                ];
              }
            ];
          };

          policies.settings.policies = [
            {
              orgId = 1;
              receiver = "TelegramContact";
              group_by = ["alertname"];
            }
          ];

          rules.settings = {
            groups = [
              {
                name = "BackupAlerts";
                orgId = 1;
                folder = "Alerts";
                interval = "5m";
                rules = [
                  {
                    uid = "backup-failure-1";
                    title = "BorgBackup Job Failed";
                    condition = "A";
                    data = [
                      {
                        refId = "A";
                        datasourceUid = "Loki";
                        model = {
                          editorMode = "code";
                          expr = ''count_over_time({unit=~"borgbackup-.*"} |~ "(?i)(error|failed|fatal)" [5m]) > 0'';
                          queryType = "range";
                        };
                      }
                    ];
                    noDataState = "OK";
                    execErrState = "Error";
                    for = "5m";
                    annotations = {
                      summary = "A BorgBackup job has failed.";
                      description = "Errors detected in BorgBackup journald logs over the last 5 minutes.";
                    };
                  }
                ];
              }
            ];
          };
        };
      };
    };
  };
}
