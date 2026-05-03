{
  virtualisation.oci-containers.containers."changedetection" = {
    image = "ghcr.io/dgtlmoon/changedetection.io:0.55.3@sha256:2d0030e12494be9ebf6a6ebbbad46afe5763f498bbfefe9ebb7f0bf6be3ca5dc";
    ports = [
      "127.0.0.1:5000:5000"
    ];
    volumes = [
      "/srv/changedetection:/datastore"
    ];
    environment = {
      PUID = "1000";
      PGID = "1000";
    };
  };
}
