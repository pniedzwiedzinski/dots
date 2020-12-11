{ pkgs, ... }:
{
  hardware.pulseaudio.enable = true;

  environment.systemPackages = with pkgs; [
    pulsemixer
    pamixer
  ];
}
