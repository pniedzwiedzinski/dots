{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.srv;
in
{
  options.srv = {
    enable = lib.mkEnableOption "The homelab services and configuration variables";
    timeZone = lib.mkOption {
      default = "Europe/Warsaw";
      type = lib.types.str;
      description = ''
        Time zone to be used for the homelab services
      '';
    };
    autoUpgrade = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = ''
        Automatically upgrade the homelab services
      '';
    };
    machineId = lib.mkOption {
      default = "";
      type = lib.types.str;
      description = "Machine identifier";
    };
  };
  imports = [
    ./services
  ];
  config = lib.mkIf cfg.enable {
    systemd.services = {
      upgrade = {
        enable = cfg.autoUpgrade;
        description = "Upgrade homelab services";
        wantedBy = [ "timers.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.nixFlakes}/bin/nixos-rebuild --experimental-features 'nix-command flakes' switch --flake github:pniedzwiedzinski:dots#${cfg.machineId}";
          User = "root";
          Group = "root";
          Restart = "on-failure";
        };
        after = [ "network.target" ];
      };
    };
    systemd.timers = {
      upgrade = {
        description = "Run upgrade service weekly";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
        };
      };
    };

    users.users.pn = {
      isNormalUser = true;
      home = "/home/pn";
      description = "Patryk";
      extraGroups = [ "wheel" ];

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqlCe4ovKa/Gwl5xmgu9nvVPmFXMgwdeLRYW7Gg7RWx pniedzwiedzinski19@gmail.com"
      ];
    };
  };
}
