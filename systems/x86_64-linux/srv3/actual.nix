{
  virtualisation.oci-containers = {
    backend = "docker";
    containers.actual = {
      autoStart = true;
      image = "actualbudget/actual-server:latest";
      ports = [
        "127.0.0.1:3006:5006"
      ];
      volumes = ["/srv/actual/data:/data"];
      extraOptions = [
        "--pull=always"
      ];
    };
  };
}
