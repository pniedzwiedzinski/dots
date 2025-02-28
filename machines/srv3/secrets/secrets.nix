let
  srv3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlEuyeV5eu0UijZuRSoc3SpjoaChPmoAJ+sPW/AoDch";
in {
  "noip-passwd.age".publicKeys = [srv3];
  "noip-login.age".publicKeys = [srv3];

  "fresh-passwd.age".publicKeys = [srv3];
}
