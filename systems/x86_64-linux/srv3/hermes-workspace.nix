{
  lib,
  pkgs,
  ...
}: {
  # Hermes Workspace — web UI for Hermes Agent
  virtualisation.oci-containers.containers."hermes-workspace" = {
    autoStart = true;
    image = "ghcr.io/outsourc-e/hermes-workspace:latest";
    ports = ["127.0.0.1:3002:3000"];
    volumes = ["/srv/hermes/workspace:/home/workspace"];
    environmentFiles = ["/srv/hermes/workspace.env"];
    environment = {
      HERMES_API_URL = "http://hermes:8642";
      HERMES_DASHBOARD_URL = "http://hermes:9119";
      HERMES_API_TOKEN = "b8197597fce4b84c3fa14a1462d51f1790d6e0a51cc114108d332fecffc1cc1a";
      COOKIE_SECURE = "0";
      TRUST_PROXY = "1";
    };
    extraOptions = [
      "--pull=always"
      "--network=hermes-net"
    ];
    dependsOn = ["hermes"];
  };
}
