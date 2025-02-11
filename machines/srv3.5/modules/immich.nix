{
  config,
  lib,
  ...
}: let
  cfg = config.srv.services.immich;
in {
  options.srv.services.immich = {
    enable = lib.mkEnableOption "Self-hosted photo and video management solution";
    user = lib.mkOption {
      default = "immich";
      type = lib.types.str;
      description = ''
        User to run the Immich container as
      '';
    };
    group = lib.mkOption {
      default = config.homelab.group;
      type = lib.types.str;
      description = ''
        Group to run the Immich container as
      '';
    };
    mediaDir = lib.mkOption {
      type = lib.types.path;
      default = "/srv/immich";
    };
    url = lib.mkOption {
      type = lib.types.str;
      default = "photos.local";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = ["d ${cfg.mediaDir} 0775 immich immich - -"];
    users.users.immich.extraGroups = [
      "video"
      "render"
    ];
    services.immich = {
      group = "immich";
      enable = true;
      port = 2283;
      mediaLocation = "${cfg.mediaDir}";
    };
  };
}
