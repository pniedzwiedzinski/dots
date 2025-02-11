{pkgs, ...}: {
  imports = [
    ./disko-config.nix

    ./hardware-configuration.nix
    ./network.nix
    ./persist.nix

    #./modules/immich.nix
    #./services/freshrss.nix

    ./services/ssh.nix
    #./services/oci.nix
    #./services/nginx.nix
    #./services/home-assistant.nix
    #./services/cgit
    #./services/yggdrasil
    #./services/noip.nix

    #./services/changedetection.nix
  ];

  disko.devices.disk.main.device = "/dev/sda";

  #srv.domain = "srv3";

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8"; # Less confusing locale than polish one
  console.keyMap = "pl";

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;
  system.autoUpgrade = {
    enable = true;
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
