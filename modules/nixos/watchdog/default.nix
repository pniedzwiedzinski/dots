{
  config,
  lib,
  ...
}:
let
  cfg = config.dots.watchdog;
in
{
  options.dots.watchdog = {
    enable = lib.mkEnableOption "Hardware watchdog and kernel panic reboot";
    runtimeTime = lib.mkOption {
      type = lib.types.str;
      default = "60s";
      description = "Systemd hardware watchdog runtime timeout.";
    };
    rebootTime = lib.mkOption {
      type = lib.types.str;
      default = "10m";
      description = "Systemd hardware watchdog reboot timeout.";
    };
    kernelPanic = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "Seconds to wait before auto-reboot on kernel panic.";
    };
    nmiWatchdog = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable NMI watchdog.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.settings.Manager = {
      RuntimeWatchdogSec = cfg.runtimeTime;
      RebootWatchdogSec = cfg.rebootTime;
    };

    boot.kernelParams = [
      "panic=${toString cfg.kernelPanic}"
    ]
    ++ lib.optionals cfg.nmiWatchdog [ "nmi_watchdog=1" ];
  };
}
