{pkgs, ...}: let
  switch-theme = pkgs.writeShellScriptBin "switch-theme" (builtins.readFile ./switch-theme.sh);
in {
  imports = [
    ./gnome-cast.nix
    ./appset-desktop.nix
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.excludePackages = [pkgs.xterm];

  environment.gnome.excludePackages = with pkgs; [
    epiphany
    baobab
    totem
    yelp
    file-roller
    seahorse
    gnome-clocks
    gnome-connections
    gnome-tour
    geary
  ];

  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        lockAll = true;
        settings = {
          "org/gnome/shell" = {
            favorite-apps = ["brave-browser.desktop" "thunderbird.desktop" "org.gnome.Nautilus.desktop"];
          };

          "org/gnome/desktop/interface" = {
            enable-hot-corners = false;
            show-battery-percentage = true;
          };

          "org/gnome/desktop/wm/keybindings" = {
            close = ["<Super>q"];
          };

          "org/gnome/settings-daemon/plugins/media-keys" = {
            custom-keybindings = [
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
            ];
          };

          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
            binding = "<Super>Return";
            command = "kgx";
            name = "GNOME Console";
          };

          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
            binding = "TaskPane";
            command = "switch-theme";
            name = "Switch Theme";
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
            binding = "Favorites";
            command = "switch-theme";
            name = "Switch Theme 2";
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
            binding = "<Super>F12";
            command = "switch-theme";
            name = "Switch Theme 2";
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
            binding = "<Alt>F12";
            command = "switch-theme";
            name = "Switch Theme 3";
          };
        };
      }
    ];
  };

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "pl";
    xkb.variant = "";
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  boot.plymouth.enable = true;

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  environment.systemPackages = with pkgs; [
    switch-theme
    libnotify
    gnome-boxes
    file-roller
    thunderbird
    gnomeExtensions.hibernate-status-button
    gnomeExtensions.caffeine
    #brave #specified in home.nix
    (pkgs.brave.overrideAttrs (oldAttrs: {
      installPhase =
        oldAttrs.installPhase
        + ''
           	substituteInPlace $out/share/applications/brave-browser.desktop \
          --replace %U "--profile-directory=Default %U"
        '';
    }))

    newsflash
    spotify
    fragments
    libreoffice
    signal-desktop
    vlc
    wl-clipboard
    mousai
    gnome-frog
    celluloid
  ];

  fonts.packages = with pkgs; [
    font-awesome
    liberation_ttf
  ];

  nixpkgs.config.allowUnfree = true;

  documentation.nixos.enable = false;
}
