{ inputs, pkgs, ... }:
{
  imports = with inputs; [
    nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen2
    home-manager.nixosModules.default
    nix-index-database.nixosModules.nix-index
    disko.nixosModules.disko

    ./hardware-configuration.nix
    ./configuration.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.pn = import ./home.nix;
  };
  environment.systemPackages = with inputs; [
    ronvim.packages.x86_64-linux.default
    pnvf.packages.x86_64-linux.default

    self.packages.x86_64-linux.gpt
    self.packages.x86_64-linux.rebuild
  ];

  nix = {
    extraOptions = "extra-experimental-features = nix-command flakes";
  };

  networking.hostName = "t14";
}
