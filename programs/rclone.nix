{ pkgs, config, ... }:

let
    mountdir = "${config.home.homeDirectory}/zhr/drive";
in
{
  home.packages = with pkgs; [
    rclone
  ];

    systemd.user = {
        services.gdrive_mount = {
            Unit = {
                Description = "mount google-drive dirs";
            };
            Install.WantedBy = [ "multi-user.target" ];
            Service = {
                # ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountdir}";
                ExecStart = ''
                    ${pkgs.rclone}/bin/rclone mount zhr-drive: ${mountdir}
                '';
                # ExecStop = "${pkgs.coreutils}/bin/umount ${mountdir}";
                Type = "notify";
                Restart = "always";
                RestartSec = "10s";
                Environment = [ "PATH=${pkgs.fuse}/bin:$PATH" ];
            };
        };
    };
}
