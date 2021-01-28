{ config, pkgs, ... }:

{

  imports = [
    ../base.nix
    ../pl.nix
    #../../modules/larbs.nix
  ];


  networking.hostName = "adax";

  environment.systemPackages = with pkgs; [
  ];

  # https://sgt.hootr.club/molten-matter/nix-distributed-builds/
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  services.openssh.enable = true;
  nix.trustedUsers = [ "bob" ];
  users.users.bob = {
    description = "Bob the Builder";
    isNormalUser = true;
    createHome = true;
    shell = "/bin/sh";
  };

}
