{ pkgs, ... }:
{
  hardware.pulseaudio = {
    enable = true;
    configFile = ./pulseaudio.pa;
  };

  environment.systemPackages = with pkgs; [
    pulsemixer
    pamixer
  ];
}
