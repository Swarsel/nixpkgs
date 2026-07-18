{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let

  inherit (lib)
    mkDefault
    mkEnableOption
    mkPackageOption
    mkRenamedOptionModule
    mkForce
    mkIf
    mkMerge
    mkOption
    types
    ;
  inherit (lib)
    literalExpression
    mapAttrs
    optionalString
    optionals
    versionAtLeast
    ;

  cfg = config.services.zabbixWeb;
  opt = options.services.zabbixWeb;
  fpm = config.services.phpfpm.pools.zabbix;

  user = "zabbix";
  group = "zabbix";
  stateDir = "/var/lib/zabbix";

  zabbixConfig = pkgs.writeText "zabbix.conf.php" ''
    <?php
    // Zabbix GUI configuration file.
    global $DB;
    $DB['TYPE'] = '${
      {
        mysql = "MYSQL";
        oracle = "ORACLE";
        pgsql = "POSTGRESQL";
      }
      .${cfg.database.type}
    }';
    $DB['SERVER'] = '${cfg.database.host}';
    $DB['PORT'] = '${toString cfg.database.port}';
    $DB['DATABASE'] = '${cfg.database.name}';
    $DB['USER'] = '${cfg.database.user}';
    # NOTE: file_get_contents adds newline at the end of returned string
    $DB['PASSWORD'] = ${
      if cfg.database.passwordFile != null then
        "trim(file_get_contents('${cfg.database.passwordFile}'), \"\\r\\n\")"
      else
        "''"
    };
    // Schema name. Used for IBM DB2 and PostgreSQL.
    $DB['SCHEMA'] = ''';
    $ZBX_SERVER = '${cfg.server.address}';
    $ZBX_SERVER_PORT = '${toString cfg.server.port}';
    $ZBX_SERVER_NAME = ''';
    $IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;

    ${cfg.extraConfig}
  '';
