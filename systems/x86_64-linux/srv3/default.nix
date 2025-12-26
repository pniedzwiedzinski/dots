{ inputs, ... }:
{
  imports = with inputs; [
    disko.nixosModules.disko
    impermanence.nixosModules.impermanence
    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
