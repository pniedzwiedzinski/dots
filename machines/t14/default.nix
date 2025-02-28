{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    # ./yggdrasil.nix
    ../base.nix
    ../../modules/media-drive.nix
    ../../modules/tailscale.nix
    ../../modules/clean.nix
    ../x220-gnome/pass.nix
    ./hardware-configuration.nix
    ../x220-gnome/pn.nix
    ../../modules/appset-dev.nix
  ];

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "t14";

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

  programs.vim.defaultEditor = true;
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

  services.locate = {
    enable = true;
    package = pkgs.plocate;
  };

  services.printing.drivers = with pkgs; [cnijfilter2];
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
  ];

  boot.binfmt.emulatedSystems = ["i686-linux" "aarch64-linux"];
  nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;

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
