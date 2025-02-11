{ config, lib, ... }:
let
cfg = config.services.srv3-webdav;
in
{

	options = {
		services.srv3-webdav = {
			enable = lib.mkEnableOption "WebDav server";

			domain = lib.mkOption {
				type = lib.types.str;
				description = "Where webdav server should live";
			};

			port = lib.mkOption {
				type = lib.types.number;
				default = 6060;
# FIX: Hardening reverse proxy
				description = "Internal port on which webdav server will run";
			};
			
			configFile = lib.mkOption {
				type = lib.types.path;
				default = "/etc/webdav.yaml";
				description = "WebDav server config file";
			};
		};

	};
	config = lib.mkIf cfg.enable {
		services.nginx.virtualHosts.${cfg.domain} = {
			forceSSL = true;
			enableACME = true;

			locations."/" = {
				proxyPass = "http://localhost:${toString cfg.port}";
			};
		};

		services.webdav = {
			enable = true;
			configFile = cfg.configFile;
		};
	};

}
