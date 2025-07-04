{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    esphome
  ];

  users.users.pn.extraGroups = ["dialout"];
}
