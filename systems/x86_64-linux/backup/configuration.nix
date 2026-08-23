{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ./disko-config.nix ];

  srv.enable = true;
  srv.machineId = "backup";

  dots = {
    nixGc.enable = true;
    remoteLogging = {
      enable = true;
      mode = "server";
    };
  };

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostId = "5819a9e0";

  boot.supportedFilesystems = [ "zfs" ];

  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };

  environment.systemPackages = with pkgs; [ borgbackup ];

  services.borgbackup.repos = {
    "srv3" = {
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINd/ymGIlBST6Mhqlwwf+X4+KTsmNz6mvE+LE9kYIcBl borg srv3"
      ];
      path = "/data/borg/srv3";
    };
  };

  systemd.tmpfiles.rules = [ "d /data 0700 borg users - -" ];

  system.stateVersion = "25.11";
}
