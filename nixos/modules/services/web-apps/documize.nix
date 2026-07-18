{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.documize;

  mkParams =
    optional:
    concatMapStrings (
      name:
      let
        predicate = optional -> cfg.${name} != null;
        template = " -${name} '${toString cfg.${name}}'";
      in
      optionalString predicate template
    );

in
{
  options.services.documize = {
    enable = mkEnableOption "Documize Wiki";
    package = mkPackageOption pkgs "documize-community" { };

    cert = mkOption {
      default = null;

      description = ''
        The {file}`cert.pem` file used for https.
      '';

      type = types.nullOr types.str;
    };

    db = mkOption {
      description = ''
        Database specific connection string for example:
        - MySQL/Percona/MariaDB:
          `user:password@tcp(host:3306)/documize`
        - MySQLv8+:
          `user:password@tcp(host:3306)/documize?allowNativePasswords=true`
        - PostgreSQL:
          `host=localhost port=5432 dbname=documize user=admin password=secret sslmode=disable`
        - MSSQL:
          `sqlserver://username:password@localhost:1433?database=Documize` or
          `sqlserver://sa@localhost/SQLExpress?database=Documize`
      '';

      type = types.str;
    };

    dbtype = mkOption {
      default = "postgresql";

      description = ''
        Specify the database provider: `mysql`, `percona`, `mariadb`, `postgresql`, `sqlserver`
      '';

      type = types.enum [
        "mysql"
        "percona"
        "mariadb"
        "postgresql"
        "sqlserver"
      ];
    };

    forcesslport = mkOption {
      default = null;

      description = ''
        Redirect given http port number to TLS.
      '';

      type = types.nullOr types.port;
    };

    key = mkOption {
      default = null;

      description = ''
        The {file}`key.pem` file used for https.
      '';

      type = types.nullOr types.str;
    };

    location = mkOption {
      default = null;

      description = ''
        reserved
      '';

      type = types.nullOr types.str;
    };

    offline = mkOption {
      apply = v: if true == v then 1 else 0;
      default = false;

      description = ''
        Set `true` for offline mode.
      '';

      type = types.bool;
    };

    port = mkOption {
      default = 5001;

      description = ''
        The http/https port number.
      '';

      type = types.port;
    };

    salt = mkOption {
      default = null;

      description = ''
        The salt string used to encode JWT tokens, if not set a random value will be generated.
      '';

      example = "3edIYV6c8B28b19fh";
      type = types.nullOr types.str;
    };

    stateDirectoryName = mkOption {
      default = "documize";

      description = ''
        The name of the directory below {file}`/var/lib/private`
        where documize runs in and stores, for example, backups.
      '';

      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.documize-server = {
      description = "Documize Wiki";
      documentation = [ "https://documize.com/" ];

      serviceConfig = {
        DynamicUser = "yes";

        ExecStart = concatStringsSep " " [
          "${cfg.package}/bin/documize"
          (mkParams false [
            "db"
            "dbtype"
            "port"
          ])
          (mkParams true [
            "offline"
            "location"
            "forcesslport"
            "key"
            "cert"
            "salt"
          ])
        ];

        Restart = "always";
        StateDirectory = cfg.stateDirectoryName;
        WorkingDirectory = "/var/lib/${cfg.stateDirectoryName}";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
