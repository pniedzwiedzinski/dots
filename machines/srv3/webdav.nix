{ pkgs, ... }:
let
	port = "6060";
in
{
	services.nginx.virtualHosts."files.niedzwiedzinski.cyou" = {
		forceSSL = true;
		enableACME = true;

		locations."/" = {
			proxyPass = "http://localhost:${port}";
		};
	};

	services.webdav = {
		enable = true;
		configFile = "/etc/webdav.yaml";
		#settings = {
			#address = "0.0.0.0";
			#port = port;
			#scope = "/srv/files";
			#modify = true;
			#auth = true;
			#users = [
			#{
				#username = "patryk";
				#password = "test";
			#}
			#];
		#};
	};

}
