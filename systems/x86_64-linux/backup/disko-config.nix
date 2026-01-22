{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/ata-SSDPR-CX400-01T-G2_4S0288440";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              priority = 1;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        options = {
          ashift = "12";
        };

        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";

          acltype = "posixacl";

          xattr = "sa";
          dnodesize = "auto";
          atime = "off";
        };
        datasets = {
          system = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };
          data = {
            type = "zfs_fs";
            mountpoint = "/data";
            options = {
              mountpoint = "legacy";
              recordsize = "1M";
            };
          };
        };
      };
    };
  };
}
