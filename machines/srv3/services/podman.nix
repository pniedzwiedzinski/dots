{pkgs, ...}: {
  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      dockerSocket.enable = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Useful other development tools
  environment.systemPackages = with pkgs; [
    podman-tui # status of containers in the terminal
    podman-compose # start group of containers for dev
  ];

  environment.persistence."/persist".directories = [
    {
      directory = "/home/pn/.local/share/containers";
      user = "pn";
      group = "users";
      mode = "755";
    }
  ];

  users.users."podman" = {
    isSystemUser = true;
    group = "podman";
  };
  users.groups.podman = {};
}
