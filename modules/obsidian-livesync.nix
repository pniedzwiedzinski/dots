{ config, lib, ... }:
let
	cfg = config.services.obsidian-livesync;
	couchdb-port = config.services.couchdb.port or 5984;
in
{
	options = {
		services.obsidian-livesync = {
			enable = lib.mkEnableOption "Obsidian Livesync Host";

			domain = lib.mkOption {
			    type = lib.types.str;
			    description = "This option is required and must be set by the user.";
			};

			couchdb.adminPass = lib.mkOption {
				description = "Couchdb password.";
				default = "";
				type = lib.types.str;
			};

			couchdb.databaseDir = lib.mkOption {
				description = "Specifies location of CouchDB database files (*.couch named). This location should be writable and readable for the user the CouchDB service runs as (couchdb by default).";
				default = "/srv/couchdb";
				type = lib.types.path;
			};
		};
	};

	config = lib.mkIf cfg.enable {
		services.couchdb = {
			enable = true;
			adminPass = cfg.couchdb.adminPass;
			databaseDir = cfg.couchdb.databaseDir;
		};

		services.nginx = {
			enable = true;
			virtualHosts.${cfg.domain} = {
#				enableACME = true;
#				forceSSL = true;
				locations."/" = {
					proxyPass = "http://127.0.0.1:${toString couchdb-port}";
			        	extraConfig = ''
					 	proxy_set_header Host "$host";
					 	proxy_set_header X-Real-IP "$remote_addr";
					 	proxy_set_header X-Forwarded-For "$proxy_add_x_forwarded_for";
					 	proxy_set_header X-Forwarded-Proto "$scheme";
					'';
				};
			};
		};
	};
}
