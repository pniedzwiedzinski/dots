{ ... }:
{

  services.yggdrasil = {
    enable = true;
    persistentKeys = true;
    settings = {
      Listen = [];
      Peers = [
        "tls://patryk.ddns.net:1919"
      ];
      AllowedPublicKeys = [
        "af868e700b6caa8debe0f912ea14b7f7c98a09418d2bf13f56e7a9a5ec73b5a8" #srv4
        "d77a4325c4d60157017e3656de31ad067b3bae754a7f0f3b2fd78679a622dc4e" #srv3
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

}
