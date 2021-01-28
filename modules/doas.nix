{
  security.sudo.enable = false;
  security.doas = {
    enable = true;
    wheelNeedsPassword = false;
  };
  environment.shellAliases = {
    sudo = "doas";
  };
}
