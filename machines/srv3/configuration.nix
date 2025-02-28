{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./disko-config.nix

    ./hardware-configuration.nix
    ./network.nix
    ./persist.nix

    ./services/ssh.nix
    ./services/docker.nix
    ./services/noip.nix
    # ./services/caddy.nix

    ./services/onedrive.nix
  ];

  disko.devices.disk.main.device = "/dev/sda";

  srv.services = {
    noip = {
      enable = true;
      agePasswdFile = ./secrets/noip-passwd.age;
      ageLoginFile = ./secrets/noip-login.age;
    };
  };

  services.onedrive-backup.enable = false;

  networking.firewall.allowedTCPPorts = [2283 8123 8000 5000 8080];

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8"; # Less confusing locale than polish one
  console.keyMap = "pl";

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
  };
  system.autoUpgrade = {
    enable = true;
    # flake = inputs.self.outPath; <- set in flake.nix
    flags = [
      "--update-input"
      "nixpkgs"
      "--commit-lock-file"
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
    allowReboot = true;
  };

  environment.systemPackages = with pkgs; [
    ripgrep
    curl
    wget
    htop
    git
    vim
    lm_sensors
  ];

  services.tailscale.enable = true;

  security.sudo.wheelNeedsPassword = false;
  nix.settings.trusted-users = ["@wheel"];
  nix.settings.experimental-features = ["flakes" "nix-command"];

  users = {
    users = {
      pn = {
        description = "patryk";
        isNormalUser = true;
        extraGroups = ["wheel" "git" "docker"];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqlCe4ovKa/Gwl5xmgu9nvVPmFXMgwdeLRYW7Gg7RWx pniedzwiedzinski19@gmail.com"
        ];
      };
    };
  };
}
