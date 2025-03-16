{pkgs, ...}: {
  imports = [
    ./disko-config.nix
    ./nvidia_gpu.nix
    ./ollama.nix
    ../doas.nix

    ./auto-shutdown.nix
  ];

  srv = {
    enable = true;
    machineId = "srv5";
  };

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

  programs.nix-ld.enable = true;

  nixpkgs.config.nvidia.acceptLicense = true;
  nixpkgs.config.allowUnfree = true;
  nix.settings.trusted-users = ["root" "@wheel"];
  nix.settings.experimental-features = ["flakes" "nix-command"];

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
    nameservers = ["1.1.1.1" "8.8.8.8"];
  };

  environment.systemPackages = with pkgs; [
    lm_sensors
    python3
  ];
}
