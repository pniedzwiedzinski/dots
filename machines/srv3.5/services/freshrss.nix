{
  config,
  lib,
  ...
}: let
  cfg = config.srv.services.freshrss;
in {
  options.srv.services.immich = {
    enable = lib.mkEnableOption "Self-hosted photo and video management solution";
  };
  config = lib.mkIf cfg.enable {
    services.freshrss = {
      enable = true;
      virtualHost = "fresh.niedzwiedzinski.cyou";
      baseUrl = "https://fresh.niedzwiedzinski.cyou";
      authType = "form";
      defaultUser = "admin";
      passwordFile = cfg.age.secrets.freshrssPasswordFile.path;
    };
  };
}
