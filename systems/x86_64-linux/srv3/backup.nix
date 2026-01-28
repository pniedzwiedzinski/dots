{pkgs, ...}: {
  services.borgbackup.jobs = {
    "borgbase" = {
      paths = [
        "/srv"
      ];
      exclude = [
        "/srv/immich"
        "/srv/www"
      ];
      repo = "ssh://p2958493@p2958493.repo.borgbase.com/./repo";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat /persist/srv3_borgbase_backup_password";
      };
      environment.BORG_RSH = "ssh -i /persist/srv3_borgbase_backup";
      compression = "auto,lzma";
      startAt = "daily";
    };

    "backup" = {
      paths = [
        "/persist/etc"
        "/persist/home"
        "/persist/srv"
        "/persist/var"
      ];
      exclude = [
        "/persist/var/lib/docker" # ignore images
        "/persist/var/lib/systemd" # ignore systemd states
        "/persist/srv/immich/thumbs" # immich save space
        "/persist/srv/immich/encoded-video" # immich save space
        "/persist/srv/postgres-immich"
        "/persist/srv/to-remove-immich-postgres"
      ];
      prune.keep = {
        within = "1d";
        daily = 7;
      };
      repo = "borg@backup:.";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat /persist/srv3_backup_passphrase";
      };
      environment.BORG_RSH = "ssh -i /persist/srv3_backup_ssh_key";
      compression = "auto,lzma";
      startAt = "daily";
    };
  };

  programs.ssh.knownHosts = {
    "backup" = {
      hostNames = ["backup"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKJMMICV34JhvF5SO7Ldg+0v3W/B6hXBbnvmeYW5+Qmw";
    };
  };
}
