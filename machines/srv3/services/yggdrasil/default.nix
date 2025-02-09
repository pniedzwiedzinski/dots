{ ... }:
let
  port = 22;
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
      AllowedPublicKeys = [
        "af868e700b6caa8debe0f912ea14b7f7c98a09418d2bf13f56e7a9a5ec73b5a8" #srv4
        "e499a4996d79d1e083a61cf024cecdf02cb51a4cd5c27dfbd82bf76b9fa9c904" #t14
        "2a0b4bb6616f881b094a6336961212c4194b19e438b1822ba151538afdc1e64c" #oppo
      ];
      MulticastInterfaces = [
        {
	  Regex = ".*";
          Beacon = false;
	  Listen = false;
          Password = "";
	}
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];

}
