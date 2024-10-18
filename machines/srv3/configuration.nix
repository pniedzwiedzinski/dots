{ config, lib, pkgs, ... }:
let
  crs = pkgs.callPackage ./coreruleset.nix { };
  
  www = "/srv/www";

  domain = "niedzwiedzinski.cyou";

in
  {
    imports =
      [
      ../../modules/obsidian-livesync.nix
      ./hardware-configuration.nix
      ./cgit.nix
      ./noip.nix
    ];

    services.obsidian-livesync = {
    	enable = true;
	domain = "obsidian.${domain}";
	adminsFile = "/etc/couchdb.ini";
    };

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only



    networking = {
      useDHCP = false;
      interfaces.enp1s0 = {
        useDHCP = true;
        ipv4.addresses = [{
          address = "192.168.1.136";
          prefixLength = 24;
        }];
      };
      hostName = "srv3";
      extraHosts = ''
      192.168.1.136 srv3.niedzwiedzinski.cyou git.niedzwiedzinski.cyou tmp.niedzwiedzinski.cyou zhr.niedzwiedzinski.cyou help.niedzwiedzinski.cyou niedzwiedzinski.cyou pics.niedzwiedzinski.cyou fresh.niedzwiedzinski.cyou obsidian.${domain}
      192.168.1.144 srv2.niedzwiedzinski.cyou
    '' + lib.readFile ( pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/StevenBlack/hosts/d2be343994aacdec74865ff8d159cf6e46359adf/alternates/fakenews-gambling-porn/hosts";
      sha256 = "1la5rd0znc25q8yd1iwbx22zzqi6941vyzmgar32jx568j856s8j";
      } );
    };

    services.dnsmasq = {
      enable = true;
      settings = {
        server = [ "1.1.1.1" "8.8.8.8" ];
        #address=/.srv1.niedzwiedzinski.cyou/192.168.1.136
        address="/.srv2.niedzwiedzinski.cyou/192.168.1.144";
      };
    };

    time.timeZone = "Europe/Warsaw";
    i18n.defaultLocale = "en_US.UTF-8"; # Less confusing locale than polish one
    console.keyMap = "pl";

    nix.gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    nix.optimise.automatic = true;
    system.autoUpgrade = {
      enable = true;
      allowReboot = true;
    };

  environment.systemPackages = with pkgs; [
    curl wget htop git
    vim lm_sensors
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      #AllowGroups = ["using-ssh"];
      AllowUsers = [ "pn-ssh" "pn@192.168.1.*" ];
    };
  };
  services.sshguard = {
    enable = true;
    whitelist = [
      "192.168.1.0/24"
    ];
  };

  services.freshrss = {
    enable = true;
    virtualHost = "fresh.niedzwiedzinski.cyou";
    baseUrl = "https://fresh.niedzwiedzinski.cyou";
    authType = "form";
    defaultUser = "admin";
    passwordFile = "/fresh/passwd";
  };

  services.nginx.enable = true;
  services.nginx.additionalModules = with pkgs.nginxModules; [ modsecurity ];
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
    "srv3.niedzwiedzinski.cyou" = let
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
      root = "${www}/srv3.niedzwiedzinski.cyou";
    };
    "pics.srv3.niedzwiedzinski.cyou" = {
      enableACME = true;
      forceSSL = true;
      root = "${www}/pics.niedzwiedzinski.cyou";
    };
    "pics.niedzwiedzinski.cyou" = {
      enableACME = true;
      forceSSL = true;
      root = "${www}/pics.niedzwiedzinski.cyou";
    };
    "tmp.niedzwiedzinski.cyou" = {
      enableACME = true;
      addSSL = true;
      root = "${www}/tmp.niedzwiedzinski.cyou";
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
      root = "${www}/niedzwiedzinski.cyou";
    };
    "zhr.niedzwiedzinski.cyou" = {
      enableACME = true;
      forceSSL = true;
      root = "${www}/zhr.niedzwiedzinski.cyou";
      extraConfig = ''
        location /rozkazy/ {
          autoindex on;
        }
      '';
    };
    "help.niedzwiedzinski.cyou" = {
      enableACME = true;
      forceSSL = true;
      root = "${www}/niedzwiedzinski.cyou/help";
    };
   "fresh.niedzwiedzinski.cyou" = {
      enableACME = true;
      forceSSL = true;
    };
  };
  security.acme.defaults.email = "pniedzwiedzinski19@gmail.com";
  security.acme.acceptTerms = true;

  networking.firewall.allowedTCPPorts = [ 53 80 443 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  virtualisation.docker.enable = true;

  users = {
    groups."using-ssh" = { name = "using-ssh"; };
    users = {
      pn-ssh = {
        description = "patryk-zdalny";
        isNormalUser = true;
        extraGroups = [ "pn" "git" "using-ssh"];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqlCe4ovKa/Gwl5xmgu9nvVPmFXMgwdeLRYW7Gg7RWx pniedzwiedzinski19@gmail.com"
        ];
      };
      pn = {
	description = "patryk";
        isNormalUser = true;
        extraGroups = [ "wheel" "git" "using-ssh" "docker" ]; # Enable ‘sudo’ for the user.
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqlCe4ovKa/Gwl5xmgu9nvVPmFXMgwdeLRYW7Gg7RWx pniedzwiedzinski19@gmail.com"
        ];
      };
    };
  };
}
