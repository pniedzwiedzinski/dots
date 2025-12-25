{
  lib,
  config,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    ./sd-image.nix
    ./4g.nix
  ];

  # Some packages (ahci fail... this bypasses that) https://discourse.nixos.org/t/does-pkgs-linuxpackages-rpi3-build-all-required-kernel-modules/42509
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
  # ! Need a trusted user for deploy-rs.
  nix.settings.trusted-users = ["@wheel"];
  system.stateVersion = "24.05";

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  sdImage = {
    # bzip2 compression takes loads of time with emulation, skip it. Enable this if you're low on space.
    compressImage = false;
    imageName = "zero2.img";

    extraFirmwareConfig = {
      # Give up VRAM for more Free System Memory
      # - Disable camera which automatically reserves 128MB VRAM
      start_x = 0;
      # - Reduce allocation of VRAM to 16MB minimum for non-rotated (32MB for rotated)
      gpu_mem = 16;

      # Configure display to 800x600 so it fits on most screens
      # * See: https://elinux.org/RPi_Configuration
      hdmi_group = 2;
      hdmi_mode = 8;
    };
  };

  hardware = {
    enableRedistributableFirmware = lib.mkForce false;
    firmware = [pkgs.raspberrypiWirelessFirmware]; # Keep this to make sure wifi works
    i2c.enable = true;
    deviceTree.filter = "bcm2837-rpi-zero*.dtb";
    deviceTree.overlays = [
      {
        name = "enable-i2c";
        dtsText = ''
          /dts-v1/;
          /plugin/;
          / {
            compatible = "brcm,bcm2837";
            fragment@0 {
              target = <&i2c1>;
              __overlay__ {
                status = "okay";
              };
            };
          };
        '';
      }
    ];
  };

  time.timeZone = "Europe/Warsaw";

  fileSystems."/srv/www" = {
    device = "/dev/disk/by-uuid/13add853-585e-4a38-95fe-cd7ff1569535";
    options = [ "nofail" "nosuid" "nodev" ];
  };

  networking.extraHosts = ''
    127.0.0.1 solar.niedzwiedzinski.local
  '';

  services.nginx.enable = true;
  services.nginx.virtualHosts."_" = {
    root = "/srv/www/";
  };
  networking.firewall.allowedTCPPorts = [ 80 ];

  age.secrets.cloudflared.file = ./secrets/cloudflared.cert.pem.age;
  age.secrets.tunnel = {
    file = ./secrets/tunnel.age;
    owner = "cloudflared";
    group = "cloudflared";
    mode = "0640";
  };
          
  environment.systemPackages = with pkgs; [
    libraspberrypi
    cloudflared
    minicom
    ppp
  ];

  systemd.services.cloudflared = {
    description = "Cloudflare Tunnel Service";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --config ${./tunnel-config.yml} run --credentials-file ${config.age.secrets.tunnel.path}";
      User = "cloudflared";
      Group = "cloudflared";
      Restart = "on-failure";
    };

    after = [ "network.target" ];
  };
  
  users.users.cloudflared = {
    isSystemUser = true;    # Marks this as a system user
    home = "/var/lib/cloudflared";  # Set the home directory
    shell = "${pkgs.shadow}/bin/nologin";   # Disable shell access
    description = "Cloudflare Tunnel Service User";
    group = "cloudflared";  # Primary group
  };

  users.groups.cloudflared = {};  # Create the group if it doesn't already exist


  boot = {
    kernelPackages = pkgs.linuxPackages_rpi02w;

    initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    # Avoids warning: mdadm: Neither MAILADDR nor PROGRAM has been set. This will cause the `mdmon` service to crash.
    # See: https://github.com/NixOS/nixpkgs/issues/254807
    swraid.enable = lib.mkForce false;
  };

  networking = {
    interfaces."wlan0".useDHCP = true;
    wireless = {
      enable = true;
      interfaces = ["wlan0"];
      # ! Change the following to connect to your own network
      networks = {
        "<ssid>" = {
          psk = "<ssid-key>";
        };
      };
    };
  };

  # Enable OpenSSH out of the box.
  services.sshd.enable = true;

  # NTP time sync.
  services.timesyncd.enable = true;

  # ! Change the following configuration
  users.users.pn = {
    isNormalUser = true;
    home = "/home/pn";
    description = "Patryk";
    extraGroups = ["wheel" "networkmanager"];
    # ! Be sure to put your own public key here
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqlCe4ovKa/Gwl5xmgu9nvVPmFXMgwdeLRYW7Gg7RWx pniedzwiedzinski19@gmail.com"];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # ! Be sure to change the autologinUser.
  # services.getty.autologinUser = "bob";
}
