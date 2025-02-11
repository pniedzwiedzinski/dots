{
  config,
  lib,
  ...
}: let
  inherit (config) srv;
  cfg = srv.hardening;
in {
  options.srv.hardening = {
    enable = lib.mkEnableOption {
      description = "Enable Wireguard client network namespace";
    };
  };
  config = lib.mkIf cfg.enable {
    nix.allowedUsers = ["@wheel"];
    security = {
      auditd.enable = true;
      audit.enable = true;
      audit.rules = [
        "-a exit,always -F arch=b64 -S execve"
      ];
    };
  };
}
