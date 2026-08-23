{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dots.autoShutdown;
  script = pkgs.writeShellScriptBin "auto-shutdown" ''
    export PATH=${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.docker}/bin:$PATH

    check_activity() {
      ssh_sessions=$(who | grep -E "(pts|tty)" -c)
      ollama_jobs=$(docker exec ollama ollama ps | wc -l)

      if [[ "$ssh_sessions" -ge 1 ]]; then
        echo "SSH active"
        return 1
      fi
      if [[ "$ollama_jobs" -ge 2 ]]; then
        echo "Ollama active"
        return 1
      fi
      return 0
    }

    while true; do
      if ! check_activity; then
        sleep 60
      else
        echo "No SSH and Ollama active, starting timeout"
        sleep 300
        if check_activity; then
          echo "No activity detected, shutting down..."
          systemctl poweroff
        fi
      fi
      sleep 60
    done
  '';
in
{
  options.dots.autoShutdown = {
    enable = lib.mkEnableOption "Automatic idle shutdown";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ssh-ollama-shutdown = {
      description = "Shutdown system if no SSH or Ollama activity detected";
      after = [
        "network.target"
        "docker.service"
      ];
      wants = [
        "network.target"
        "docker.service"
      ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${script}/bin/auto-shutdown";
        Restart = "always";
        RestartSec = "10s";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
