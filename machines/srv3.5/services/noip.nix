{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.srv.services.noip;
in {
  options.srv.services.noip = {
    enable = lib.mkEnableOption "Dynamic DNS update IP service";
    passwdFile = lib.mkOption {
      type = lib.types.path;
    };
    loginFile = lib.mkOption {
      type = lib.types.path;
    };
    interface = lib.mkOption {
      type = lib.types.str;
      default = "enp1s0";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = let
      serviceScript = pkgs.writeShellScript "noip-setup.sh" ''
        passwd=$(cat ${cfg.passwdFile})
        login=$(cat ${cfg.loginFile})
        temp=$(mktemp noip.XXX.conf)
        noip2 -I ${cfg.interface} -U 5 -C -c "$temp" -u "$login" -p "$passwd"
        noip2 -c "$temp"
      '';
    in {
      services.noip = {
        enable = true;
        wantedBy = ["multi-user.target"];
        aliases = ["noip2.service"];
        after = ["network.target" "syslog.target"];
        path = with pkgs; [noip coreutils];
        serviceConfig = {
          WorkingDirectory = "/tmp";
          User = "noip";
          ExecStart = "${serviceScript}";
          Restart = "always";
          Type = "forking";
        };
      };
    };

    users.users.noip = {
      isSystemUser = true;
      group = "noip";
    };
    users.groups.noip = {};
  };
}
