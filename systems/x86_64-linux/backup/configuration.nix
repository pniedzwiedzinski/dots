{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./disko-config.nix
  ];

  srv.enable = true;
  srv.machineId = "backup";

  # Ensure Tailscale is enabled (also enabled by srv module)
  services.tailscale.enable = true;

  networking.hostId = "8425e349";

  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  boot.supportedFilesystems = ["zfs"];

  users.users.borg = {
    isNormalUser = true;
    description = "Borg Backup User";
    home = "/home/borg";
    packages = [pkgs.borgbackup];
    openssh.authorizedKeys.keys = [
      "restrict,command=\"borg serve --restrict-to-path /data\" ssh-ed25519 AAAA..."
    ];
  };

  systemd.tmpfiles.rules = [
    "d /data 0700 borg users - -"
  ];
}
