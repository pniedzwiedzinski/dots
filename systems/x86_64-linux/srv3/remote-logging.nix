{ config, lib, pkgs, ... }:

{
  # Forward journal logs to remote server for post-mortem debugging
  services.journald.upload = {
    enable = true;
    settings = {
      Upload = {
        URL = "http://backup:19532";
      };
    };
  };
}
