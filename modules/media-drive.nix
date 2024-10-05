# Configuration for my "Media" usb hard drive
{ pkgs, ... }:
let
	mediasync = pkgs.writeShellScriptBin "mediasync" (builtins.readFile ./mediasync);
in
{
	fileSystems."/media" = {
		device = "/dev/disk/by-id/wwn-0x50014ee25fca2cb8-part1";
		options = [ "nosuid" "nodev" "nofail" "noauto" "x-gvfs-show" "x-gvfs-name=Media" ];
	};

	environment.systemPackages = [ mediasync ];
}
