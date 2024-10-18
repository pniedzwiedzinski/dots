{ config, lib, pkgs, ... }:
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

			adminsFile = lib.mkOption {
				type = lib.types.path;
				description = "File with authentication data";
				example = ''
				[admins]
				admin = strongPassword
				'';
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
			configFile = cfg.adminsFile;
			extraConfig = ''
				[couchdb]
				database_dir = ${cfg.couchdb.databaseDir}
				single_node=true
				max_document_size = 50000000
				uri_file = ${config.services.couchdb.uriFile}
				view_index_dir = ${config.services.couchdb.viewIndexDir}
				
				[log]
				file = ${config.services.couchdb.logFile}

				[chttpd]
				require_valid_user = true
				max_http_request_size = 4294967296
				enable_cors = true
				port = ${toString config.services.couchdb.port}
				bind_address = ${config.services.couchdb.bindAddress}
				
				[chttpd_auth]
				require_valid_user = true
				authentication_redirect = /_utils/session.html
				
				[httpd]
				WWW-Authenticate = Basic realm="couchdb"
				enable_cors = true
				bind_address = 127.0.0.1

				[cors]
				#origins = app://obsidian.md,capacitor://localhost,http://localhost
				#credentials = true
			'';
		};

		services.nginx = {
			enable = true;
			virtualHosts.${cfg.domain} = {
				enableACME = true;
				forceSSL = true;
				locations."/" = {
					proxyPass = "http://127.0.0.1:${toString couchdb-port}";
			        	extraConfig = ''
						proxy_set_header Host "$host";
						proxy_set_header X-Real-IP "$remote_addr";
						proxy_set_header X-Forwarded-For "$proxy_add_x_forwarded_for";
						proxy_set_header X-Forwarded-Proto "$scheme";
						add_header Access-Control-Allow-Origin "$http_origin" always;
						add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
						add_header Access-Control-Allow-Headers "Content-Type, Authorization" always;
						add_header Access-Control-Allow-Credentials "true" always;
						add_header Access-Control-Max-Age 86400 always;

						if ($request_method = OPTIONS) {
							return 204;
						}
					'';
				};
			};
		};
	};
}
