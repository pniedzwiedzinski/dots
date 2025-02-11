{
  virtualisation.oci-containers.containers.changedetection = {
    image = "ghcr.io/dgtlmoon/changedetection.io";
    ports = ["5000:5000"];
    volumes = ["changedetection-data:/datastore"];
  };
}