in
{
  imports = [
    (mkRenamedOptionModule
      [
        "services"
        "zabbixWeb"
        "virtualHost"
      ]
      [
        "services"
        "zabbixWeb"
        "httpd"
        "virtualHost"
      ]
    )
  ];

  # interface

  options.services = {
    zabbixWeb = {
      enable = mkEnableOption "the Zabbix web interface";

      package = mkPackageOption pkgs [
        "zabbix"
        "web"
      ] { };

      database = {
        host = mkOption {
          default = "";
          description = "Database host address.";
          type = types.str;
        };

        name = mkOption {
          default = "zabbix";
          description = "Database name.";
          type = types.str;
        };

        passwordFile = mkOption {
          default = null;

          description = ''
            A file containing the password corresponding to
            {option}`database.user`.
          '';

          example = "/run/keys/zabbix-dbpassword";
          type = types.nullOr types.path;
        };

        port = mkOption {
          default =
            if cfg.database.type == "mysql" then
              config.services.mysql.port
            else if cfg.database.type == "pgsql" then
              config.services.postgresql.settings.port
            else
              1521;

          defaultText = literalExpression ''
            if config.${opt.database.type} == "mysql" then config.${options.services.mysql.port}
            else if config.${opt.database.type} == "pgsql" then config.services.postgresql.settings.port
            else 1521
          '';

          description = "Database host port.";
          type = types.port;
        };

        socket = mkOption {
          default = null;
          description = "Path to the unix socket file to use for authentication.";
          example = "/run/postgresql";
          type = types.nullOr types.path;
        };

        type = mkOption {
          default = "pgsql";
          description = "Database engine to use.";
          example = "mysql";

          type = types.enum [
            "mysql"
            "pgsql"
            "oracle"
          ];
        };

        user = mkOption {
          default = "zabbix";
          description = "Database user.";
          type = types.str;
        };
      };

      extraConfig = mkOption {
        default = "";

        description = ''
          Additional configuration to be copied verbatim into {file}`zabbix.conf.php`.
        '';

        type = types.lines;
      };

      frontend = mkOption {
        default = "httpd";
        description = "Frontend server to use.";
        example = "nginx";

        type = types.enum [
          "nginx"
          "httpd"
        ];
      };

      hostname = mkOption {
        default = "zabbix.local";
        description = "Hostname for either nginx or httpd.";
        type = types.str;
      };

      httpd.virtualHost = mkOption {
        default = { };

        description = ''
          Apache configuration can be done by adapting `services.httpd.virtualHosts.<name>`.
          See [](#opt-services.httpd.virtualHosts) for further information.
        '';

        example = literalExpression ''
          {
            hostName = "zabbix.example.org";
            adminAddr = "webmaster@example.org";
            forceSSL = true;
            enableACME = true;
          }
        '';

        type = types.submodule (import ../web-servers/apache-httpd/vhost-options.nix);
      };

      nginx.virtualHost = mkOption {
        default = { };

        description = ''
          Nginx configuration can be done by adapting `services.nginx.virtualHosts.<name>`.
          See [](#opt-services.nginx.virtualHosts) for further information.
        '';

        example = literalExpression ''
          {
            forceSSL = true;
            sslCertificateKey = "/etc/ssl/zabbix.key";
            sslCertificate = "/etc/ssl/zabbix.crt";
          }
        '';

        type = types.submodule (import ../web-servers/nginx/vhost-options.nix);
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
          Options for the Zabbix PHP pool. See the documentation on `php-fpm.conf` for details on configuration directives.
        '';

        type =
          with types;
          attrsOf (oneOf [
            str
            int
            bool
          ]);
      };

      server = {
        address = mkOption {
          default = "localhost";
          description = "The IP address or hostname of the Zabbix server to connect to.";
          type = types.str;
        };

        port = mkOption {
          default = 10051;
          description = "The port of the Zabbix server to connect to.";
          type = types.port;
        };
      };
    };
  };

  # implementation

  config = mkIf cfg.enable {

    services.httpd = mkIf (cfg.frontend == "httpd") {
      enable = true;
      adminAddr = mkDefault cfg.httpd.virtualHost.adminAddr;
      extraModules = [ "proxy_fcgi" ];

      virtualHosts.${cfg.hostname} = mkMerge [
        cfg.httpd.virtualHost
        {
          documentRoot = mkForce "${cfg.package}/share/zabbix";

          extraConfig = ''
            <Directory "${cfg.package}/share/zabbix">
              <FilesMatch "\.php$">
                <If "-f %{REQUEST_FILENAME}">
                  SetHandler "proxy:unix:${fpm.socket}|fcgi://localhost/"
                </If>
              </FilesMatch>
              AllowOverride all
              Options -Indexes
              DirectoryIndex index.php
            </Directory>
          '';
        }
      ];
    };

    services.nginx = mkIf (cfg.frontend == "nginx") {
      enable = true;

      virtualHosts.${cfg.hostname} = mkMerge [
        cfg.nginx.virtualHost
        {
          locations."/" = {
            index = "index.html index.htm index.php";
            tryFiles = "$uri $uri/ =404";
          };

          locations."~ \\.php$".extraConfig = ''
            fastcgi_pass  unix:${fpm.socket};
            fastcgi_index index.php;
          '';

          root = mkForce "${cfg.package}/share/zabbix";
        }
      ];
    };

    services.phpfpm.pools.zabbix = {
      inherit user;
      group = config.services.${cfg.frontend}.group;
      phpEnv.ZABBIX_CONFIG = "${zabbixConfig}";

      phpOptions = ''
        # https://www.zabbix.com/documentation/current/manual/installation/install
        memory_limit = 128M
        post_max_size = 16M
        upload_max_filesize = 2M
        max_execution_time = 300
        max_input_time = 300
        session.auto_start = 0
        mbstring.func_overload = 0
        always_populate_raw_post_data = -1
        # https://bbs.archlinux.org/viewtopic.php?pid=1745214#p1745214
        session.save_path = ${stateDir}/session
      ''
      + optionalString (config.time.timeZone != null) ''
        date.timezone = "${config.time.timeZone}"
      ''
      + optionalString (cfg.database.type == "oracle") ''
        extension=${pkgs.phpPackages.oci8}/lib/php/extensions/oci8.so
      '';

      settings = {
        "listen.group" =
          if cfg.frontend == "httpd" then config.services.httpd.group else config.services.nginx.group;

        "listen.owner" =
          if cfg.frontend == "httpd" then config.services.httpd.user else config.services.nginx.user;
      }
      // cfg.poolConfig;
    };

    services.zabbixWeb.extraConfig =
      optionalString
        (
          (versionAtLeast config.system.stateVersion "20.09") && (versionAtLeast cfg.package.version "5.0.0")
        )
        ''
          $DB['DOUBLE_IEEE754'] = 'true';
        '';

    systemd.tmpfiles.rules = [
      "d '${stateDir}' 0750 ${user} ${group} - -"
    ]
    ++ optionals (cfg.frontend == "httpd") [
      "d '${stateDir}/session' 0750 ${user} ${config.services.httpd.group} - -"
    ]
    ++ optionals (cfg.frontend == "nginx") [
      "d '${stateDir}/session' 0750 ${user} ${config.services.nginx.group} - -"
    ];

    users.groups.${group} = mapAttrs (name: mkDefault) { gid = config.ids.gids.zabbix; };

    users.users.${user} = mapAttrs (name: mkDefault) {
      inherit group;
      description = "Zabbix daemon user";
      uid = config.ids.uids.zabbix;
    };
  };
}
