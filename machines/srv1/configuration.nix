{ config, pkgs, ... }:
let
  ModSecurity-nginx = pkgs.callPackage ./modsecurity.nix { };
  crs = pkgs.callPackage ./coreruleset.nix { };
  nvim = (import (pkgs.fetchzip {
    url = "https://github.com/nixos/nixpkgs/archive/517c29935b6e4dec12571e7d101e2b0da220263d.zip";
    sha256 = "1s85sz62iykvca90d3cgd981670rnkd5c171wda7wpwdj0d52sf3";
  }) { }).neovim.override {
    vimAlias = true;
  };

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
    imports =
      [
      #./hardware-configuration.nix
      ./cgit.nix
      ./yggdrasil.nix
    ];

    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

    networking.hostName = "srv1";
    networking.extraHosts = ''
      192.168.1.136 srv1.niedzwiedzinski.cyou git.niedzwiedzinski.cyou tmp.niedzwiedzinski.cyou zhr.niedzwiedzinski.cyou help.niedzwiedzinski.cyou niedzwiedzinski.cyou
    '' + pkgs.stdenv.lib.readFile ( pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/StevenBlack/hosts/d2be343994aacdec74865ff8d159cf6e46359adf/alternates/fakenews-gambling-porn/hosts";
      sha256 = "1la5rd0znc25q8yd1iwbx22zzqi6941vyzmgar32jx568j856s8j";
    } );

    services.dnsmasq = {
      enable = true;
      servers = [ "1.1.1.1" "8.8.8.8" ];
      extraConfig = ''
        address=/.srv1.niedzwiedzinski.cyou/192.168.1.136
      '';
    };

    time.timeZone = "Europe/Warsaw";
    i18n.defaultLocale = "en_US.UTF-8"; # Less confusing locale than polish one
    console.keyMap = "pl";

    nix.gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    nix.optimise.automatic = true;
    nix.trustedUsers = [ "pn" ];
    system.autoUpgrade = {
      enable = true;
      allowReboot = true;
    };

    nixpkgs.config = {
      packageOverrides = super: {
        rss-bridge = super.rss-bridge.overrideDerivation (attrs: {
    src = pkgs.fetchFromGitHub {
            owner = "RSS-Bridge";
            repo = "rss-bridge";
            rev = "ee5d190391afffd037e09c04418a240f7ac67ecd";
            sha256 = "0sxdl6ycqmhd76hc5r8i1yv8vgl18ssmv1p9dzx8ikp5imvfgakc";
          };
        });
      };
    };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp4s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  environment.systemPackages = with pkgs; [
    curl wget htop git
    nvim lm_sensors
    mirror
    newrepo
  ];

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.sshguard = {
    enable = true;
    whitelist = [
      "192.168.0.0/18"
      "201:da2c:2873:5ee3:cc87:79ce:5a12:fff9"
    ];
  };

  services.nginx.enable = true;
  services.nginx.package = (pkgs.nginx.override { modules = [ ModSecurity-nginx ]; });
  services.nginx.appendHttpConfig = ''
    modsecurity on;
    # modsecurity_rules '
    #   SecRuleEngine On
    #   Include ${crs}/crs-setup.conf;
    #   Include ${crs}/rules/*.conf;
    # ';
    charset utf-8;
    source_charset utf-8;
  '';
  services.nginx.virtualHosts = {
    "srv1.niedzwiedzinski.cyou" = let
      modsec_config = builtins.toFile "modsecurity_rules.conf" ''
        SecRuleEngine On
        SecRule ARGS:testparam "@contains test" "id:1234,deny,status:403"
      '';
    in {
      enableACME = true;
      forceSSL = true;
      extraConfig = ''
        location ~ /*.md {
	  types { } default_type "text/markdown; charset=utf-8";
        }
        modsecurity_rules_file ${modsec_config};
      '';
      root = "/var/www/srv1.niedzwiedzinski.cyou";
    };
    "pics.srv1.niedzwiedzinski.cyou" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/pics.srv1.niedzwiedzinski.cyou";
    };
    "rss.srv1.niedzwiedzinski.cyou" = {
      enableACME = true;
      forceSSL = true;
      extraConfig = ''
        modsecurity_rules '
          SecRuleEngine On
          SecRule ARGS:u "@rx life[-_]*hack(s)?" "id:1234,deny,status:403"
        ';
      '';
    };
    "git.niedzwiedzinski.cyou" = {
      locations."/".proxyPass = "http://0.0.0.0:8080/cgit/";
      locations."/cgit/".extraConfig = ''
        rewrite ^/cgit/(.*) https://git.niedzwiedzinski.cyou/$1;
      '';
      enableACME = true;
      forceSSL = true;
    };
    "tmp.niedzwiedzinski.cyou" = {
      enableACME = true;
      addSSL = true;
      root = "/var/www/tmp.niedzwiedzinski.cyou";
      extraConfig = ''
        modsecurity_rules '
          SecRuleEngine On
          SecRule ARGS:testparam "@contains test" "id:1234,deny,status:403"
          Include ${crs}/crs-setup.conf
          Include ${crs}/all-rules.conf
        ';
      '';
    };
    "niedzwiedzinski.cyou" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/niedzwiedzinski.cyou";
    };
    "y.niedzwiedzinski.cyou" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/niedzwiedzinski.cyou";
      locations."/omick.net".proxyPass = "http://omick.net/";
      locations."/suckless.org".proxyPass = "http://suckless.org/";
      locations."/based.cooking".proxyPass = "http://based.cooking/";

    };
    "zhr.niedzwiedzinski.cyou" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/zhr.niedzwiedzinski.cyou";
      extraConfig = ''
        location /rozkazy/ {
          autoindex on;
        }
      '';
    };
    "help.niedzwiedzinski.cyou" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/niedzwiedzinski.cyou/help";
    };
  };
  security.acme.email = "pniedzwiedzinski19@gmail.com";
  security.acme.acceptTerms = true;

  networking.firewall.allowedTCPPorts = [ 53 80 443 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.molly-brown = {
    #hostName = "srv1.niedzwiedzinski.cyou";
    #enable = true;
  };

  systemd = {
    services.git-fetch = {
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
    timers.git-fetch = {
      partOf = [ "git-fetch.service" ];
      wantedBy = ["timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        Unit = "git-fetch.service";
      };
    };

  };

  services.lighttpd = {
    enable = true;
    port = 8080;
    pn-cgit = {
      logo = "${./baby-yoda.png.comp}";
      enable = true;
      configText = let
        aboutFilter = pkgs.writeScriptBin "about-format.sh" ''
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
      in ''
        # source-filter=${pkgs.cgit}/lib/cgit/filters/syntax-highlighting.sh
        about-filter=${aboutFilter}/bin/about-format.sh
        #about-filter=${pkgs.discount}/bin/markdown
        cache-size=1000
        root-title=git.niedzwiedzinski.cyou
        root-desc=Personal git server, because I can
        readme=:README.md
        snapshots=tar.gz
        clone-prefix=https://git.niedzwiedzinski.cyou
        section-from-path=1
        scan-path=/srv/git/
      '';
    };
  };

  services.rss-bridge = {
    enable = true;
    virtualHost = "rss.srv1.niedzwiedzinski.cyou";
    whitelist = [
      "Instagram"
      "Soundcloud"
      "Facebook"
    ];
  };

  users = {
    groups = {
      git = {};
    };
    users = {
      pn = {
        isNormalUser = true;
        extraGroups = [ "wheel" "git" ]; # Enable ‘sudo’ for the user.
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqlCe4ovKa/Gwl5xmgu9nvVPmFXMgwdeLRYW7Gg7RWx pniedzwiedzinski19@gmail.com"
        ];
      };

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
