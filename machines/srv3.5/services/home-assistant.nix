{
  config,
  lib,
  ...
}: let
  cfg = config.srv.services.home-assistant;
in {
  options.srv.services.home-assistant = {
    enable = lib.mkEnableOption "Web change detection watchdog with UI and notifications";
  };
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.homeassistant = {
      # user = "homeassistant";
      volumes = [
        "/srv/home-assistant:/config"
        "/etc/localtime:/etc/localtime:ro"
        "/run/dbus:/run/dbus:ro"
      ];
      environment.TZ = "Europe/Warsaw";
      image = "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
      extraOptions = [
        "--network=host"
      ];
    };
    networking.firewall.allowedTCPPorts = [8123];

    users.users.homeassistant = {
      isSystemUser = true;
      group = "srvworker";
    };
  };
}
