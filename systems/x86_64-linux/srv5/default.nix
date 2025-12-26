{ inputs, ... }:
{
  imports = with inputs; [
    disko.nixosModules.disko
    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
