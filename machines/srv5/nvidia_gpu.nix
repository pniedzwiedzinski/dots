{
  config,
  pkgs,
  ...
}: {
  virtualisation.docker.daemon.settings.features.cdi = true;
  hardware.nvidia-container-toolkit.enable = true;

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production;

  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = ["nvidia"];

  nixpkgs.config.cudaSupport = true;

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
    cudaPackages.cudatoolkit
  ];
}
