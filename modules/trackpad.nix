{
  services.xserver.libinput = {
    enable = true;
    naturalScrolling = true;
    additionalOptions = ''MatchIsTouchpad "on"'';
  };
}
