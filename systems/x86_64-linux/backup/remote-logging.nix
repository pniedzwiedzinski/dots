{ config, lib, pkgs, ... }:

{
  services.journald.remote = {
    enable = true;
    listen = "http";
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    19532 # default systemd-journal-remote port
  ];
}
