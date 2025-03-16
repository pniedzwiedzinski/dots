{pkgs, ...}: let
  script = pkgs.writeShellScriptBin "auto_shutdown" ''
    #!/${pkgs.bash}/bin/bash
    export PATH=${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.docker}/bin:$PATH

    check_activity() {
    	# Check for active SSH sessions
    	ssh_sessions=$(who | grep -E "(pts|tty)" -c)

    	# Check for running Ollama jobs
    	ollama_jobs=$(docker exec ollama ollama ps | wc -l)

    	if [[ "$ssh_sessions" -eq 0 && "$ollama_jobs" -le 1 ]]; then
    		return 1 # No activity (ollama ps header line counts as 1)
    	else
    		return 0 # Activity detected
    	fi
    }

    while true; do
    	if check_activity; then
    		sleep 60 # Check again in a minute
    	else
    		sleep 300 # No activity, wait 5 more minutes
    		if ! check_activity; then
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
