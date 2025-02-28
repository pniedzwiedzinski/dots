{ pkgs, ... }:
{
	environment.systemPackages = with pkgs; [
	  tuba
          yt-dlp
	];

}
