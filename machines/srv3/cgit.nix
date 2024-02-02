{ pkgs, ...}:
let
  cgitHostname = "git.niedzwiedzinski.cyou";

  mirror = pkgs.writeScriptBin "mirror" ''
  #!/bin/sh

  name=`echo "$1" | rev | cut -d'/' -f1 | rev`

  cd /srv/git
  sudo -u git ${pkgs.git}/bin/git clone --mirror $1 $name
  sudo -u git /run/current-system/sw/bin/chmod -R g+w $name
  '';

  newrepo = pkgs.writeScriptBin "newrepo" ''
  #!/bin/sh

  [ -z $1 ] && echo "Pass repo name" && exit 1

  sudo -u git git init --bare /srv/git/$1
  sudo -u git /run/current-system/sw/bin/chmod -R g+w /srv/git/$1
  '';

in
{
  environment.systemPackages = [ newrepo mirror ];
  systemd.services.git-fetch = {
    script = ''
      #!/bin/sh
      cd /srv/git
      for f in `find . -name HEAD`; do
        cd ''${f%HEAD}
        ${pkgs.git}/bin/git fetch
        cd /srv/git
      done
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "git";
    };
  };
  systemd.timers.git-fetch = {
    partOf = [ "git-fetch.service" ];
    wantedBy = ["timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Unit = "git-fetch.service";
    };
  };
  services.nginx.virtualHosts."${cgitHostname}".locations."=/mylogo.png" = {
     alias = "${./baby-yoda.png.comp}";
   };
  services.cgit.gitN = {
    enable = true;
    package = pkgs.cgit-pink;
    scanPath = "/srv/git";
    nginx.virtualHost = cgitHostname;
    settings = {
      about-filter = let formatScript = pkgs.writeScriptBin "about-format.sh" ''
          #!/bin/sh
          ${pkgs.coreutils}/bin/cat << EOF
          <style>
          .md blockquote {
            background: #eee;
            font-style: italic;
            padding: 0 1em;
          }
          </style>
          <div class="md">
          EOF
          ${pkgs.coreutils}/bin/cat /dev/stdin | ${pkgs.lowdown}/bin/lowdown
          echo '</div>'
        '';
      in "${formatScript}/bin/about-format.sh";
      cache-size = "1000";
      root-title = cgitHostname;
      root-desc = "Personal git server, because I can";
      readme = ":README.md";
      snapshots = "tar.gz zip";
      clone-prefix = "https://${cgitHostname}";
      section-from-path = "1";
      logo = "/mylogo.png";
    };
  };

  users = {
    groups = { git = {}; };
    users = {
      git = {
        isSystemUser = true;
        group = "git";
        description = "git user";
        home = "/srv/git";
        shell = "${pkgs.git}/bin/git-shell";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqlCe4ovKa/Gwl5xmgu9nvVPmFXMgwdeLRYW7Gg7RWx pniedzwiedzinski19@gmail.com"
        ];
      };
    };
  };
}
