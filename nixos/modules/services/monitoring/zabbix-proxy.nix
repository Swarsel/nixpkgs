{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.zabbixProxy;
  opt = options.services.zabbixProxy;
  pgsql = config.services.postgresql;
  mysql = config.services.mysql;

  inherit (lib)
    mkAfter
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    ;
  inherit (lib)
    attrValues
    getName
    literalExpression
    optional
    optionalAttrs
    optionalString
    types
    ;
  inherit (lib.generators) toKeyValue;

  user = "zabbix";
  group = "zabbix";
  runtimeDir = "/run/zabbix";
  stateDir = "/var/lib/zabbix";
  passwordFile = "${runtimeDir}/zabbix-dbpassword.conf";

  moduleEnv = pkgs.symlinkJoin {
    name = "zabbix-proxy-module-env";
    paths = attrValues cfg.modules;
  };

  configFile = pkgs.writeText "zabbix_proxy.conf" (
    toKeyValue { listsAsDuplicateKeys = true; } cfg.settings
  );

  mysqlLocal = cfg.database.createLocally && cfg.database.type == "mysql";
  pgsqlLocal = cfg.database.createLocally && cfg.database.type == "pgsql";

in

{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "zabbixProxy"
      "extraConfig"
    ] "Use services.zabbixProxy.settings instead.")
  ];

  # interface

  options = {

    services.zabbixProxy = {
      enable = mkEnableOption "the Zabbix Proxy";

      package = mkOption {
        default =
          if cfg.database.type == "mysql" then
            pkgs.zabbix.proxy-mysql
          else if cfg.database.type == "pgsql" then
            pkgs.zabbix.proxy-pgsql
          else
            pkgs.zabbix.proxy-sqlite;

        defaultText = literalExpression "pkgs.zabbix.proxy-pgsql";
        description = "The Zabbix package to use.";
        type = types.package;
      };

      database = {
        createLocally = mkOption {
          default = true;
          description = "Whether to create a local database automatically.";
          type = types.bool;
        };

        host = mkOption {
          default = "localhost";
          description = "Database host address.";
          type = types.str;
        };

        name = mkOption {
          default = if cfg.database.type == "sqlite" then "${stateDir}/zabbix.db" else "zabbix";
          defaultText = literalExpression "zabbix";
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
          default = if cfg.database.type == "mysql" then mysql.port else pgsql.settings.port;

          defaultText = literalExpression ''
            if config.${opt.database.type} == "mysql"
            then config.${options.services.mysql.port}
            else config.services.postgresql.settings.port
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
            "sqlite"
          ];
        };

        user = mkOption {
          default = "zabbix";
          description = "Database user.";
          type = types.str;
        };
      };

      extraPackages = mkOption {
        default = with pkgs; [
          net-tools
          nmap
          traceroute
        ];

        defaultText = literalExpression "[ net-tools nmap traceroute ]";

        description = ''
          Packages to be added to the Zabbix {env}`PATH`.
          Typically used to add executables for scripts, but can be anything.
        '';

        type = types.listOf types.package;
      };

      listen = {
        ip = mkOption {
          default = "0.0.0.0";

          description = ''
            List of comma delimited IP addresses that the trapper should listen on.
            Trapper will listen on all network interfaces if this parameter is missing.
          '';

          type = types.str;
        };

        port = mkOption {
          default = 10051;

          description = ''
            Listen port for trapper.
          '';

          type = types.port;
        };
      };

      modules = mkOption {
        default = { };
        description = "A set of modules to load.";

        example = literalExpression ''
          {
            "dummy.so" = pkgs.stdenv.mkDerivation {
              name = "zabbix-dummy-module-''${cfg.package.version}";
              src = cfg.package.src;
              buildInputs = [ cfg.package ];
              sourceRoot = "zabbix-''${cfg.package.version}/src/modules/dummy";
              installPhase = '''
                mkdir -p $out/lib
                cp dummy.so $out/lib/
              ''';
            };
          }
        '';

        type = types.attrsOf types.package;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Open ports in the firewall for the Zabbix Proxy.
        '';

        type = types.bool;
      };

      server = mkOption {
        description = ''
          The IP address or hostname of the Zabbix server to connect to.
        '';

        type = types.str;
      };

      settings = mkOption {
        default = { };

        description = ''
          Zabbix Proxy configuration. Refer to
          <https://www.zabbix.com/documentation/current/manual/appendix/config/zabbix_proxy>
          for details on supported values.
        '';

        example = {
          CacheSize = "1G";
          SSHKeyLocation = "/var/lib/zabbix/.ssh";
          StartPingers = 32;
        };

        type =
          with types;
          attrsOf (oneOf [
            int
            str
            (listOf str)
          ]);
      };

    };

  };

  # implementation

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = !config.services.zabbixServer.enable;
        message = "Please choose one of services.zabbixServer or services.zabbixProxy.";
      }
      {
        assertion =
          cfg.database.createLocally -> cfg.database.user == user && cfg.database.name == cfg.database.user;

        message = "services.zabbixProxy.database.user must be set to ${user} if services.zabbixProxy.database.createLocally is set true";
      }
      {
        assertion = cfg.database.createLocally -> cfg.database.passwordFile == null;
        message = "a password cannot be specified if services.zabbixProxy.database.createLocally is set to true";
      }
    ];

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.listen.port ];
    };

    security.wrappers = {
      fping = {
        group = "root";
        owner = "root";
        setuid = true;
        source = "${pkgs.fping}/bin/fping";
      };
    };

    services.mysql = optionalAttrs mysqlLocal {
      enable = true;
      package = mkDefault pkgs.mariadb;
    };

    services.postgresql = optionalAttrs pgsqlLocal {
      enable = true;
      ensureDatabases = [ cfg.database.name ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = cfg.database.user;
        }
      ];
    };

    services.zabbixProxy.settings = mkMerge [
      {
        # TODO: set to cfg.database.socket if database type is pgsql?
        DBHost = optionalString (cfg.database.createLocally != true) cfg.database.host;
        DBName = cfg.database.name;
        DBUser = cfg.database.user;
        FpingLocation = "/run/wrappers/bin/fping";
        ListenIP = cfg.listen.ip;
        ListenPort = cfg.listen.port;
        LoadModule = builtins.attrNames cfg.modules;
        LogType = "console";
        Server = cfg.server;
        SocketDir = runtimeDir;
      }
      (mkIf (cfg.database.createLocally != true) { DBPort = cfg.database.port; })
      (mkIf (cfg.database.passwordFile != null) { Include = [ "${passwordFile}" ]; })
      (mkIf (mysqlLocal && cfg.database.socket != null) { DBSocket = cfg.database.socket; })
      (mkIf (cfg.modules != { }) { LoadModulePath = "${moduleEnv}/lib"; })
    ];

    systemd.services.mysql.postStart = mkAfter (
      optionalString mysqlLocal ''
        ( echo "CREATE DATABASE IF NOT EXISTS \`${cfg.database.name}\` CHARACTER SET utf8 COLLATE utf8_bin;"
          echo "CREATE USER IF NOT EXISTS '${cfg.database.user}'@'localhost' IDENTIFIED WITH ${
            if (getName config.services.mysql.package == getName pkgs.mariadb) then
              "unix_socket"
            else
              "auth_socket"
          };"
          echo "GRANT ALL PRIVILEGES ON \`${cfg.database.name}\`.* TO '${cfg.database.user}'@'localhost';"
        ) | ${config.services.mysql.package}/bin/mysql -N
      ''
    );

    systemd.services.zabbix-proxy = {
      after = optional mysqlLocal "mysql.service" ++ optional pgsqlLocal "postgresql.target";
      description = "Zabbix Proxy";
      path = [ "/run/wrappers" ] ++ cfg.extraPackages;

      preStart =
        optionalString pgsqlLocal ''
          if ! test -e "${stateDir}/db-created"; then
            cat ${cfg.package}/share/zabbix/database/postgresql/schema.sql | ${pgsql.package}/bin/psql ${cfg.database.name}
            touch "${stateDir}/db-created"
          fi
        ''
        + optionalString mysqlLocal ''
          if ! test -e "${stateDir}/db-created"; then
            cat ${cfg.package}/share/zabbix/database/mysql/schema.sql | ${mysql.package}/bin/mysql ${cfg.database.name}
            touch "${stateDir}/db-created"
          fi
        ''
        + optionalString (cfg.database.type == "sqlite") ''
          if ! test -e "${cfg.database.name}"; then
            ${pkgs.sqlite}/bin/sqlite3 "${cfg.database.name}" < ${cfg.package}/share/zabbix/database/sqlite3/schema.sql
          fi
        ''
        + optionalString (cfg.database.passwordFile != null) ''
          # create a copy of the supplied password file in a format zabbix can consume
          install -m 0600 <(echo "DBPassword = $(cat ${cfg.database.passwordFile})") ${passwordFile}
        '';

      serviceConfig = {
        ExecStart = "@${cfg.package}/sbin/zabbix_proxy zabbix_proxy -f --config ${configFile}";
        Group = group;
        PrivateTmp = true;
        Restart = "always";
        RestartSec = 2;
        RuntimeDirectory = "zabbix";
        StateDirectory = "zabbix";
        User = user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.${group} = {
      gid = config.ids.gids.zabbix;
    };

    users.users.${user} = {
      inherit group;
      description = "Zabbix daemon user";
      uid = config.ids.uids.zabbix;
    };

  };

}
