## Basic rules for interacting with the internet
{ pkgs, lib, ... }:
let
  blocklist = pkgs.writeText "hosts" ''
    0.0.0.0 netflix.com
    0.0.0.0 hbogo.com
  '';
    # 0.0.0.0 www.facebook.com
in
{
  # networking.nameservers = lib.mkForce [
  #   "192.168.1.136"
  #   "1.1.1.1"
  #   "8.8.8.8"
  # ];

  environment.etc."resolv.conf".text = ''
    nameserver 192.168.1.136
    nameserver 1.1.1.1
    nameserver 8.8.8.8
    options edns0
  '';


  networking.hostFiles = [
    ( pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/StevenBlack/hosts/d2be343994aacdec74865ff8d159cf6e46359adf/alternates/fakenews-gambling-porn/hosts";
      sha256 = "1la5rd0znc25q8yd1iwbx22zzqi6941vyzmgar32jx568j856s8j";
    } )
      blocklist
    ];

  }
