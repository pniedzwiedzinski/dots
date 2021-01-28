{ pkgs, ... }:
let
  hyperion = pkgs.callPackage ./hyperion-ng.nix { };
  hyperionConfig = pkgs.fetchurl {
    url = "https://gist.githubusercontent.com/pniedzwiedzinski/e1810bc4dd08b97512d28c42daa95326/raw/460febec24390dc90d3b70987f07ef1ab8a77b3a/hyperion.config.json";
    sha256 = "1yaiw8ljy6kaq6vnf5ccq2c4wpjlakd00nmq51v1q2sdnc06jmqq";
  };
in
{
  imports = [
    ./spi.nix
  ];

  environment.systemPackages = [
    hyperion
  ];


  # networking.firewall.allowedTCPPorts = [  ];
  networking.firewall.enable = false; #TODO

  systemd.services.hyperion = {
    enable = true;
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${hyperion}/bin/hyperiond";
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      Restart = "on-failure";
      User = "root";
      Group = "root";
      Type = "simple";
      UMask = "007";
      TimeoutStopSec = "10";
    };
  };
}
