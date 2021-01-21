{ pkgs, lib, ... }:

let
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
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    networking = {
      hostName = "x220";

      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };
    };

    nixpkgs.config.allowUnfree = true;


    environment.systemPackages = with pkgs; [
      discord
    # Basic tools
    groff file ssh-ident busybox_utils

    # XORG perfs
    dunst

    # UI apps
    zathura sxiv pulsemixer
    lynx lf arandr wpa_supplicant_gui
    system-config-printer libreoffice
    vscodium abook

    # Audio/Video
    mpd mpc_cli mpv ffmpeg youtube-dl

    # CLIs
    gitAndTools.gh docker-compose xsel
    bc libnotify
    pamixer maim killall
    quickserve ueberzug chafa

    # Thinkpad utils
    nur.repos.pn.dockd acpi tpacpi-bat

    wineStaging

  ];

  fonts.fonts = with pkgs; [
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

  virtualisation.anbox.enable = true;
  programs.adb.enable = true;

  virtualisation.docker.enable = true;
  # systemd.services.docker.enable = false;

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