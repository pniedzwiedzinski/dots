## Basic rules for interacting with the internet
{ pkgs, ... }:
{
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];


  networking.extraHosts = "${ pkgs.stdenv.lib.readFile "${pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/StevenBlack/hosts/5a5016ab5bf0166e004147cb49ccd0114ed29b72/alternates/fakenews-gambling-porn/hosts";
    sha256 = "1c60fyzxz89bic6ymcvb8fcanyxpzr8v2z5vixxr79d8mj0vjswm";
  }}"}";
}
