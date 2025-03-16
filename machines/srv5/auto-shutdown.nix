{pkgs, ...}: let
  script = pkgs.writeShellScriptBin "auto_shutdown" ''
    #!/${pkgs.bash}/bin/bash
    export PATH=${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.docker}/bin:$PATH

    check_activity() {
      # Check for active SSH sessions
      ssh_sessions=$(who | grep -E "(pts|tty)" -c)

      # Check for running Ollama jobs
      ollama_jobs=$(docker exec ollama ollama ps | wc -l)

      if [[ "$ssh_sessions" -ge 1 ]]; then
        echo "SSH active"
        return 1
      fi
      if [[ "$ollama_jobs" -ge 2 ]]; then
        echo "Ollama active"
        return 1 # No activity (ollama ps header line counts as 1)
      fi
      return 0 # Activity detected
    }

    while true; do
      if ! check_activity; then
        sleep 60 # Check again in a minute
      else
        echo "No SSH and Ollama active, starting timeout"
        sleep 300 # No activity, wait 5 more minutes
        if check_activity; then
          echo "No activity detected, shutting down..."
          systemctl poweroff
        fi
      fi
      sleep 60
    done
  '';
in {
  systemd.services.ssh-ollama-shutdown = {
    description = "Shutdown system if no SSH or Ollama activity detected";
    after = ["network.target" "docker.service"];
    wants = ["network.target" "docker.service"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${script}/bin/auto_shutdown";
      Restart = "always";
      RestartSec = "10s";
    };
    wantedBy = ["multi-user.target"];
  };
}
