{ inputs, ... }:
{
  imports = with inputs; [
    agenix.nixosModules.default
    disko.nixosModules.disko
    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
