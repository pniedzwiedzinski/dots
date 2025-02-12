{
  config,
  lib,
  ...
}: let
  cfg = config.srv.services.changedetection;
in {
  options.srv.services.changedetection = {
    enable = lib.mkEnableOption "Web change detection watchdog with UI and notifications";
  };
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.changedetection = {
      #      user = "changedetection";
      image = "ghcr.io/dgtlmoon/changedetection.io";
      ports = ["5000:5000"];
      volumes = ["/srv/changedetection:/datastore"];
    };

    users.users.changedetection = {
      isSystemUser = true;
      group = "srvworker";
    };
    users.groups.srvworker = {};
  };
}
