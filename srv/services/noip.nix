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
    agePasswdFile = lib.mkOption {
      type = lib.types.path;
    };
    ageLoginFile = lib.mkOption {
      type = lib.types.path;
    };
    interface = lib.mkOption {
      type = lib.types.str;
      default = "enp1s0";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets = {
      noip-passwd = {
        file = cfg.agePasswdFile;
        mode = "400";
        owner = "noip";
        group = "noip";
      };
      noip-login = {
        file = cfg.ageLoginFile;
        mode = "400";
        owner = "noip";
        group = "noip";
      };
    };

    systemd = let
      serviceScript = pkgs.writeShellScript "noip-setup.sh" ''
        passwd=$(cat ${config.age.secrets.noip-passwd.path})
        login=$(cat ${config.age.secrets.noip-login.path})
        temp=$(mktemp noip.XXX.conf)
        noip2 -I ${cfg.interface} -U 5 -C -c "$temp" -u "$login" -p "$passwd"
        noip2 -c "$temp"
      '';
    in {
      services.noip = {
        enable = true;
        wantedBy = ["multi-user.target"];
        aliases = ["noip2.service"];
        after = ["network.target" "syslog.target" "default.target"];
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
