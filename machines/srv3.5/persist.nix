{
  lib,
  pkgs,
  ...
}: {
  fileSystems."/persist".neededForBoot = true;
  users.mutableUsers = false;
  systemd.tmpfiles.rules = ["d /var/lib/systemd/pstore 0755 root root 14d"];

  environment.persistence = {
    "/persist" = {
      hideMounts = true;
      directories = [
        {
          directory = "/var/lib/nixos";
          user = "root";
          group = "root";
          mode = "0755";
        }
        {
          directory = "/var/lib/tailscale";
          user = "root";
          group = "root";
          mode = "0700";
        }
        {
          directory = "/var/log";
          user = "root";
          group = "root";
          mode = "0755";
        }
        {
          directory = "/var/lib/systemd";
          user = "root";
          group = "root";
          mode = "0755";
        }
        {
          directory = "/var/lib/NetworkManager";
          user = "root";
          group = "root";
          mode = "0755";
        }

        {
          directory = "/var/spool";
          user = "root";
          group = "root";
          mode = "0777";
        }
        {
          directory = "/var/lib/acme";
          user = "acme";
          group = "acme";
          mode = "0755";
        }
        "/etc/NetworkManager"
        "/srv"
      ];
      files = [
        "/etc/adjtime"
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
    };
  };

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /mnt
    mount -o subvol=/ /dev/sda3 /mnt

    echo "Archive old root"
    if [[ -e /mnt/root ]]; then
      mkdir -p /mnt/old_roots
      timestamp=$(date --date="@$(stat -c %Y /mnt/root)" "+%Y-%m-%-d_%H:%M:%S")
      mv /mnt/root "/mnt/old_roots/$timestamp"
    fi

    echo "Restoring blank /root subvolume"
    btrfs subvolume snapshot /mnt/root-blank /mnt/root

    echo "Deleting old roots"
    for i in $(find /mnt/old_roots/ -maxdepth 1 -mtime +30); do
      btrfs subvolume list -o "$i" | cut -f9 -d' ' |
      while read subvolume; do
        echo "Deleting /$subvolume subvolume"
        btrfs subvolume delete "/mnt/$subvolume"
      done &&
      echo "Deleting /root subvolume" &&
      btrfs subvolume delete "$i"
    done

    umount /mnt
  '';
}
