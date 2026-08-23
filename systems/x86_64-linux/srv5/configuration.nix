{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./disko-config.nix
    ../doas.nix
    ./docker-compose.nix
  ];

  srv = {
    enable = true;
    machineId = "srv5";
  };

  dots = {
    docker.enable = true;
    nvidia.enable = true;
    ollamaProxy.enable = true;
    autoShutdown.enable = true;
  };

  disko.devices.disk.main.device = "/dev/sda";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "pn" ];
    };
  };

  programs.nix-ld.enable = true;

  nixpkgs.config.nvidia.acceptLicense = true;
  nixpkgs.config.allowUnfree = true;
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];
  nix.settings.experimental-features = [
    "flakes"
    "nix-command"
  ];

  networking = {
    hostName = "srv5";
    interfaces = {
      enp4s0.ipv4.addresses = [
        {
          address = "192.168.1.244";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = "192.168.1.1";
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  environment.systemPackages = with pkgs; [
    lm_sensors
    python3
  ];
}
