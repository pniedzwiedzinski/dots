{ pkgs, ... }:
{
  systemd = {
    services.noip = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      aliases = [ "noip2.service" ];
      after = [ "network.target" "syslog.target" ];
      serviceConfig = {
        User = "root";
        ExecStart = "${pkgs.noip}/bin/noip2 -c /etc/noip2.conf";
        Restart = "always";
        Type = "forking";
      };
    };
  };
}
