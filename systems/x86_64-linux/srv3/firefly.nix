{
  lib,
  pkgs,
  ...
}: {
  virtualisation.oci-containers = {
    backend = "docker";

    containers."firefly-db" = {
      autoStart = true;
      image = "postgres:16-alpine";
      volumes = ["/srv/firefly/db:/var/lib/postgresql/data"];
      environment = {
        POSTGRES_USER = "firefly";
        POSTGRES_DB = "firefly";
        POSTGRES_PASSWORD = "efd4ea7ac0b68245572d2cfdfe1dc6b92acfe34c616169e2"; # Consider moving to agenix/environmentFiles later
      };
      extraOptions = [
        "--pull=always"
        "--network=firefly-net"
        "--network-alias=firefly-db"
      ];
    };

    containers.firefly = {
      autoStart = true;
      image = "fireflyiii/core:latest";
      ports = ["127.0.0.1:3007:8080"];
      volumes = ["/srv/firefly/upload:/var/www/html/storage/upload"];
      environment = {
        DB_CONNECTION = "pgsql";
        DB_HOST = "firefly-db";
        DB_PORT = "5432";
        DB_DATABASE = "firefly";
        DB_USERNAME = "firefly";
        DB_PASSWORD = "efd4ea7ac0b68245572d2cfdfe1dc6b92acfe34c616169e2"; # Should match POSTGRES_PASSWORD
        APP_KEY = "base64:ugLQrF38Rf8U4OmFXlodYw1eM2IkfllZ2wR8qGNZOmA=";
        TRUSTED_PROXIES = "**";
        SITE_OWNER = "patryk@niedzwiedzinski.cyou";
        TZ = "Europe/Warsaw";
      };
      extraOptions = [
        "--pull=always"
        "--network=firefly-net"
        "--network-alias=firefly"
      ];
      dependsOn = ["firefly-db"];
    };

    containers."firefly-importer" = {
      autoStart = true;
      image = "fireflyiii/data-importer:latest";
      ports = ["127.0.0.1:3008:8080"];
      environment = {
        FIREFLY_III_URL = "http://firefly:8080";
        FIREFLY_III_ACCESS_TOKEN = "<PLACEHOLDER>";
        VANITY_URL = "https://firefly.srv3.niedzwiedzinski.cyou";
        TRUSTED_PROXIES = "**";
        TZ = "Europe/Warsaw";
      };
      extraOptions = [
        "--pull=always"
        "--network=firefly-net"
        "--network-alias=importer"
      ];
      dependsOn = ["firefly"];
    };
  };

  # Docker network for Firefly III containers
  systemd.services."docker-network-firefly-net" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.docker}/bin/docker network rm -f firefly-net";
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect firefly-net || ${pkgs.docker}/bin/docker network create firefly-net
    '';
    partOf = ["docker-firefly-db.service" "docker-firefly.service" "docker-firefly-importer.service"];
    wantedBy = ["docker-firefly-db.service" "docker-firefly.service" "docker-firefly-importer.service"];
    before = ["docker-firefly-db.service" "docker-firefly.service" "docker-firefly-importer.service"];
  };
}
