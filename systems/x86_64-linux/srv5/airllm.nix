{
  pkgs,
  lib,
  ...
}: {
  virtualisation.oci-containers.containers."airllm" = {
    image = "airllm:latest";
    autoStart = true;
    ports = [
      "5000:5000/tcp"
    ];
    environment = {
      MODEL_ID = "Qwen/Qwen3.5-4B";
      MAX_LENGTH = "128";
      COMPRESSION = "4bit";
    };
    volumes = [
      "airllm_hf-cache:/root/.cache/huggingface:rw"
    ];
    extraOptions = [
      "--device=nvidia.com/gpu=all"
      "--network-alias=airllm"
      "--network=airllm_default"
    ];
    dependsOn = [ "build-airllm-image" ];
    log-driver = "journald";
  };

  systemd.services."docker-airllm" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    partOf = [
      "docker-compose-airllm-root.target"
    ];
    wantedBy = [
      "docker-compose-airllm-root.target"
    ];
  };

  systemd.services."build-airllm-image" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      cd /etc/nixos/systems/x86_64-linux/srv5/airllm && docker build -t airllm:latest .
    '';
    wantedBy = ["multi-user.target"];
  };

  systemd.services."docker-network-airllm_default" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm airllm_default";
    };
    script = ''
      docker network inspect airllm_default || docker network create airllm_default
    '';
    partOf = ["docker-compose-airllm-root.target"];
    wantedBy = ["docker-compose-airllm-root.target"];
  };

  systemd.services."docker-volume-airllm_hf-cache" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect airllm_hf-cache || docker volume create airllm_hf-cache
    '';
    partOf = ["docker-compose-airllm-root.target"];
    wantedBy = ["docker-compose-airllm-root.target"];
  };

  systemd.targets."docker-compose-airllm-root" = {
    unitConfig = {
      Description = "Root target for airllm.";
    };
    wantedBy = ["multi-user.target"];
  };
}
