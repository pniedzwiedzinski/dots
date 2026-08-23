{
  config,
  lib,
  ...
}:
let
  cfg = config.dots.docker;
in
{
  options.dots.docker = {
    enable = lib.mkEnableOption "Docker daemon";
    storageDriver = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Docker storage driver. Null for auto-detection.";
    };
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Users to add to the docker group.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.docker.storageDriver = lib.mkIf (cfg.storageDriver != null) cfg.storageDriver;
    users.extraGroups.docker.members = cfg.users;
  };
}
