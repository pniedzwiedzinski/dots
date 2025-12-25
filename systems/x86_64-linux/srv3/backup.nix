{pkgs, ...}: {
  services.borgbackup.jobs."borgbase" = {
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
      passCommand = "cat /persist/srv3_borg_backup_password";
    };
    environment.BORG_RSH = "ssh -i /persist/srv3_borg_backup";
    compression = "auto,lzma";
    startAt = "daily";
  };
}
