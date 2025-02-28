{ lib, ... }:
{
  services.openssh = {
    enable = true;
    ports = lib.mkForce [ 19 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "pn@192.168.1.*" ];
    };
  };
  networking.firewall.allowedTCPPorts = [ 19 ];
  services.sshguard = {
    enable = true;
    whitelist = [
      "192.168.1.0/24"
    ];
  };
}
