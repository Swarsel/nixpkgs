{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.flarum;

  flarumInstallConfig = pkgs.writeText "config.json" (
    builtins.toJSON {
      adminUser = {
        email = cfg.adminEmail;
        password = cfg.initialAdminPassword;
        username = cfg.adminUser;
      };

      baseUrl = cfg.baseUrl;
      databaseConfiguration = cfg.database;
      debug = false;
      offline = false;

      settings = {
        forum_title = cfg.forumTitle;
      };
    }
  );
in
{
  options.services.flarum = {
    enable = mkEnableOption "Flarum discussion platform";
    package = mkPackageOption pkgs "flarum" { };

    adminEmail = mkOption {
      default = "admin@example.com";
      description = "Email for first web application administrator";
      type = types.str;
    };

    adminUser = mkOption {
      default = "flarum";
      description = "Username for first web application administrator";
      type = types.str;
    };

    baseUrl = mkOption {
      default = "http://localhost";
      description = "Change `domain` instead.";
      example = "https://forum.example.com";
      type = types.str;
    };

    createDatabaseLocally = mkOption {
      default = false;

      description = ''
        Create the database and database user locally, and run installation.

        WARNING: Due to <https://github.com/flarum/framework/issues/4018>, this option is set
        to false by default. The 'flarum install' command may delete existing database tables.
        Only set this to true if you are certain you are working with a fresh, empty database.
      '';

      type = types.bool;
    };

    database = mkOption {
      default = {
        # the name of the database in the instance
        database = "flarum";
        # the database driver; i.e. MySQL; MariaDB...
        driver = "mysql";
        # the host of the connection; localhost in most cases unless using an external service
        host = "localhost";
        # database password
        password = "";
        # the port of the connection; defaults to 3306 with MySQL
        port = 3306;
        # the prefix for the tables; useful if you are sharing the same database with another service
        prefix = "";
        strict = false;
        # database username
        username = "flarum";
      };

      description = "MySQL database parameters";

      type =
        with types;
        attrsOf (oneOf [
          str
          bool
          int
        ]);
    };

    domain = mkOption {
      default = "localhost";
      description = "Domain to serve on.";
      example = "forum.example.com";
      type = types.str;
    };

    forumTitle = mkOption {
      default = "A Flarum Forum on NixOS";
      description = "Title of the forum.";
      type = types.str;
    };

    group = mkOption {
      default = "flarum";
      description = "System group to run Flarum";
      type = types.str;
    };

    initialAdminPassword = mkOption {
      default = "flarum";
      description = "Initial password for the adminUser";
      type = types.str;
    };

    stateDir = mkOption {
      default = "/var/lib/flarum";
      description = "Home directory for writable storage";
      type = types.path;
    };

    user = mkOption {
      default = "flarum";
      description = "System user to run Flarum";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.createDatabaseLocally || cfg.database.driver == "mysql";
        message = "Flarum can only be automatically installed in MySQL/MariaDB.";
      }
    ];

    services.mysql = mkIf cfg.enable {
      enable = true;
      package = pkgs.mariadb;
      ensureDatabases = [ cfg.database.database ];

      ensureUsers = [
        {
          ensurePermissions = {
            "${cfg.database.database}.*" = "ALL PRIVILEGES";
          };

          name = cfg.database.username;
        }
      ];
    };

    services.nginx = {
      enable = true;

      virtualHosts."${cfg.domain}" = {
        extraConfig = ''
          index index.php;
          include ${cfg.package}/share/php/flarum/.nginx.conf;
        '';

        locations."~ \\.php$".extraConfig = ''
          fastcgi_pass unix:${config.services.phpfpm.pools.flarum.socket};
          fastcgi_index site.php;
        '';

        root = "${cfg.stateDir}/public";
      };
    };

    services.phpfpm.pools.flarum = {
      phpOptions = ''
        error_log = syslog
        log_errors = on
      '';

      settings = {
        "listen.group" = config.services.nginx.group;
        "listen.mode" = "0600";
        "listen.owner" = config.services.nginx.user;
        "pm" = mkDefault "dynamic";
        "pm.max_children" = mkDefault 10;
        "pm.max_requests" = mkDefault 500;
        "pm.max_spare_servers" = mkDefault 3;
        "pm.min_spare_servers" = mkDefault 1;
        "pm.start_servers" = mkDefault 2;
      };

      user = cfg.user;
    };

    systemd.services.flarum-install = {
      after = [ "mysql.service" ];
      before = [ "phpfpm-flarum.service" ];
      description = "Flarum installation";
      path = [ config.services.phpfpm.phpPackage ];
      requiredBy = [ "phpfpm-flarum.service" ];
      requires = [ "mysql.service" ];

      script = ''
        mkdir -p ${cfg.stateDir}/{extensions,public/assets/avatars}
        mkdir -p ${cfg.stateDir}/storage/{cache,formatter,sessions,views}
        cd ${cfg.stateDir}
        cp -f ${cfg.package}/share/php/flarum/{extend.php,site.php,flarum} .
        ln -sf ${cfg.package}/share/php/flarum/vendor .
        ln -sf ${cfg.package}/share/php/flarum/public/index.php public/
      ''
      + optionalString (cfg.createDatabaseLocally && cfg.database.driver == "mysql") ''
        if [ ! -f config.php ]; then
          php flarum install --file=${flarumInstallConfig}
        fi
      ''
      + ''
        if [ -f config.php ]; then
          php flarum migrate
          php flarum cache:clear
        fi
      '';

      serviceConfig = {
        Group = cfg.group;
        Type = "oneshot";
        User = cfg.user;
      };
    };

    systemd.services."phpfpm-flarum" = {
      restartTriggers = [ cfg.package ];
    };

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      createHome = true;
      group = cfg.group;
      home = cfg.stateDir;
      homeMode = "755";
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [
    fsagbuya
    jasonodoom
  ];
}
