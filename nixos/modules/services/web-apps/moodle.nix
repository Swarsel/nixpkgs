{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkPackageOption
    mkForce
    mkIf
    mkMerge
    mkOption
    types
    ;
  inherit (lib)
    literalExpression
    optional
    optionalString
    ;

  cfg = config.services.moodle;
  fpm = config.services.phpfpm.pools.moodle;

  user = "moodle";
  group = config.services.httpd.group;
  stateDir = "/var/lib/moodle";

  moodleConfig = pkgs.writeText "config.php" ''
    <?php  // Moodle configuration file

    unset($CFG);
    global $CFG;
    $CFG = new stdClass();

    $CFG->dbtype    = '${
      {
        mysql = "mariadb";
        pgsql = "pgsql";
      }
      .${cfg.database.type}
    }';
    $CFG->dblibrary = 'native';
    $CFG->dbhost    = '${cfg.database.host}';
    $CFG->dbname    = '${cfg.database.name}';
    $CFG->dbuser    = '${cfg.database.user}';
    ${optionalString (
      cfg.database.passwordFile != null
    ) "$CFG->dbpass = file_get_contents('${cfg.database.passwordFile}');"}
    $CFG->prefix    = 'mdl_';
    $CFG->dboptions = array (
      'dbpersist' => 0,
      'dbport' => '${toString cfg.database.port}',
      ${optionalString (cfg.database.socket != null) "'dbsocket' => '${cfg.database.socket}',"}
      'dbcollation' => 'utf8mb4_unicode_ci',
    );

    $CFG->wwwroot   = '${
      if cfg.virtualHost.addSSL || cfg.virtualHost.forceSSL || cfg.virtualHost.onlySSL then
        "https"
      else
        "http"
    }://${cfg.virtualHost.hostName}';
    $CFG->dataroot  = '${stateDir}';
    $CFG->admin     = 'admin';

    $CFG->directorypermissions = 02777;
    $CFG->disableupdateautodeploy = true;

    $CFG->pathtogs = '${pkgs.ghostscript}/bin/gs';
    $CFG->pathtophp = '${phpExt}/bin/php';
    $CFG->pathtodu = '${pkgs.coreutils}/bin/du';
    $CFG->aspellpath = '${pkgs.aspell}/bin/aspell';
    $CFG->pathtodot = '${pkgs.graphviz}/bin/dot';

    ${cfg.extraConfig}

    require_once('${cfg.package}/share/moodle/lib/setup.php');

    // There is no php closing tag in this file,
    // it is intentional because it prevents trailing whitespace problems!
  '';

  mysqlLocal = cfg.database.createLocally && cfg.database.type == "mysql";
  pgsqlLocal = cfg.database.createLocally && cfg.database.type == "pgsql";

  phpExt = pkgs.php83.buildEnv {
    extensions =
      { all, ... }:
      with all;
      [
        iconv
        mbstring
        curl
        openssl
        tokenizer
        soap
        ctype
        zip
        gd
        simplexml
        dom
        intl
        sqlite3
        pgsql
        pdo_sqlite
        pdo_pgsql
        pdo_odbc
        pdo_mysql
        pdo
        mysqli
        session
        zlib
        xmlreader
        fileinfo
        filter
        opcache
        exif
        sodium
      ];

    extraConfig = "max_input_vars = 5000";
  };
