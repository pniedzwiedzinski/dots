{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dots.nvidia;
in
{
  options.dots.nvidia = {
    enable = lib.mkEnableOption "NVIDIA GPU drivers and container toolkit";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.daemon.settings.features.cdi = true;
    hardware.nvidia-container-toolkit.enable = true;

    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.production;
      open = false;
    };

    hardware.graphics.enable = true;

    services.xserver.videoDrivers = [ "nvidia" ];

    nixpkgs.config.cudaSupport = true;

    environment.systemPackages = with pkgs; [
      nvtopPackages.nvidia
      cudaPackages.cudatoolkit
    ];
  };
}
