# Auto-generated using compose2nix v0.3.2-pre.
{
  pkgs,
  lib,
  ...
}: {
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."ollama" = {
    image = "ollama/ollama";
    environment = {
      "OLLAMA_HOST" = "0.0.0.0:11434";
    };
    volumes = [
      "ollama:/root/.ollama:rw"
    ];
    ports = [
      "11434:11434/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--device=nvidia.com/gpu=all"
      "--network-alias=ollama"
      "--network=ollama_default"
    ];
  };
  systemd.services."docker-ollama" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-ollama_default.service"
      "docker-volume-ollama_ollama.service"
    ];
    requires = [
      "docker-network-ollama_default.service"
      "docker-volume-ollama_ollama.service"
    ];
    partOf = [
      "docker-compose-ollama-root.target"
    ];
    wantedBy = [
      "docker-compose-ollama-root.target"
    ];
  };
  # Networks
  systemd.services."docker-network-ollama_default" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f ollama_default";
    };
    script = ''
      docker network inspect ollama_default || docker network create ollama_default
    '';
    partOf = ["docker-compose-ollama-root.target"];
    wantedBy = ["docker-compose-ollama-root.target"];
  };

  # Volumes
  systemd.services."docker-volume-ollama_ollama" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect ollama_ollama || docker volume create ollama_ollama
    '';
    partOf = ["docker-compose-ollama-root.target"];
    wantedBy = ["docker-compose-ollama-root.target"];
  };
  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-ollama-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
