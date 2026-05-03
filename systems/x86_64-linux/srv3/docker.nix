{
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
  virtualisation.oci-containers.backend = "docker";
  users.extraGroups.docker.members = ["pn"];

  environment.persistence."/persist".directories = [
    "/var/lib/docker"
  ];
}
