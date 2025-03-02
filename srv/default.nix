{
  lib,
  config,
  ...
}: let
  cfg = config.srv;
in {
  options.srv = {
    enable = lib.mkEnableOption "The homelab services and configuration variables";
    timeZone = lib.mkOption {
      default = "Europe/Warsaw";
      type = lib.types.str;
      description = ''
        Time zone to be used for the homelab services
      '';
    };
    machineId = lib.mkOption {
      default = "";
      type = lib.types.str;
      description = "Machine identifier";
    };
  };
  imports = [
    ./services
  ];
  config = lib.mkIf cfg.enable {
    system.autoUpgrade = {
      dates = "*-*-* 07:00:00";
      randomizedDelaySec = "1h";
      flake = "github:pniedzwiedzinski/dots";
    };

    networking.hostName = cfg.machineId;
    time.timeZone = cfg.timeZone;

    # services.openssh = {
    #   enable = true;
    #   ports = [ 22 ];
    #   settings = {
    #     PasswordAuthentication = false;
    #     PermitRootLogin = "no";
    #   };
    # };
    # networking.firewall.allowedTCPPorts = [ 22 ];

    services.tailscale.enable = true;

    security.sudo.wheelNeedsPassword = false;
    nix.settings.trusted-users = ["@wheel"];
    nix.settings.experimental-features = [
      "flakes"
      "nix-command"
    ];

    users.users.pn = {
      isNormalUser = true;
      home = "/home/pn";
      description = "Patryk";
      extraGroups = ["wheel"];

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqlCe4ovKa/Gwl5xmgu9nvVPmFXMgwdeLRYW7Gg7RWx pniedzwiedzinski19@gmail.com"
      ];
    };
  };
}
