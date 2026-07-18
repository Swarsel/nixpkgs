{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.pgmanage;

  confFile = pkgs.writeTextFile {
    name = "pgmanage.conf";

    text = ''
      connection_file = ${pgmanageConnectionsFile}

      allow_custom_connections = ${builtins.toJSON cfg.allowCustomConnections}

      pgmanage_port = ${toString cfg.port}

      super_only = ${builtins.toJSON cfg.superOnly}

      ${lib.optionalString (cfg.loginGroup != null) "login_group = ${cfg.loginGroup}"}

      login_timeout = ${toString cfg.loginTimeout}

      web_root = ${cfg.package}/etc/pgmanage/web_root

      sql_root = ${cfg.sqlRoot}

      ${lib.optionalString (cfg.tls != null) ''
        tls_cert = ${cfg.tls.cert}
        tls_key = ${cfg.tls.key}
      ''}

      log_level = ${cfg.logLevel}
    '';
  };

  pgmanageConnectionsFile = pkgs.writeTextFile {
    name = "pgmanage-connections.conf";

    text = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: conn: "${name}: ${conn}") cfg.connections
    );
  };

  pgmanage = "pgmanage";

in
{

  options.services.pgmanage = {
    enable = lib.mkEnableOption "PostgreSQL Administration for the web";
    package = lib.mkPackageOption pkgs "pgmanage" { };

    allowCustomConnections = lib.mkOption {
      default = false;

      description = ''
        This tells pgmanage whether or not to allow anyone to use a custom
        connection from the login screen.
      '';

      type = lib.types.bool;
    };

    connections = lib.mkOption {
      default = { };

      description = ''
        pgmanage requires at least one PostgreSQL server be defined.

        Detailed information about PostgreSQL connection strings is available at:
        <https://www.postgresql.org/docs/current/libpq-connect.html>

        Note that you should not specify your user name or password. That
        information will be entered on the login screen. If you specify a
        username or password, it will be removed by pgmanage before attempting to
        connect to a database.
      '';

      example = {
        mini-server = "hostaddr=127.0.0.1 port=5432 dbname=postgres sslmode=require";
        nuc-server = "hostaddr=192.168.0.100 port=5432 dbname=postgres";
      };

      type = lib.types.attrsOf lib.types.str;
    };

    localOnly = lib.mkOption {
      default = true;

      description = ''
        This tells pgmanage whether or not to set the listening socket to local
        addresses only.
      '';

      type = lib.types.bool;
    };

    logLevel = lib.mkOption {
      default = "error";

      description = ''
        Verbosity of logs
      '';

      type = lib.types.enum [
        "error"
        "warn"
        "notice"
        "info"
      ];
    };

    loginGroup = lib.mkOption {
      default = null;

      description = ''
        This tells pgmanage to only allow users in a certain PostgreSQL group to
        login to pgmanage. Note that a connection will be made to PostgreSQL in
        order to test if the user is a member of the login group.
      '';

      type = lib.types.nullOr lib.types.str;
    };

    loginTimeout = lib.mkOption {
      default = 3600;

      description = ''
        Number of seconds of inactivity before user is automatically logged
        out.
      '';

      type = lib.types.int;
    };

    port = lib.mkOption {
      default = 8080;

      description = ''
        This tells pgmanage what port to listen on for browser requests.
      '';

      type = lib.types.port;
    };

    sqlRoot = lib.mkOption {
      default = "/var/lib/pgmanage";

      description = ''
        This tells pgmanage where to put the SQL file history. All tabs are saved
        to this location so that if you get disconnected from pgmanage you
        don't lose your work.
      '';

      type = lib.types.str;
    };

    superOnly = lib.mkOption {
      default = true;

      description = ''
        This tells pgmanage whether or not to only allow super users to
        login. The recommended value is true and will restrict users who are not
        super users from logging in to any PostgreSQL instance through
        pgmanage. Note that a connection will be made to PostgreSQL in order to
        test if the user is a superuser.
      '';

      type = lib.types.bool;
    };

    tls = lib.mkOption {
      default = null;

      description = ''
        These options tell pgmanage where the TLS Certificate and Key files
        reside. If you use these options then you'll only be able to access
        pgmanage through a secure TLS connection. These options are only
        necessary if you wish to connect directly to pgmanage using a secure TLS
        connection. As an alternative, you can set up pgmanage in a reverse proxy
        configuration. This allows your web server to terminate the secure
        connection and pass on the request to pgmanage. You can find help to set
        up this configuration in:
        <https://github.com/pgManage/pgManage/blob/master/INSTALL_NGINX.md>
      '';

      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            cert = lib.mkOption {
              description = "TLS certificate";
              type = lib.types.str;
            };

            key = lib.mkOption {
              description = "TLS key";
              type = lib.types.str;
            };
          };
        }
      );
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.pgmanage = {
      after = [ "postgresql.target" ];
      description = "pgmanage - PostgreSQL Administration for the web";

      serviceConfig = {
        ExecStart =
          "${cfg.package}/sbin/pgmanage -c ${confFile}"
          + lib.optionalString cfg.localOnly " --local-only=true";

        Group = pgmanage;
        User = pgmanage;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "postgresql.target" ];
    };

    users = {
      groups.${pgmanage} = {
        name = pgmanage;
      };

      users.${pgmanage} = {
        createHome = true;
        group = pgmanage;
        home = cfg.sqlRoot;
        isSystemUser = true;
        name = pgmanage;
      };
    };
  };
}
