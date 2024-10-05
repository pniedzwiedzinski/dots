{ config, pkgs, ... }:

{
	imports =
		[ # Include the results of the hardware scan.
		../base.nix
		../../modules/gnome.nix
		../x220-gnome/pass.nix
		./hardware-configuration.nix
		../x220-gnome/pn.nix
		];

# Enable networking
	networking.networkmanager.enable = true;

# Set your time zone.
	time.timeZone = "Europe/Warsaw";

# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";

	i18n.extraLocaleSettings = {
		LC_ALL = "en_US.UTF-8";
		LC_ADDRESS = "en_US.UTF-8";
		LC_IDENTIFICATION = "en_US.UTF-8";
		LC_MEASUREMENT = "en_US.UTF-8";
		LC_MONETARY = "en_US.UTF-8";
		LC_NAME = "en_US.UTF-8";
		LC_NUMERIC = "en_US.UTF-8";
		LC_PAPER = "en_US.UTF-8";
		LC_TELEPHONE = "en_US.UTF-8";
		LC_TIME = "en_US.UTF-8";
	};

	programs.vim.defaultEditor = true;
	programs.nano.enable = false;
	programs.git.enable = true;

# Allow unfree packages
	nixpkgs.config.allowUnfree = true;
	nix.settings.experimental-features = [ "flakes" "nix-command" ];

# List packages installed in system profile. To search, run:
# $ nix search wget
	environment.systemPackages = with pkgs; [
#  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
#  wget
	];

	fileSystems."/persist".neededForBoot = true;
	#environment.persistence."/persistent" = {
    #enable = true;  # NB: Defaults to true, not needed
    #hideMounts = true;
    #directories = [
      #"/var/log"
      #"/var/lib/bluetooth"
      #"/var/lib/nixos"
      #"/var/lib/systemd/coredump"
      #"/etc/NetworkManager/system-connections"
      #{ directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
    #];
    #files = [
      #"/etc/machine-id"
	#"/etc/shadow"
      #{ file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
    #];
    #users.pn = {
      #directories = [
        #"Downloads"
        #"Music"
        #"Pictures"
        #"Documents"
        #"Videos"
        #"VirtualBox VMs"
        #{ directory = ".gnupg"; mode = "0700"; }
        #{ directory = ".ssh"; mode = "0700"; }
        #{ directory = ".local/share/keyrings"; mode = "0700"; }
        #".local/share/direnv"
      #];
    #};
  #};

# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
# programs.gnupg.agent = {
#   enable = true;
#   enableSSHSupport = true;
# };


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

}
