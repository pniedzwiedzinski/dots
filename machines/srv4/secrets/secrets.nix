let
  pi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHZLujsz0Us5/KOt4mBDcJcxS/h7FIMD90UusYf43iXU";
in
{
  "cloudflared.cert.pem.age".publicKeys = [ pi ];
}
