{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.wordpress;
  eachSite = cfg.sites;
  user = "wordpress";
  webserver = config.services.${cfg.webserver};
  stateDir = hostName: "/var/lib/wordpress/${hostName}";

  pkg =
    hostName: cfg:
    pkgs.stdenv.mkDerivation rec {
      installPhase = ''
        mkdir -p $out
        cp -r * $out/

        # symlink the wordpress config
        ln -s ${wpConfig hostName cfg} $out/share/wordpress/wp-config.php
        # symlink uploads directory
        ln -s ${cfg.uploadsDir} $out/share/wordpress/wp-content/uploads
        ln -s ${cfg.fontsDir} $out/share/wordpress/wp-content/fonts

        # https://github.com/NixOS/nixpkgs/pull/53399
        #
        # Symlinking works for most plugins and themes, but Avada, for instance, fails to
        # understand the symlink, causing its file path stripping to fail. This results in
        # requests that look like: https://example.com/wp-content//nix/store/...plugin/path/some-file.js
        # Since hard linking directories is not allowed, copying is the next best thing.

        # copy additional plugin(s), theme(s) and language(s)
        ${concatStringsSep "\n" (
          mapAttrsToList (
            name: theme: "cp -r ${theme} $out/share/wordpress/wp-content/themes/${name}"
          ) cfg.themes
        )}
        ${concatStringsSep "\n" (
          mapAttrsToList (
            name: plugin: "cp -r ${plugin} $out/share/wordpress/wp-content/plugins/${name}"
          ) cfg.plugins
        )}
        ${concatMapStringsSep "\n" (
          language: "cp -r ${language} $out/share/wordpress/wp-content/languages/"
        ) cfg.languages}
      '';

      pname = "wordpress-${hostName}";
      src = cfg.package;
      version = src.version;
    };

  mergeConfig =
    cfg:
    {
      AUTOMATIC_UPDATER_DISABLED = true;
      DB_CHARSET = "utf8";

      DB_HOST = "${cfg.database.host}:${
        if cfg.database.socket != null then cfg.database.socket else toString cfg.database.port
      }";

      DB_NAME = cfg.database.name;

      # Always set DB_PASSWORD even when passwordFile is not set. This is the
      # default Wordpress behaviour.
      DB_PASSWORD =
        if (cfg.database.passwordFile != null) then { _file = cfg.database.passwordFile; } else "";

      DB_USER = cfg.database.user;
      # wordpress is installed onto a read-only file system
      DISALLOW_FILE_EDIT = true;
    }
    // cfg.settings;

  wpConfig =
    hostName: cfg:
    let
      conf_gen = c: mapAttrsToList (k: v: "define('${k}', ${mkPhpValue v});") cfg.mergedConfig;
    in
    pkgs.writeTextFile {
      checkPhase = "${pkgs.php}/bin/php --syntax-check $target";
      name = "wp-config-${hostName}.php";

      text = ''
        <?php
          $table_prefix  = '${cfg.database.tablePrefix}';

          require_once('${stateDir hostName}/secret-keys.php');

          ${cfg.extraConfig}
          ${concatStringsSep "\n" (conf_gen cfg.mergedConfig)}

          if ( !defined('ABSPATH') )
            define('ABSPATH', dirname(__FILE__) . '/');

          require_once(ABSPATH . 'wp-settings.php');
        ?>
      '';
    };

  mkPhpValue =
    v:
    let
      isHasAttr = s: isAttrs v && hasAttr s v;
      # "you're escaped" -> "'you\'re escaped'"
      # https://www.php.net/manual/en/language.types.string.php#language.types.string.syntax.single
      toPhpString = s: "'${escape [ "'" "\\" ] s}'";
    in
    if isString v then
      toPhpString v
    # NOTE: If any value contains a , (comma) this will not get escaped
    else if isList v && strings.isConvertibleWithToString v then
      toPhpString (concatMapStringsSep "," toString v)
    else if isInt v then
      toString v
    else if isBool v then
      boolToString v
    else if isHasAttr "_file" then
      "trim(file_get_contents(${toPhpString (toString v._file)}))"
    else if isHasAttr "_raw" then
      v._raw
    else
      abort "The Wordpress config value ${lib.generators.toPretty { } v} can not be encoded.";

  secretsVars = [
    "AUTH_KEY"
    "SECURE_AUTH_KEY"
    "LOGGED_IN_KEY"
    "NONCE_KEY"
    "AUTH_SALT"
    "SECURE_AUTH_SALT"
    "LOGGED_IN_SALT"
    "NONCE_SALT"
  ];
  secretsScript = hostStateDir: ''
    # The match in this line is not a typo, see https://github.com/NixOS/nixpkgs/pull/124839
    grep -q "LOOGGED_IN_KEY" "${hostStateDir}/secret-keys.php" && rm "${hostStateDir}/secret-keys.php"
    if ! test -e "${hostStateDir}/secret-keys.php"; then
      umask 0177
      echo "<?php" >> "${hostStateDir}/secret-keys.php"
      ${concatMapStringsSep "\n" (var: ''
        echo "define('${var}', '`tr -dc a-zA-Z0-9 </dev/urandom | head -c 64`');" >> "${hostStateDir}/secret-keys.php"
      '') secretsVars}
      echo "?>" >> "${hostStateDir}/secret-keys.php"
      chmod 440 "${hostStateDir}/secret-keys.php"
    fi
  '';

  siteOpts =
    {
      config,
      lib,
      name,
      ...
    }:
    {
      options = {
        package = mkPackageOption pkgs "wordpress" { };

        database = {
          createLocally = mkOption {
            default = true;
            description = "Create the database and database user locally.";
            type = types.bool;
          };

          host = mkOption {
            default = "localhost";
            description = "Database host address.";
            type = types.str;
          };

          name = mkOption {
            default = "wordpress";
            description = "Database name.";
            type = types.str;
          };

          passwordFile = mkOption {
            default = null;

            description = ''
              A file containing the password corresponding to
              {option}`database.user`.
            '';

            example = "/run/keys/wordpress-dbpassword";
            type = types.nullOr types.path;
          };

          port = mkOption {
            default = 3306;
            description = "Database host port.";
            type = types.port;
          };

          socket = mkOption {
            default = null;
            defaultText = literalExpression "/run/mysqld/mysqld.sock";
            description = "Path to the unix socket file to use for authentication.";
            type = types.nullOr types.path;
          };

          tablePrefix = mkOption {
            default = "wp_";

            description = ''
              The $table_prefix is the value placed in the front of your database tables.
              Change the value if you want to use something other than wp_ for your database
              prefix. Typically this is changed if you are installing multiple WordPress blogs
              in the same database.

              See <https://codex.wordpress.org/Editing_wp-config.php#table_prefix>.
            '';

            type = types.str;
          };

          user = mkOption {
            default = "wordpress";
            description = "Database user.";
            type = types.str;
          };
        };

        extraConfig = mkOption {
          default = "";

          description = ''
            Any additional text to be appended to the wp-config.php
            configuration file. This is a PHP script. For configuration
            settings, see <https://codex.wordpress.org/Editing_wp-config.php>.

            **Note**: Please pass structured settings via
            `services.wordpress.sites.${name}.settings` instead.
          '';

          example = ''
            @ini_set( 'log_errors', 'Off' );
            @ini_set( 'display_errors', 'On' );
          '';

          type = types.lines;
        };

        finalPackage = mkOption {
          default = pkg name config;
          defaultText = literalExpression "pkg name config";

          description = ''
            WordPress package with bundled configuration, plugins and themes.
          '';

          readOnly = true;
          type = types.package;
        };

        fontsDir = mkOption {
          default = "/var/lib/wordpress/${name}/fonts";

          description = ''
            This directory is used to download fonts from a remote location, e.g.
            to host google fonts locally.
          '';

          type = types.path;
        };

        languages = mkOption {
          default = [ ];

          description = ''
            List of path(s) to respective language(s) which are copied from the 'languages' directory.
          '';

          example = literalExpression ''
            [
              # Let's package the German language.
              # For other languages try to replace language and country code in the download URL with your desired one.
              # Reference https://translate.wordpress.org for available translations and
              # codes.
              (pkgs.stdenv.mkDerivation {
                name = "language-de";
                src = pkgs.fetchurl {
                  url = "https://de.wordpress.org/wordpress-''${pkgs.wordpress.version}-de_DE.tar.gz";
                  # Name is required to invalidate the hash when wordpress is updated
                  name = "wordpress-''${pkgs.wordpress.version}-language-de";
                  sha256 = "sha256-dlas0rXTSV4JAl8f/UyMbig57yURRYRhTMtJwF9g8h0=";
                };
                installPhase = "mkdir -p $out; cp -r ./wp-content/languages/* $out/";
              })
            ];
          '';

          type = types.listOf types.path;
        };

        mergedConfig = mkOption {
          default = mergeConfig config;

          defaultText = literalExpression ''
            {
              DISALLOW_FILE_EDIT = true;
              AUTOMATIC_UPDATER_DISABLED = true;
            }
          '';

          description = ''
            Read only representation of the final configuration.
          '';

          readOnly = true;
        };

        plugins = mkOption {
          default = { };

          description = ''
            Path(s) to respective plugin(s) which are copied from the 'plugins' directory.

            ::: {.note}
            These plugins need to be packaged before use, see example.
            :::
          '';

          example = literalExpression ''
            {
              inherit (pkgs.wordpressPackages.plugins) embed-pdf-viewer-plugin;
            }
          '';

          type =
            with types;
            coercedTo (listOf path) (
              l:
              warn "setting this option with a list is deprecated" listToAttrs (
                map (p: nameValuePair (p.name or (throw "${p} does not have a name")) p) l
              )
            ) (attrsOf path);
        };

        poolConfig = mkOption {
          default = {
            "pm" = "dynamic";
            "pm.max_children" = 32;
            "pm.max_requests" = 500;
            "pm.max_spare_servers" = 4;
            "pm.min_spare_servers" = 2;
            "pm.start_servers" = 2;
          };

          description = ''
            Options for the WordPress PHP pool. See the documentation on `php-fpm.conf`
            for details on configuration directives.
          '';

          type =
            with types;
            attrsOf (oneOf [
              str
              int
              bool
            ]);
        };

        settings = mkOption {
          default = { };

          description = ''
            Structural Wordpress configuration.
            Refer to <https://developer.wordpress.org/apis/wp-config-php>
            for details and supported values.
          '';

          example = literalExpression ''
            {
              WP_DEFAULT_THEME = "twentytwentytwo";
              WP_SITEURL = "https://example.org";
              WP_HOME = "https://example.org";
              WP_DEBUG = true;
              WP_DEBUG_DISPLAY = true;
              WPLANG = "de_DE";
              FORCE_SSL_ADMIN = true;
              AUTOMATIC_UPDATER_DISABLED = true;
            }
          '';

          type = types.attrsOf types.anything;
        };

        themes = mkOption {
          default = { inherit (pkgs.wordpressPackages.themes) twentytwentyfive; };
          defaultText = literalExpression "{ inherit (pkgs.wordpressPackages.themes) twentytwentyfive; }";

          description = ''
            Path(s) to respective theme(s) which are copied from the 'theme' directory.

            ::: {.note}
            These themes need to be packaged before use, see example.
            :::
          '';

          example = literalExpression ''
            {
              inherit (pkgs.wordpressPackages.themes) responsive-theme;
            }
          '';

          type =
            with types;
            coercedTo (listOf path) (
              l:
              warn "setting this option with a list is deprecated" listToAttrs (
                map (p: nameValuePair (p.name or (throw "${p} does not have a name")) p) l
              )
            ) (attrsOf path);
        };

        uploadsDir = mkOption {
          default = "/var/lib/wordpress/${name}/uploads";

          description = ''
            This directory is used for uploads of pictures. The directory passed here is automatically
            created and permissions adjusted as required.
          '';

          type = types.path;
        };

        virtualHost = mkOption {
          description = ''
            Apache configuration can be done by adapting {option}`services.httpd.virtualHosts`.
          '';

          example = literalExpression ''
            {
              adminAddr = "webmaster@example.org";
              forceSSL = true;
              enableACME = true;
            }
          '';

          type = types.submodule (import ../web-servers/apache-httpd/vhost-options.nix);
        };

      };

      config.virtualHost.hostName = mkDefault name;
    };
