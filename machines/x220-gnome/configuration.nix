{ config, pkgs, ... }:

{
	imports =
		[ # Include the results of the hardware scan.
		../base.nix
		./gnome.nix
		./pass.nix
		./hardware-configuration.nix
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
# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.pn = {
		isNormalUser = true;
		description = "Patryk Niedzwiedzinski";
		extraGroups = [ "networkmanager" "wheel" ];
		packages = with pkgs; [
			gnomeExtensions.gsconnect
		];
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
	system.stateVersion = "24.05"; # Did you read the comment?

}
