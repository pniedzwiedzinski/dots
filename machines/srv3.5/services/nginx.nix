{pkgs, ...}: let
  crs = pkgs.callPackage ./coreruleset.nix {};
  www = "/srv/www";
in {
  services.nginx = {
    enable = true;

    additionalModules = with pkgs.nginxModules; [modsecurity];
    appendHttpConfig = ''
      modsecurity on;
      # modsecurity_rules '
      #   SecRuleEngine On
      #   Include ${crs}/crs-setup.conf;
      #   Include ${crs}/rules/*.conf;
      # ';
      charset utf-8;
      source_charset utf-8;
    '';
    commonHttpConfig = ''
      log_format main '$http_x_forwarded_for - $remote_user [$time_local] "$host" "$request" '
              '$status $body_bytes_sent "$http_referer" '
              '"$http_user_agent" $request_time';
    '';

    virtualHosts."git.niedzwiedzinski.cyou".extraConfig = pkgs.lib.mkAfter ''
      if ($http_user_agent ~* "(DotBot|AdsBot-Google|Amazonbot|anthropic-ai|Applebot|Applebot-Extended|AwarioRssBot|AwarioSmartBot|Bytespider|CCBot|ChatGPT-User|ClaudeBot|Claude-Web|cohere-ai|DataForSeoBot|Diffbot|FacebookBot|FriendlyCrawler|Google-Extended|GoogleOther|GPTBot|img2dataset|ImagesiftBot|magpie-crawler|Meltwater|omgili|omgilibot|peer39_crawler|peer39_crawler/1.0|PerplexityBot|PiplBot|scoop.it|Seekr|YouBot)"){
        return 403;
      }
    '';

    virtualHosts = {
      "srv3.niedzwiedzinski.cyou" = let
        modsec_config = builtins.toFile "modsecurity_rules.conf" ''
          SecRuleEngine On
          SecRule ARGS:testparam "@contains test" "id:1234,deny,status:403"
        '';
      in {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
               location ~ /*.md {
          types { } default_type "text/markdown; charset=utf-8";
               }
               modsecurity_rules_file ${modsec_config};
        '';
        root = "${www}/srv3.niedzwiedzinski.cyou";
      };
      "pics.srv3.niedzwiedzinski.cyou" = {
        enableACME = true;
        forceSSL = true;
        root = "${www}/pics.niedzwiedzinski.cyou";
      };
      "pics.niedzwiedzinski.cyou" = {
        enableACME = true;
        forceSSL = true;
        root = "${www}/pics.niedzwiedzinski.cyou";
      };
      "tmp.niedzwiedzinski.cyou" = {
        enableACME = true;
        addSSL = true;
        root = "${www}/tmp.niedzwiedzinski.cyou";
        extraConfig = ''
          modsecurity_rules '
            SecRuleEngine On
            SecRule ARGS:testparam "@contains test" "id:1234,deny,status:403"
            Include ${crs}/crs-setup.conf
            Include ${crs}/all-rules.conf
          ';
        '';
      };
      "niedzwiedzinski.cyou" = {
        enableACME = true;
        forceSSL = true;
        root = "${www}/niedzwiedzinski.cyou";
      };
      "zhr.niedzwiedzinski.cyou" = {
        enableACME = true;
        forceSSL = true;
        root = "${www}/zhr.niedzwiedzinski.cyou";
        extraConfig = ''
          location /rozkazy/ {
            autoindex on;
          }
        '';
        locations."/harcdzielnia/" = {
          return = "301 https://harcdzielnia.niedzwiedzinski.cyou";
        };
      };
      "help.niedzwiedzinski.cyou" = {
        enableACME = true;
        forceSSL = true;
        root = "${www}/niedzwiedzinski.cyou/help";
      };
      "fresh.niedzwiedzinski.cyou" = {
        enableACME = true;
        forceSSL = true;
      };
    };
  };

  security.acme.defaults.email = "pniedzwiedzinski19@gmail.com";
  security.acme.acceptTerms = true;
  networking.firewall.allowedTCPPorts = [80 443];
}
