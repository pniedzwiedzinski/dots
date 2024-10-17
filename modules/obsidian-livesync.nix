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
			extraConfig = ''
				[couchdb]
				single_node=true
				max_document_size = 50000000
				
				[chttpd]
				require_valid_user = true
				max_http_request_size = 4294967296
				enable_cors = true
				
				[chttpd_auth]
				require_valid_user = true
				authentication_redirect = /_utils/session.html
				
				[httpd]
				WWW-Authenticate = Basic realm="couchdb"
				bind_address = 127.0.0.1
				
				[cors]
				origins = app://obsidian.md, capacitor://localhost, http://localhost
				credentials = true
				headers = accept, authorization, content-type, origin, referer
				methods = GET,PUT,POST,HEAD,DELETE
				max_age = 3600
			'';
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
					        add_header Access-Control-Allow-Origin "app://obsidian.md";
						add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
						add_header Access-Control-Allow-Headers "Content-Type, Authorization";
						add_header Access-Control-Allow-Credentials "true";
						add_header Access-Control-Max-Age 86400;
					'';
				};
			};
		};
	};
}
