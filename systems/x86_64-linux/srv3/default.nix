{ inputs, ... }:
{
  imports = with inputs; [
    disko.nixosModules.disko
    impermanence.nixosModules.impermanence
    hermes-agent.nixosModules.default
    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
