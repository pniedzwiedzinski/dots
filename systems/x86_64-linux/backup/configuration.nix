{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./disko-config.nix
  ];

  srv.enable = true;
  srv.machineId = "backup";

  # Remote update
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
    interval = "weekly"; # Co tydzień sprawdzaj spójność dysków
  };

  users.users.borg = {
    isNormalUser = true;
    description = "Borg Backup User";
    home = "/data";
    packages = [ pkgs.borgbackup ];
    openssh.authorizedKeys.keys = [
      "restrict,command=\"borg serve --restrict-to-path /data\" ssh-ed25519 AAAA..."
    ];
  };

  systemd.tmpfiles.rules = [
    "d /data 0700 borg users - -"
  ];

  system.stateVersion = "25.11";
}
