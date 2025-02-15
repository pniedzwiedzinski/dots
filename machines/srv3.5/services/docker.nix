{
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
  users.extraGroups.docker.members = ["pn"];

  environment.persistence."/persist".directories = [
    "/var/lib/docker"
  ];
}
