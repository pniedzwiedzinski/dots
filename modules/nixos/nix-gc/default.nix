{
  config,
  lib,
  ...
}:
let
  cfg = config.dots.nixGc;
in
{
  options.dots.nixGc = {
    enable = lib.mkEnableOption "Automatic Nix garbage collection and store optimisation";
    olderThan = lib.mkOption {
      type = lib.types.str;
      default = "30d";
      description = "Delete generations older than this duration.";
    };
  };

  config = lib.mkIf cfg.enable {
    nix = {
      gc = {
        automatic = true;
        options = "--delete-older-than ${cfg.olderThan}";
      };
      optimise.automatic = true;
    };
  };
}
