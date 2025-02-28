{
  services.openssh = {
    enable = true;
    ports = [19];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = ["pn@192.168.1.*"];
    };
  };
  services.sshguard = {
    enable = true;
    whitelist = [
      "192.168.1.0/24"
    ];
  };
}
