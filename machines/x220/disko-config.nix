# USAGE in your configuration.nix.
# Update devices to match your hardware.
# {
#  imports = [ ./disko-config.nix ];
#  disko.devices.disk.main.device = "/dev/sda";
#  disko.devices.disk.main.content.partitions.swap.size = "16G"; # Must be greater than RAM to enable hibernation
# }
{ lib, config, ... }:
{

  boot.initrd.postDeviceCommands = ''
    mkdir /btrfs_tmp
    mount -t btrfs -o subvol=root,defaults ${config.disko.devices.disk.main.device} /btrfs_tmp
    if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';

  disko.devices = {
    disk = {
      main = {
	device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
	    swap = {
	      size = "13G";
	      content = {
		type = "swap";
		discardPolicy = "both";
                resumeDevice = true;
	      };
	    };
            data = {
              size = "100%";
              content = {
                type = "btrfs";
		extraArgs = [ "-f" ];
		mountpoint = "/partition-root";
		subvolumes = {
                  "/nix" = {
                    mountOptions = [ "compress=zstd" "noatime" ];
                    mountpoint = "/nix";
                  };
		  "/persist" = {
		    mountpoint = "/persist";
		  };
		  "/root" = {
		    mountpoint = "/";
		  };
		};
              };
            };
          };
        };
      };
    };
  };
}
