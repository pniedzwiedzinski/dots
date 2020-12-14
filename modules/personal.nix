## Personal utils for daily use machines like laptop, cell phone
## This should not be used on a server

{ pkgs, ... }:
{
  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gnome3";
    };
  };

  environment.systemPackages = with pkgs; [
    pass ssh-ident
  ];

  programs.browserpass.enable = true;

  environment.shellAliases = {
    ssh = "ssh-ident";
  };

}
