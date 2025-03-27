{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.wakeonhttp;
  pythonEnv = pkgs.python3.withPackages (ps:
    with ps; [
      flask
      requests
      rpi-gpio
    ]);
in {
  options = {
    services.wakeonhttp = {
      enable = mkEnableOption "Raspberry Pi Gateway";

      port = mkOption {
        type = types.port;
        default = 5000;
        description = "Port to listen for http requests";
      };

      gpioPin = mkOption {
        type = types.ints.positive;
        default = 14;
        description = "GPIO pin number connected to the host";
      };

      ollamaUrl = mkOption {
        type = types.str;
        default = "http://192.168.1.244:11434";
        description = "Ollama server url";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.wakeonhttp = {
      description = "Raspberry Pi Gateway Service";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = ''
          ${pythonEnv.interpreter} ${./wakeonhttp.py} \
            --port=${toString cfg.port} \
            --gpio-pin=${toString cfg.gpioPin} \
            --ollama-url=${toString cfg.ollamaUrl}
        '';
        Restart = "always";
        User = "wakeonhttp";
      };
    };

    networking.firewall.allowedTCPPorts = [cfg.port];

    users.groups.gpio = {};

    users.users.wakeonhttp = {
      isSystemUser = true;
      description = "wakeonhttp service user";
      group = "gpio";
    };

    services.udev.extraRules = ''
      SUBSYSTEM=="gpio", KERNEL=="gpio*", GROUP="gpio", MODE="0660"
      SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", \
        RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio /sys/class/gpio/export /sys/class/gpio/unexport; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
      SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add", \
        RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value; chmod 660 /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value'"
    '';
  };
}
