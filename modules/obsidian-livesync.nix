{ config, lib, ... }:
let
	cfg = config.services.obsidian-livesync;
in
{
	options = {
		services.obsidian-livesync = {
			enable = lib.mkEnableOption "Obsidian Livesync Host";

			domain = lib.mkOption {
			    type = lib.types.str;
			    description = "This option is required and must be set by the user.";
			    default = lib.mkDefault null;
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

	config = lib.mkIf cfg.enable (
	lib.mkIf (cfg.domain == null)
	(throw "You must set `services.obsidian-livesync.domain` to use this service")
	{
		services.couchdb = {
			enable = true;
			adminPass = cfg.couchdb.adminPass;
			databaseDir = cfg.couchdb.databaseDir;
		};

		services.nginx = {
			enable = true;
			virtualHost.${cfg.domain} = {
				enableACME = true;
				forceSSL = true;
				locations."/" = {
					proxyPass = "http://127.0.0.1:${config.services.couchdb.port}";
				        proxySetHeader = {
						  Host = "$host";
						  X-Real-IP = "$remote_addr";
						  X-Forwarded-For = "$proxy_add_x_forwarded_for";
						  X-Forwarded-Proto = "$scheme";
					};
				};
			};
		};
	});
}
