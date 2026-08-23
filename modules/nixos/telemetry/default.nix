{
  config,
  lib,
  ...
}:
let
  cfg = config.dots.telemetry;
in
{
  options.dots.telemetry = {
    enable = lib.mkEnableOption "Prometheus, Pushgateway, and cAdvisor telemetry stack";
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.pushgateway = {
      enable = true;
      web.listen-address = "127.0.0.1:9091";
      persistMetrics = true;
    };

    systemd.services.pushgateway.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "pushgateway";
      Group = "pushgateway";
    };
    users.users.pushgateway = {
      isSystemUser = true;
      group = "pushgateway";
    };
    users.groups.pushgateway = { };

    services.prometheus = {
      enable = true;
      port = 9090;
      listenAddress = "127.0.0.1";
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [
                "srv3:9100"
                "backup:9100"
                "srv2:9100"
                "srv5:9100"
              ];
            }
          ];
        }
        {
          job_name = "cadvisor";
          static_configs = [
            {
              targets = [ "127.0.0.1:8080" ];
            }
          ];
        }
        {
          job_name = "pushgateway";
          static_configs = [
            {
              targets = [ "127.0.0.1:9091" ];
            }
          ];
        }
      ];
    };

    services.cadvisor = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 8080;
      extraOptions = [
        "--disable_metrics=percpu,sched,tcp,udp,disk,diskIO,hugetlb,referenced_memory,cpu_topology,resctrl"
      ];
    };

    systemd.services.cadvisor.postStart = lib.mkForce "";
  };
}
