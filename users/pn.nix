## My default user

{
  users.users.pn = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  ## Although it's less secure I tend not to have sensitive data on my machines
  security.sudo.wheelNeedsPassword = false;
}
