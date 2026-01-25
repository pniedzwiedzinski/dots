{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ../base.nix
    ./modules/media-drive.nix
    ./modules/clean.nix
    ./modules/appset-dev.nix
    ./modules/pass.nix
    ./modules/gnome.nix
    ./modules/hyprland.nix
    ./modules/keyd.nix

    ./disko-config.nix
    ./virt.nix

    ./xerox-printer.nix
  ];

  # Power management
  services.power-profiles-daemon.enable = true;
  services.tlp = {
    enable = false;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 50;

      #Optional helps save long term battery health
      START_CHARGE_THRESH_BAT0 = 60; # 40 and below it starts to charge
      STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
    };
  };

  disko.devices.disk.main.device = "/dev/nvme0n1";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "t14";

  services.tailscale.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ALL = "en_US.UTF-8";
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "en_IE.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };
  programs.nano.enable = false;
  programs.git.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.optimise.automatic = true;
  nix.settings.trusted-users = ["@wheel"];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.login1.suspend" ||
          action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
          action.id == "org.freedesktop.login1.suspend-ignore-inhibit") {
        if (subject.isInGroup("users") || subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      }
    });
  '';

  services.locate = {
    enable = true;
    package = pkgs.plocate;
  };

  services.printing.drivers = with pkgs; [
    cnijfilter2
    fxlinuxprint
  ];
  services.printing.logLevel = "debug";
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [pkgs.sane-airscan];
  services.udev.packages = [pkgs.sane-airscan];
  hardware.sane.disabledDefaultBackends = ["escl"];

  # programs.nix-ld.dev = {
  # 	enable = true;
  # 	libraries = [
  # 		pkgs.libgcc.lib
  # 	];
  # };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  environment.systemPackages = with pkgs; [
    obsidian
    poppler-utils # pdfunite
  ];

  boot.binfmt.emulatedSystems = [
    "i686-linux"
    "aarch64-linux"
  ];
  nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;

  users.users.pn = {
    isNormalUser = true;
    description = "Patryk Niedźwiedziński";
    extraGroups = [
      "lp"
      "scanner"
      "networkmanager"
      "wheel"
    ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
