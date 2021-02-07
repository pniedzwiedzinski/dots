{ config, pkgs, ... }:
let
  nvim = pkgs.neovim.override {
    vimAlias = true;
  };
in
  {
    imports =
      [
      #./hardware-configuration.nix
      ./cgit.nix
    ];

    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

    networking.hostName = "srv1";

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
    curl wget nvim htop git
  ];

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  services.sshguard.enable = true;

  services.nginx.enable = true;
  services.nginx.virtualHosts."srv1.niedzwiedzinski.cyou" = {
    addSSL = true;
    enableACME = true;
    root = "/var/www/srv1.niedzwiedzinski.cyou";
  };
  services.nginx.virtualHosts."git.niedzwiedzinski.cyou" = {
    locations."/".proxyPass = "http://localhost:8080/cgit/";
    locations."/cgit/".proxyPass = "http://localhost:8080";
  };
  security.acme.certs = {
    "srv1.niedzwiedzinski.cyou".email = "pniedzwiedzinski19@gmail.com";
  };
  security.acme.acceptTerms = true;

  networking.firewall.allowedTCPPorts = [ 80 8080 443 ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  services.molly-brown = {
    #hostName = "srv1.niedzwiedzinski.cyou";
    #enable = true;
  };

  systemd = {
    services.git-fetch = {
      script = ''
        cd /srv/git
        for f in `ls -I git-shell-commands`; do
          cd $f
          git fetch
          cd ..
        done
      '';
      serviceConfig = {
        Type = "oneshot";
      };
    };
    timers.git-fetch = {
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
      configText = ''
        # source-filter=${pkgs.cgit}/lib/cgit/filters/syntax-highlighting.sh
        about-filter=${pkgs.cgit}/lib/cgit/filters/about-formatting.sh
        cache-size=1000
        root-title=git.niedzwiedzinski.cyou
        root-desc=Personal git server, because I can
        scan-path=/srv/git/
        virtual-root=/
        readme=:README.md
        readme=:README.rst
        readme=:README.txt
        readme=:README

      '';
    };
  };

  users.users.pn = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqlCe4ovKa/Gwl5xmgu9nvVPmFXMgwdeLRYW7Gg7RWx pniedzwiedzinski19@gmail.com"
    ];
  };

  users.users.git = {
    isSystemUser = true;
    description = "git user";
    home = "/srv/git";
    shell = "${pkgs.git}/bin/git-shell";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIqlCe4ovKa/Gwl5xmgu9nvVPmFXMgwdeLRYW7Gg7RWx pniedzwiedzinski19@gmail.com"
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}