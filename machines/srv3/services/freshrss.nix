{
  config,
  lib,
  ...
}: let
  cfg = config.srv.services.freshrss;
in {
  options.srv.services.freshrss = {
    enable = lib.mkEnableOption "Self-hosted rss manager";
    passwdFile = {
      type = lib.types.path;
    };
  };
  config = lib.mkIf cfg.enable {
    services.freshrss = {
      enable = true;
      virtualHost = "fresh.niedzwiedzinski.cyou";
      baseUrl = "https://fresh.niedzwiedzinski.cyou";
      authType = "form";
      defaultUser = "pn";
      passwordFile = cfg.passwdFile;
    };
  };
}
