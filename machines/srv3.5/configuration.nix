{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./disko-config.nix

    ./hardware-configuration.nix
    ./network.nix
    ./persist.nix

    #./services/immich.nix
    #./services/freshrss.nix
    ./services/changedetection.nix
    #./services/home-assistant.nix

    ./services/ssh.nix
    ./services/oci.nix
    #./services/nginx.nix
    #./services/cgit
    #./services/yggdrasil
    ./services/noip.nix
  ];

  disko.devices.disk.main.device = "/dev/sda";

  srv.services = {
    changedetection.enable = true;
    #   freshrss.enable = false; #TODO password
    #   immich.enable = true;
    #   home-assistant.enable = true;
    noip = {
      enable = true;
      passwdFile = config.age.secrets.noip-passwd.path;
      loginFile = config.age.secrets.noip-login.path;
    };
  };

  age.secrets = {
    noip-passwd = {
      file = ./secrets/noip-passwd.age;
      mode = "400";
      owner = "noip";
      group = "noip";
    };
    noip-login = {
      file = ./secrets/noip-login.age;
      mode = "400";
      owner = "noip";
      group = "noip";
    };
  };

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
