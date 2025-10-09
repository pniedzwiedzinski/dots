{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.onedrive-backup;
  fullBackup = pkgs.writeShellScript "full_backup.sh" ''
    #!/bin/sh
    #set -eou pipefail
    export "PATH=${pkgs.gzip}/bin:${pkgs.gnutar}/bin:${pkgs.openssl}/bin:$PATH"

    CONF_DIR="/persist/onedrive"
    BACKUP_DIR="/persist/backup"

    TARGET="backup_$(date +%Y-%m-%d_%H-%M-%S)"
    mkdir -p "$BACKUP_DIR/$TARGET"
    tar -cvpPzf "$BACKUP_DIR/$TARGET/$TARGET.tar.gz" /persist/srv
    ${pkgs.onedrive}/bin/onedrive -v --confdir "$CONF_DIR" --sync --upload-only --syncdir="$BACKUP_DIR" || true
    rm -r "$BACKUP_DIR/$TARGET"
  '';
in {
  options.services.onedrive-backup = {
    enable = lib.mkEnableOption "Onedrive Backup service";
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      services.onedrive-backup = {
        description = "Weekly Backup Service";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = fullBackup;
          User = "root";
          RemainAfterExit = false;
          SuccessExitStatus = 0;
        };
      };
      timers.onedrive-backup = {
        description = "Weekly Backup Timer";
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = "Sun *-*-* 03:00:00";
          Persistent = true;
        };
      };
    };

    environment.systemPackages = with pkgs; [onedrive];

    users.groups.onedrive = {};
    users.users.onedrive = {
      isSystemUser = true;
      group = "onedrive";
    };
  };
}
