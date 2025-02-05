{pkgs, ...}: {
  imports = [
    ./disko-config.nix
    ../../modules/doas.nix
  ];

  disko.devices.disk.main.device = "/dev/sda";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = ["pn@192.168.1.*"];
    };
  };

  virtualisation.docker.enable = true;

  nix.settings.trusted-users = ["root" "@wheel"];
  nix.settings.experimental-features = ["flakes" "nix-command"];

  networking.firewall.allowedTCPPorts = [8888];

  environment.systemPackages = with pkgs; [lm_sensors];

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