in
{
  # interface
  options = {
    services.wordpress = {

      sites = mkOption {
        default = { };
        description = "Specification of one or more WordPress sites to serve";
        type = types.attrsOf (types.submodule siteOpts);
      };

      webserver = mkOption {
        default = "httpd";

        description = ''
          Whether to use apache2 or nginx for virtual host management.

          Further nginx configuration can be done by adapting `services.nginx.virtualHosts.<name>`.
          See [](#opt-services.nginx.virtualHosts) for further information.

          Further apache2 configuration can be done by adapting `services.httpd.virtualHosts.<name>`.
          See [](#opt-services.httpd.virtualHosts) for further information.
        '';

        type = types.enum [
          "httpd"
          "nginx"
          "caddy"
        ];
      };

    };
  };

  # implementation
  config = mkIf (eachSite != { }) (mkMerge [
    {

      assertions =
        (mapAttrsToList (hostName: cfg: {
          assertion = cfg.database.createLocally -> cfg.database.user == user;
          message = ''services.wordpress.sites."${hostName}".database.user must be ${user} if the database is to be automatically provisioned'';
        }) eachSite)
        ++ (mapAttrsToList (hostName: cfg: {
          assertion = cfg.database.createLocally -> cfg.database.passwordFile == null;
          message = ''services.wordpress.sites."${hostName}".database.passwordFile cannot be specified if services.wordpress.sites."${hostName}".database.createLocally is set to true.'';
        }) eachSite);

      services.mysql = mkIf (any (v: v.database.createLocally) (attrValues eachSite)) {
        enable = true;
        package = mkDefault pkgs.mariadb;
        ensureDatabases = mapAttrsToList (hostName: cfg: cfg.database.name) eachSite;

        ensureUsers = mapAttrsToList (hostName: cfg: {
          ensurePermissions = {
            "${cfg.database.name}.*" = "ALL PRIVILEGES";
          };

          name = cfg.database.user;
        }) eachSite;
      };

      services.phpfpm.pools = mapAttrs' (
        hostName: cfg:
        (nameValuePair "wordpress-${hostName}" {
          inherit user;
          group = webserver.group;

          settings = {
            "listen.group" = webserver.group;
            "listen.owner" = webserver.user;
          }
          // cfg.poolConfig;
        })
      ) eachSite;

    }

    (mkIf (cfg.webserver == "httpd") {
      services.httpd = {
        enable = true;
        extraModules = [ "proxy_fcgi" ];

        virtualHosts = mapAttrs (
          hostName: cfg:
          mkMerge [
            cfg.virtualHost
            {
              documentRoot = mkForce "${cfg.finalPackage}/share/wordpress";

              extraConfig = ''
                <Directory "${cfg.finalPackage}/share/wordpress">
                  <FilesMatch "\.php$">
                    <If "-f %{REQUEST_FILENAME}">
                      SetHandler "proxy:unix:${
                        config.services.phpfpm.pools."wordpress-${hostName}".socket
                      }|fcgi://localhost/"
                    </If>
                  </FilesMatch>

                  # standard wordpress .htaccess contents
                  <IfModule mod_rewrite.c>
                    RewriteEngine On
                    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
                    RewriteBase /
                    RewriteRule ^index\.php$ - [L]
                    RewriteCond %{REQUEST_FILENAME} !-f
                    RewriteCond %{REQUEST_FILENAME} !-d
                    RewriteRule . /index.php [L]
                  </IfModule>

                  DirectoryIndex index.php
                  Require all granted
                  Options +FollowSymLinks -Indexes
                </Directory>

                # https://wordpress.org/support/article/hardening-wordpress/#securing-wp-config-php
                <Files wp-config.php>
                  Require all denied
                </Files>
              '';
            }
          ]
        ) eachSite;
      };
    })

    {
      systemd.services = mkMerge [
        (mapAttrs' (
          hostName: cfg:
          (nameValuePair "wordpress-init-${hostName}" {
            after = optional cfg.database.createLocally "mysql.service";
            before = [ "phpfpm-wordpress-${hostName}.service" ];
            script = secretsScript (stateDir hostName);

            serviceConfig = {
              Group = webserver.group;
              Type = "oneshot";
              User = user;
            };

            wantedBy = [ "multi-user.target" ];
          })
        ) eachSite)

        (optionalAttrs (any (v: v.database.createLocally) (attrValues eachSite)) {
          httpd.after = [ "mysql.service" ];
        })
      ];

      systemd.tmpfiles.rules = flatten (
        mapAttrsToList (hostName: cfg: [
          "d '${stateDir hostName}' 0750 ${user} ${webserver.group} - -"
          "d '${cfg.uploadsDir}' 0750 ${user} ${webserver.group} - -"
          "Z '${cfg.uploadsDir}' 0750 ${user} ${webserver.group} - -"
          "d '${cfg.fontsDir}' 0750 ${user} ${webserver.group} - -"
          "Z '${cfg.fontsDir}' 0750 ${user} ${webserver.group} - -"
        ]) eachSite
      );

      users.users.${user} = {
        group = webserver.group;
        isSystemUser = true;
      };
    }

    (mkIf (cfg.webserver == "nginx") {
      services.nginx = {
        enable = true;

        virtualHosts = mapAttrs (hostName: cfg: {
          extraConfig = ''
            index index.php;
          '';

          locations = {
            "/" = {
              extraConfig = ''
                try_files $uri $uri/ /index.php$is_args$args;
              '';

              priority = 200;
            };

            "~ /\\." = {
              extraConfig = "deny all;";
              priority = 800;
            };

            "~ \\.php$" = {
              extraConfig = ''
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass unix:${config.services.phpfpm.pools."wordpress-${hostName}".socket};
                fastcgi_index index.php;
                include "${config.services.nginx.package}/conf/fastcgi.conf";
                fastcgi_param PATH_INFO $fastcgi_path_info;
                fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
                # Mitigate https://httpoxy.org/ vulnerabilities
                fastcgi_param HTTP_PROXY "";
                fastcgi_intercept_errors off;
                fastcgi_buffer_size 16k;
                fastcgi_buffers 4 16k;
                fastcgi_connect_timeout 300;
                fastcgi_send_timeout 300;
                fastcgi_read_timeout 300;
              '';

              priority = 500;
            };

            "~* /(?:uploads|files)/.*\\.php$" = {
              extraConfig = "deny all;";
              priority = 900;
            };

            "~* \\.(js|css|png|jpg|jpeg|gif|ico)$" = {
              extraConfig = ''
                expires max;
                log_not_found off;
              '';

              priority = 1000;
            };
          };

          root = "${cfg.finalPackage}/share/wordpress";
          serverName = mkDefault hostName;
        }) eachSite;
      };
    })

    (mkIf (cfg.webserver == "caddy") {
      services.caddy = {
        enable = true;

        virtualHosts = mapAttrs' (
          hostName: cfg:
          (nameValuePair hostName {
            extraConfig = ''
              root    * /${cfg.finalPackage}/share/wordpress
              file_server

              php_fastcgi unix/${config.services.phpfpm.pools."wordpress-${hostName}".socket}

              @uploads {
                path_regexp path /uploads\/(.*)\.php
              }
              rewrite @uploads /

              @wp-admin {
                path  not ^\/wp-admin/*
              }
              rewrite @wp-admin {path}/index.php?{query}
            '';
          })
        ) eachSite;
      };
    })

  ]);
}
