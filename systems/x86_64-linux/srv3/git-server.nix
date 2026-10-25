{...}: {
  services.openssh.settings.AllowUsers = ["git"];
  users.users.git = {
    isNormalUser = true;
    home = "/srv/git";
    createHome = false;
    description = "Git repository user";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqlCe4ovKa/Gwl5xmgu9nvVPmFXMgwdeLRYW7Gg7RWx pniedzwiedzinski19@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINEx9Pnd+TE6yGEsn0Z1nDJgqv4be2XH/+URvP9zQLlr oppo"
    ];
  };
}
