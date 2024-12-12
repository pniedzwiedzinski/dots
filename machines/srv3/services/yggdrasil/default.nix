{ ... }:
let
  port = 1670;
in
{

  services.yggdrasil = {
    enable = true;
    persistentKeys = true;
    settings = {
      Listen = [
        "tls://0.0.0.0:${toString port}" 
      ];
      Peers = [];
      AllowedPublicKeys = [];
      MulticastInterfaces = [
        {
	  Regex = "*";
	  Listen = false;
	}
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];

}
