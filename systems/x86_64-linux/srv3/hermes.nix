{
  lib,
  pkgs,
  ...
}: {
  # Hermes Agent — AI coding assistant (Nous Research)
  virtualisation.oci-containers = {
    backend = "docker";
    containers.hermes = {
      autoStart = true;
      image = "nousresearch/hermes-agent:latest";
      cmd = ["gateway" "run"];
      ports = [
        "127.0.0.1:8642:8642"
        "127.0.0.1:9119:9119"
      ];
      volumes = ["/srv/hermes/data:/opt/data"];
      environment = {
        HERMES_HOME = "/opt/data";
        HERMES_DASHBOARD = "1";
        API_SERVER_ENABLED = "true";
        API_SERVER_HOST = "0.0.0.0";
        API_SERVER_KEY = "b8197597fce4b84c3fa14a1462d51f1790d6e0a51cc114108d332fecffc1cc1a";
      };
      extraOptions = [
        "--pull=always"
        "--network=hermes-net"
        "--network-alias=hermes"
      ];
    };
  };

  # Hermes Workspace — web UI for Hermes Agent
  virtualisation.oci-containers.containers."hermes-workspace" = {
    autoStart = true;
    image = "ghcr.io/outsourc-e/hermes-workspace:latest";
    ports = ["127.0.0.1:3002:3000"];
    volumes = [
      "/srv/hermes/workspace:/workspace"
      "/srv/hermes/data:/home/workspace/.hermes"
    ];
    environmentFiles = ["/srv/hermes/workspace.env"];
    environment = {
      HERMES_HOME = "/home/workspace/.hermes";
      HERMES_WORKSPACE_DIR = "/workspace";
      HERMES_API_URL = "http://hermes:8642";
      HERMES_DASHBOARD_URL = "http://hermes:9119";
      HERMES_API_TOKEN = "b8197597fce4b84c3fa14a1462d51f1790d6e0a51cc114108d332fecffc1cc1a";
      COOKIE_SECURE = "0";
      TRUST_PROXY = "1";
    };
    extraOptions = [
      "--pull=always"
      "--network=hermes-net"
      "--user=10000:10000" # share folder
    ];
    dependsOn = ["hermes"];
  };

  # Docker network for Hermes containers
  systemd.services."docker-network-hermes-net" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.docker}/bin/docker network rm -f hermes-net";
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect hermes-net || ${pkgs.docker}/bin/docker network create hermes-net
    '';
    partOf = ["docker-hermes.service"];
    wantedBy = ["docker-hermes.service"];
    before = ["docker-hermes.service"];
  };
}
