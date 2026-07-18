{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.pgbouncer;

  settingsFormat = pkgs.formats.ini { };
  configFile = settingsFormat.generate "pgbouncer.ini" (
    lib.filterAttrsRecursive (_: v: v != null) cfg.settings
  );
  configPath = "pgbouncer/pgbouncer.ini";
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "pgbouncer" "logFile" ] ''
      `services.pgbouncer.logFile` has been removed, use `services.pgbouncer.settings.pgbouncer.logfile`
      instead.
      Please note that the new option expects an absolute path
      whereas the old option accepted paths relative to pgbouncer's home dir.
    '')
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "listenAddress" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "listen_addr" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "listenPort" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "listen_port" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "poolMode" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "pool_mode" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "maxClientConn" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "max_client_conn" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "defaultPoolSize" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "default_pool_size" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "maxDbConnections" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "max_db_connections" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "maxUserConnections" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "max_user_connections" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "ignoreStartupParameters" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "ignore_startup_parameters" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "databases" ]
      [ "services" "pgbouncer" "settings" "databases" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "users" ]
      [ "services" "pgbouncer" "settings" "users" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "peers" ]
      [ "services" "pgbouncer" "settings" "peers" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "authType" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "auth_type" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "authHbaFile" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "auth_hba_file" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "authFile" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "auth_file" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "authUser" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "auth_user" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "authQuery" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "auth_query" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "authDbname" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "auth_dbname" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "adminUsers" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "admin_users" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "statsUsers" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "stats_users" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "verbose" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "verbose" ]
    )
    (lib.mkChangedOptionModule
      [ "services" "pgbouncer" "syslog" "enable" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "syslog" ]
      (
        config:
        let
          enable = lib.getAttrFromPath [ "services" "pgbouncer" "syslog" "enable" ] config;
        in
        if enable then 1 else 0
      )
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "syslog" "syslogIdent" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "syslog_ident" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "syslog" "syslogFacility" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "syslog_facility" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "tls" "client" "sslmode" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "client_tls_sslmode" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "tls" "client" "keyFile" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "client_tls_key_file" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "tls" "client" "certFile" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "client_tls_cert_file" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "tls" "client" "caFile" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "client_tls_ca_file" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "tls" "server" "sslmode" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "server_tls_sslmode" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "tls" "server" "keyFile" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "server_tls_key_file" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "tls" "server" "certFile" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "server_tls_cert_file" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "pgbouncer" "tls" "server" "caFile" ]
      [ "services" "pgbouncer" "settings" "pgbouncer" "server_tls_ca_file" ]
    )
    (lib.mkRemovedOptionModule [
      "services"
      "pgbouncer"
      "extraConfig"
    ] "Use services.pgbouncer.settings instead.")
  ];

  options.services.pgbouncer = {
    enable = lib.mkEnableOption "PostgreSQL connection pooler";
    package = lib.mkPackageOption pkgs "pgbouncer" { };

    group = lib.mkOption {
      default = "pgbouncer";

      description = ''
        The group pgbouncer is run as.
      '';

      type = lib.types.str;
    };

    homeDir = lib.mkOption {
      default = "/var/lib/pgbouncer";

      description = ''
        Specifies the home directory.
      '';

      type = lib.types.path;
    };

    # Linux settings
    openFilesLimit = lib.mkOption {
      default = 65536;

      description = ''
        Maximum number of open files.
      '';

      type = lib.types.int;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Whether to automatically open the specified TCP port in the firewall.
      '';

      type = lib.types.bool;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration for PgBouncer, see <https://www.pgbouncer.org/config.html>
        for supported values.
      '';

      type = lib.types.submodule {
        options = {
          databases = lib.mkOption {
            default = { };

            description = ''
              Detailed information about PostgreSQL database definitions:
              <https://www.pgbouncer.org/config.html#section-databases>
            '';

            example = {
              bardb = "host=localhost dbname=bazdb";
              exampledb = "host=/run/postgresql/ port=5432 auth_user=exampleuser dbname=exampledb sslmode=require";
              foodb = "host=host1.example.com port=5432";
            };

            type = lib.types.attrsOf lib.types.str;
          };

          peers = lib.mkOption {
            default = { };

            description = ''
              Optional.

              Detailed information about PostgreSQL database definitions:
              <https://www.pgbouncer.org/config.html#section-peers>
            '';

            example = {
              "1" = "host=host1.example.com";
              "2" = "host=/tmp/pgbouncer-2 port=5555";
            };

            type = lib.types.attrsOf lib.types.str;
          };

          pgbouncer = {
            default_pool_size = lib.mkOption {
              default = 20;

              description = ''
                How many server connections to allow per user/database pair.
                Can be overridden in the per-database configuration.
              '';

              type = lib.types.int;
            };

            ignore_startup_parameters = lib.mkOption {
              default = null;

              description = ''
                By default, PgBouncer allows only parameters it can keep track of in startup packets:
                client_encoding, datestyle, timezone and standard_conforming_strings.

                All others parameters will raise an error.
                To allow others parameters, they can be specified here, so that PgBouncer knows that
                they are handled by the admin and it can ignore them.

                If you need to specify multiple values, use a comma-separated list.

                IMPORTANT: When using prometheus-pgbouncer-exporter, you need:
                extra_float_digits
                <https://github.com/prometheus-community/pgbouncer_exporter#pgbouncer-configuration>
              '';

              example = "extra_float_digits";
              type = lib.types.nullOr lib.types.commas;
            };

            listen_addr = lib.mkOption {
              default = null;

              description = ''
                Specifies a list (comma-separated) of addresses where to listen for TCP connections.
                You may also use * meaning “listen on all addresses”.
                When not set, only Unix socket connections are accepted.

                Addresses can be specified numerically (IPv4/IPv6) or by name.
              '';

              example = "*";
              type = lib.types.nullOr lib.types.commas;
            };

            listen_port = lib.mkOption {
              default = 6432;

              description = ''
                Which port to listen on. Applies to both TCP and Unix sockets.
              '';

              type = lib.types.port;
            };

            max_client_conn = lib.mkOption {
              default = 100;

              description = ''
                Maximum number of client connections allowed.

                When this setting is increased, then the file descriptor limits in the operating system
                might also have to be increased. Note that the number of file descriptors potentially
                used is more than maxClientConn. If each user connects under its own user name to the server,
                the theoretical maximum used is:
                maxClientConn + (max pool_size * total databases * total users)

                If a database user is specified in the connection string (all users connect under the same user name),
                the theoretical maximum is:
                maxClientConn + (max pool_size * total databases)

                The theoretical maximum should never be reached, unless somebody deliberately crafts a special load for it.
                Still, it means you should set the number of file descriptors to a safely high number.
              '';

              type = lib.types.int;
            };

            max_db_connections = lib.mkOption {
              default = 0;

              description = ''
                Do not allow more than this many server connections per database (regardless of user).
                This considers the PgBouncer database that the client has connected to,
                not the PostgreSQL database of the outgoing connection.

                This can also be set per database in the [databases] section.

                Note that when you hit the limit, closing a client connection to one pool will
                not immediately allow a server connection to be established for another pool,
                because the server connection for the first pool is still open.
                Once the server connection closes (due to idle timeout),
                a new server connection will immediately be opened for the waiting pool.

                0 = unlimited
              '';

              type = lib.types.int;
            };

            max_user_connections = lib.mkOption {
              default = 0;

              description = ''
                Do not allow more than this many server connections per user (regardless of database).
                This considers the PgBouncer user that is associated with a pool,
                which is either the user specified for the server connection
                or in absence of that the user the client has connected as.

                This can also be set per user in the [users] section.

                Note that when you hit the limit, closing a client connection to one pool
                will not immediately allow a server connection to be established for another pool,
                because the server connection for the first pool is still open.
                Once the server connection closes (due to idle timeout), a new server connection
                will immediately be opened for the waiting pool.

                0 = unlimited
              '';

              type = lib.types.int;
            };

            pool_mode = lib.mkOption {
              default = "session";

              description = ''
                Specifies when a server connection can be reused by other clients.

                session
                    Server is released back to pool after client disconnects. Default.
                transaction
                    Server is released back to pool after transaction finishes.
                statement
                    Server is released back to pool after query finishes.
                    Transactions spanning multiple statements are disallowed in this mode.
              '';

              type = lib.types.enum [
                "session"
                "transaction"
                "statement"
              ];
            };
          };

          users = lib.mkOption {
            default = { };

            description = ''
              Optional.

              Detailed information about PostgreSQL user definitions:
              <https://www.pgbouncer.org/config.html#section-users>
            '';

            example = {
              user1 = "pool_mode=session";
            };

            type = lib.types.attrsOf lib.types.str;
          };
        };

        freeformType = settingsFormat.type;
      };
    };

    user = lib.mkOption {
      default = "pgbouncer";

      description = ''
        The user pgbouncer is run as.
      '';

      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc.${configPath}.source = configFile;

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        (cfg.settings.pgbouncer.listen_port or 6432)
      ];
    };

    # Default to RuntimeDirectory instead of /tmp.
    services.pgbouncer.settings.pgbouncer.unix_socket_dir = lib.mkDefault "/run/pgbouncer";

    systemd.services.pgbouncer = {
      after = [ "network-online.target" ];
      description = "PgBouncer - PostgreSQL connection pooler";
      reloadTriggers = [ configFile ];

      serviceConfig = {
        ExecStart = utils.escapeSystemdExecArgs [
          (lib.getExe cfg.package)
          "/etc/${configPath}"
        ];

        Group = cfg.group;
        LimitNOFILE = cfg.openFilesLimit;
        RuntimeDirectory = "pgbouncer";
        Type = "notify-reload";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      createHome = true;
      description = "PgBouncer service user";
      group = cfg.group;
      home = cfg.homeDir;
      isSystemUser = true;
    };
  };

  meta.maintainers = [ lib.maintainers._1000101 ];
}
