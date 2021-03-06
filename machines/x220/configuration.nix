{ pkgs, lib, ... }:

let
  signal = pkgs.callPackage ../../pkgs/signal.nix { };
  busybox_utils = pkgs.stdenv.mkDerivation {
    name = "strings";
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      cp ${pkgs.busybox}/bin/strings $out/bin/strings
      cp ${pkgs.busybox}/bin/telnet $out/bin/telnet
    '';
  };
in
  {

    virtualisation.virtualbox.host.enable = true;
    users.extraGroups.vboxusers.members = [ "pn" ];

    services.yggdrasil = {
      enable = false;
      persistentKeys = true;
      config = {
        Peers = [
          "tcp://51.75.44.73:50001"
          "tcp://176.223.130.120:22632"
        ];
      };
    };

    imports = [
      ../base.nix
      ../pl.nix
      ../../modules/larbs.nix
      ../../modules/internet.nix
      ../../modules/dockd.nix
      ../../modules/trackpad.nix
      ../../modules/agetty.nix
    ];

    boot.plymouth.enable = true;
    # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    networking = {
      hostName = "x220";
      firewall.allowedTCPPorts = [
        6969 # qrcp
      ];

      networkmanager = {
        enable = true;
        wifi = {
          backend = "iwd";
          powersave = true;
        };
      };
    };

    nixpkgs.config.allowUnfree = true;

    nix.extraOptions = ''
      show-trace = true
    '';

    environment.variables = {
      ELECTRUMDIR="$\{XDG_DATA_HOME:-$HOME/.local/share}/electrum";
    };

    environment.binsh = "${pkgs.dash}/bin/dash";

    environment.systemPackages = with pkgs; [
      guvcview
      signal
      usbutils
      discord
    # Basic tools
    file ssh-ident busybox_utils

    # XORG perfs
    dunst

    # UI apps
    zathura sxiv pulsemixer
    lynx lf arandr wpa_supplicant_gui
    system-config-printer libreoffice
    abook

    # Audio/Video
    mpd mpc_cli mpv ffmpeg youtube-dl

    # CLIs
    gitAndTools.gh docker-compose xsel
    bc libnotify
    pamixer maim killall
    ueberzug chafa

    # Thinkpad utils
    acpi tpacpi-bat
  ];

  fonts.fonts = with pkgs; [
    liberation_ttf
    roboto-slab
  ];

  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gnome3";
    };
  };

  programs.browserpass.enable = true;
  programs.dockd.enable = true;


  virtualisation.docker.enable = true;
  systemd.services.docker.wantedBy = lib.mkForce [];

  services.udev.packages = [ pkgs.libu2f-host ];

  services.pcscd.enable = true;

  services.agetty = {
    defaultUser = "pn";
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.epson_201207w ];
  };
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.epkowa ];

  hardware.bluetooth.powerOnBoot = false;

  services.cron.enable = true;
  # services.fcron.enable = true;

  services.acpid.enable = true;

  # Battery
  services.tlp.enable = true;

  services.xserver = {
    videoDrivers = [ "intel" ];
    deviceSection = ''
      Option "DIR" "2"
      Option "TearFree" "true"
    '';
  };

  services.xserver.wacom = {
    enable = true;
  };

  users.users.pn.extraGroups = [ "docker" "scanner" "lp" ];

  security.pam.u2f = {
    enable = true;
    cue = true;
    interactive = true;
    #control = "required";
    #control = "requisite";
  };

}
