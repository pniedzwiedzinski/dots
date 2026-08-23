{
  config,
  lib,
  ...
}:
let
  cfg = config.dots.remoteLogging;
in
{
  options.dots.remoteLogging = {
    enable = lib.mkEnableOption "Remote journal logging";
    mode = lib.mkOption {
      type = lib.types.enum [
        "client"
        "server"
      ];
      default = "client";
      description = "Operate as a journal log client (upload) or server (receive).";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "http://backup:19532";
      description = "Remote journal URL. Only used in client mode.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf (cfg.mode == "client") {
        services.journald.upload = {
          enable = true;
          settings.Upload.URL = cfg.url;
        };
      })
      (lib.mkIf (cfg.mode == "server") {
        services.journald.remote = {
          enable = true;
          listen = "http";
        };

        networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 19532 ];
      })
    ]
  );
}
