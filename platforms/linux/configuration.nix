# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
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
  nix.useSandbox = true;

  # Add NUR
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  # NUR cachable
  #nixpkgs.config.packageOverrides = pkgs: {
  #  nur = import (builtins.fetchTarball {
  #    url = "https://github.com/nix-community/NUR/archive/02ba8936dec5010545a97bba41a52a03078a2644.tar.gz";
  #    sha256 = "0ix86b53l9hv5minkjhbydi82n6dc4s700k8pwlm0z5fwlgvhy09";
  #  }) {
  #    inherit pkgs;
  #  };
  #};


  imports =
    [ # Include the results of the hardware scan.
      # <home-manager>/nixos
      ../../modules/dockd.nix
      ../../modules/trackpad.nix
      ../../modules/agetty.nix
      ../../modules/slock.nix
      ../../hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.plymouth.enable = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.extraModulePackages = with pkgs.linuxPackages; [
    v4l2loopback
    acpi_call
  ];

  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 video_nr=9 card_label="obs"
  '';

  boot.cleanTmpDir = true;

  fileSystems = {
    "/home" = {
      device = "/dev/disk/by-label/home";
      fsType = "ext4";
    };
    "/nix" = {
      device = "/dev/disk/by-label/nix";
      fsType = "ext4";
    };
    "/var/lib/docker" = {
      device = "/dev/disk/by-label/docker";
      fsType = "ext4";
    };
    # "/media" = {
    #   device = "/dev/disk/by-label/media";
    #   fsType = "ext4";
    # };
    # "/backup" = {
    #   device = "/dev/disk/by-label/backup";
    #   fsType = "ext4";
    # };
    "/mnt/qnap" = {
      device = "//192.168.1.119/Patryk";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,vers=1.0";

      in ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
    };
  };

  networking = {
    networkmanager = {
     enable = true;
     wifi.backend = "iwd";
    };

    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  networking.hostName = "nixos"; # Define your hostname.
  networking.extraHosts = "${ pkgs.stdenv.lib.readFile "${pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/StevenBlack/hosts/5a5016ab5bf0166e004147cb49ccd0114ed29b72/alternates/fakenews-gambling-porn/hosts";
    sha256 = "1c60fyzxz89bic6ymcvb8fcanyxpzr8v2z5vixxr79d8mj0vjswm";
  }}"}";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  #networking.interfaces.enp0s25.useDHCP = true;
  #networking.interfaces.wlp3s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  nixpkgs.config = {
    allowUnfree = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Basic tools
    stdenv wget vim curl htop dnsutils zip unzip
    zsh neovim ripgrep jq groff file pinentry_gnome
    ssh-ident busybox_utils

    # XORG perfs
    xorg.xorgserver xorg.xf86inputevdev xorg.xf86inputsynaptics xorg.xf86inputlibinput
    xorg.xf86videointel
    noto-fonts-extra dunst xclip
    xwallpaper xdotool

    # UI apps
    zathura brave sxiv pulsemixer
    lynx lf nur.repos.pn.st arandr wpa_supplicant_gui
    system-config-printer libreoffice
    vscodium abook

    # Audio/Video
    mpd mpc_cli mpv ffmpeg youtube-dl

    # CLIs
    lm_sensors
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

  # Pure conf
  environment.etc = {
    "zsh/zshenv".text = ''
      export ZDOTDIR=$HOME/.config/zsh
    '';
  };

  environment.variables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gnome3";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    histFile = "$XDG_DATA_HOME/zsh/history";

    syntaxHighlighting.enable = true;
  };

  programs.vim.defaultEditor = true;
  programs.browserpass.enable = true;
  programs.dockd.enable = true;
  programs.adb.enable = true;

  virtualisation.docker.enable = true;
  # virtualisation.anbox.enable = true;

  # List services that you want to enable:

  # services.udev.packages = [
  #   pkgs.android-udev-rules
  # ];
  services.udev.packages = [ pkgs.libu2f-host ];

  services.pcscd.enable = true;

  services.agetty = {
    defaultUser = "pn";
    # autologinUser = "pn";
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.epson_201207w ];
  };

  services.cron.enable = true;
  # services.fcron.enable = true;

  services.acpid.enable = true;

  # Battery
  services.tlp.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.sane.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true;
  services.xserver.layout = "pl";
  # services.xserver.xkbOptions = "eurosign:e";
  services.xserver.deviceSection = ''
    Option "TearFree" "true"
  '';
  services.xserver.wacom = {
    enable = true;
  };

  # Enable touchpad support.
  services.xserver.libinput = {
    enable = true;
    accelSpeed = "0.8";
  };

  # Enable the KDE Desktop Environment.
  #services.xserver.displayManager.sddm.enable = true;
  #services.xserver.desktopManager.plasma5 = {
  #  enable = true;
  #};

  # i3
  #services.xserver.desktopManager.xterm.enable = false;
  #services.xserver.displayManager.defaultSession = "none+i3";
  #services.xserver.windowManager.i3 = {
  #  enable = true;
  #  package = pkgs.i3-gaps;
  #  extraPackages = with pkgs; [
  #    i3status
  #    i3lock
  #    i3blocks
  #  ];
  #};

  # XFCE + i3
  #services.xserver.displayManager.defaultSession = "xfce+i3";
  #services.xserver.desktopManager = {
  #  xterm.enable = false;
  #  xfce = {
  #    enable = true;
  #    noDesktop = true;
  #    enableXfwm = false;
  #  };
  #};
  #services.xserver.windowManager.i3 = {
  #  enable = true;
  #  package = pkgs.i3-gaps;
  #  extraPackages = with pkgs; [
  #    i3status
  #    i3lock
  #    i3blocks
  #  ];
  #};


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pn = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "docker" "adbusers" "scanner" "lp" ]; # Enable ‘sudo’ for the user.
  };

  users.defaultUserShell = "/run/current-system/sw/bin/zsh";
  security.sudo.wheelNeedsPassword = false;

  security.pam.u2f = {
    enable = true;
    cue = true;
    interactive = true;
    #control = "required";
    #control = "requisite";
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
