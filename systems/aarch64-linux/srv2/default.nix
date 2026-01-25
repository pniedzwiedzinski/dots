{inputs, ...}: {
  imports = with inputs; [
    nixos-hardware.nixosModules.raspberry-pi-3
    ./configuration.nix
  ];

  srv = {
    enable = true;
    machineId = "srv2";
  };
}