in
{
  # interface
  options.services.moodle = {
    enable = mkEnableOption "Moodle web application";
    package = mkPackageOption pkgs "moodle" { };

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
        default = "moodle";
        description = "Database name.";
        type = types.str;
      };

      passwordFile = mkOption {
        default = null;

        description = ''
          A file containing the password corresponding to
          {option}`database.user`.
        '';

        example = "/run/keys/moodle-dbpassword";
        type = types.nullOr types.path;
      };

      port = mkOption {
        default =
          {
            mysql = 3306;
            pgsql = 5432;
          }
          .${cfg.database.type};

        defaultText = literalExpression "3306";
        description = "Database host port.";
        type = types.port;
      };

      socket = mkOption {
        default =
          if mysqlLocal then
            "/run/mysqld/mysqld.sock"
          else if pgsqlLocal then
            "/run/postgresql"
          else
            null;

        defaultText = literalExpression "/run/mysqld/mysqld.sock";
        description = "Path to the unix socket file to use for authentication.";
        type = types.nullOr types.path;
      };

      type = mkOption {
        default = "mysql";
        description = "Database engine to use.";

        type = types.enum [
          "mysql"
          "pgsql"
        ];
      };

      user = mkOption {
        default = "moodle";
        description = "Database user.";
        type = types.str;
      };
    };

    extraConfig = mkOption {
      default = "";

      description = ''
        Any additional text to be appended to the config.php
        configuration file. This is a PHP script. For configuration
        details, see <https://docs.moodle.org/37/en/Configuration_file>.
      '';

      example = ''
        $CFG->disableupdatenotifications = true;
      '';

      type = types.lines;
    };

    initialPassword = mkOption {
      description = ''
        Specifies the initial password for the admin, i.e. the password assigned if the user does not already exist.
        The password specified here is world-readable in the Nix store, so it should be changed promptly.
      '';

      example = "correcthorsebatterystaple";
      type = types.str;
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
        Options for the Moodle PHP pool. See the documentation on `php-fpm.conf`
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

    virtualHost = mkOption {
      description = ''
        Apache configuration can be done by adapting {option}`services.httpd.virtualHosts`.
        See [](#opt-services.httpd.virtualHosts) for further information.
      '';

      example = literalExpression ''
        {
          hostName = "moodle.example.org";
          adminAddr = "webmaster@example.org";
          forceSSL = true;
          enableACME = true;
        }
      '';

      type = types.submodule (import ../web-servers/apache-httpd/vhost-options.nix);
    };
  };

  # implementation
  config = mkIf cfg.enable {

    assertions = [
      {
        assertion =
          cfg.database.createLocally -> cfg.database.user == user && cfg.database.user == cfg.database.name;

        message = "services.moodle.database.user must be set to ${user} if services.moodle.database.createLocally is set true";
      }
      {
        assertion = cfg.database.createLocally -> cfg.database.passwordFile == null;
        message = "a password cannot be specified if services.moodle.database.createLocally is set to true";
      }
    ];

    services.httpd = {
      enable = true;
      adminAddr = mkDefault cfg.virtualHost.adminAddr;
      extraModules = [ "proxy_fcgi" ];

      virtualHosts.${cfg.virtualHost.hostName} = mkMerge [
        cfg.virtualHost
        {
          documentRoot = mkForce "${cfg.package}/share/moodle";

          extraConfig = ''
            <Directory "${cfg.package}/share/moodle">
              <FilesMatch "\.php$">
                <If "-f %{REQUEST_FILENAME}">
                  SetHandler "proxy:unix:${fpm.socket}|fcgi://localhost/"
                </If>
              </FilesMatch>
              Options -Indexes
              DirectoryIndex index.php
            </Directory>
          '';
        }
      ];
    };

    services.mysql = mkIf mysqlLocal {
      enable = true;
      package = mkDefault pkgs.mariadb;
      ensureDatabases = [ cfg.database.name ];

      ensureUsers = [
        {
          ensurePermissions = {
            "${cfg.database.name}.*" =
              "SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, DROP, INDEX, ALTER";
          };

          name = cfg.database.user;
        }
      ];
    };

    services.phpfpm.pools.moodle = {
      inherit user group;
      phpEnv.MOODLE_CONFIG = "${moodleConfig}";

      phpOptions = ''
        zend_extension = opcache.so
        opcache.enable = 1
        max_input_vars = 5000
      '';

      phpPackage = phpExt;

      settings = {
        "listen.group" = config.services.httpd.group;
        "listen.owner" = config.services.httpd.user;
      }
      // cfg.poolConfig;
    };

    services.postgresql = mkIf pgsqlLocal {
      enable = true;
      ensureDatabases = [ cfg.database.name ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = cfg.database.user;
        }
      ];
    };

    systemd.services.httpd.after =
      optional mysqlLocal "mysql.service" ++ optional pgsqlLocal "postgresql.target";

    systemd.services.moodle-cron = {
      after = [ "moodle-init.service" ];
      description = "Moodle cron service";
      environment.MOODLE_CONFIG = moodleConfig;

      serviceConfig = {
        ExecStart = "${phpExt}/bin/php ${cfg.package}/share/moodle/admin/cli/cron.php";
        Group = group;
        User = user;
      };
    };

    systemd.services.moodle-init = {
      after = optional mysqlLocal "mysql.service" ++ optional pgsqlLocal "postgresql.target";
      before = [ "phpfpm-moodle.service" ];
      environment.MOODLE_CONFIG = moodleConfig;

      script = ''
        ${phpExt}/bin/php ${cfg.package}/share/moodle/admin/cli/check_database_schema.php && rc=$? || rc=$?

        [ "$rc" == 1 ] && ${phpExt}/bin/php ${cfg.package}/share/moodle/admin/cli/upgrade.php \
          --non-interactive \
          --allow-unstable

        [ "$rc" == 2 ] && ${phpExt}/bin/php ${cfg.package}/share/moodle/admin/cli/install_database.php \
          --agree-license \
          --adminpass=${cfg.initialPassword}

        true
      '';

      serviceConfig = {
        Group = group;
        Type = "oneshot";
        User = user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.timers.moodle-cron = {
      description = "Moodle cron timer";

      timerConfig = {
        OnCalendar = "minutely";
      };

      wantedBy = [ "timers.target" ];
    };

    systemd.tmpfiles.settings."10-moodle".${stateDir}.d = {
      inherit user group;
      mode = "0750";
    };

    users.users.${user} = {
      group = group;
      isSystemUser = true;
    };
  };
}
