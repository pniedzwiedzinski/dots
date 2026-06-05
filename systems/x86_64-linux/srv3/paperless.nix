{
  config,
  lib,
  ...
}: {
  systemd.services."docker-network-paperless-net" = {
    path = [config.virtualisation.docker.package];
    description = "Create docker network paperless-net";
    after = ["network.target" "docker.service"];
    wantedBy = ["multi-user.target"];
    script = ''
      ${config.virtualisation.docker.package}/bin/docker network inspect paperless-net >/dev/null 2>&1 || ${config.virtualisation.docker.package}/bin/docker network create paperless-net
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${config.virtualisation.docker.package}/bin/docker network rm paperless-net";
    };
  };

  virtualisation.oci-containers.containers = {
    "paperless-broker" = {
      image = "docker.io/library/redis:7";
      autoStart = true;
      extraOptions = ["--network=paperless-net"];
      volumes = [
        "/srv/paperless/redisdata:/data"
      ];
      dependsOn = [];
    };

    "paperless-webserver" = {
      image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
      autoStart = true;
      dependsOn = ["paperless-broker"];
      extraOptions = ["--network=paperless-net"];
      ports = [
        "127.0.0.1:8000:8000"
      ];
      volumes = [
        "/srv/paperless/data:/usr/src/paperless/data"
        "/srv/paperless/media:/usr/src/paperless/media"
        "/srv/paperless/export:/usr/src/paperless/export"
        "/srv/paperless/consume:/usr/src/paperless/consume"
      ];
      environmentFiles = [
        "/srv/compose/paperless/docker-compose.env"
      ];
      environment = {
        PAPERLESS_REDIS = "redis://paperless-broker:6379";
        USERMAP_UID = "1001";
        USERMAP_GID = "1001";
      };
    };
  };

  systemd.services."docker-paperless-broker" = {
    partOf = ["docker-network-paperless-net.service"];
    wantedBy = ["docker-network-paperless-net.service"];
    after = ["docker-network-paperless-net.service"];
    requires = ["docker-network-paperless-net.service"];
  };

  systemd.services."docker-paperless-webserver" = {
    partOf = ["docker-network-paperless-net.service"];
    wantedBy = ["docker-network-paperless-net.service"];
    after = ["docker-network-paperless-net.service"];
    requires = ["docker-network-paperless-net.service"];
  };

  users.groups.scanner = {
    gid = 1001;
  };

  users.users.scanner = {
    isNormalUser = true;
    uid = 1001;
    group = "scanner";
    description = "User for network scanner FTP upload";
    home = "/srv/paperless/consume";
    # Please generate the password hash using `mkpasswd -m sha-512`
    # and put it inside this file, or replace this with an agenix secret.
    hashedPasswordFile = "/persist/scanner-password.hash";
  };

  services.vsftpd = {
    enable = true;
    writeEnable = true;
    localUsers = true;
    userlistEnable = true;
    userlist = [ "scanner" ];
    extraConfig = ''
      userlist_deny=NO
      pasv_enable=YES
      pasv_min_port=50000
      pasv_max_port=50100
      chroot_local_user=YES
      allow_writeable_chroot=YES
      dirlist_enable=YES
      download_enable=YES
    '';
  };
}
