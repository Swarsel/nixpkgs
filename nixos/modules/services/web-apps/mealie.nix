{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mealie;
  pkg = cfg.package;
in
{
  options.services.mealie = {
    enable = lib.mkEnableOption "Mealie, a recipe manager and meal planner";
    package = lib.mkPackageOption pkgs "mealie" { };

    credentialsFile = lib.mkOption {
      default = null;

      description = ''
        File containing credentials used in mealie such as {env}`POSTGRES_PASSWORD`
        or sensitive LDAP options.

        Expects the format of an `EnvironmentFile=`, as described by {manpage}`systemd.exec(5)`.
      '';

      example = "/run/secrets/mealie-credentials.env";
      type = with lib.types; nullOr path;
    };

    database = {
      createLocally = lib.mkOption {
        default = false;

        description = ''
          Configure local PostgreSQL database server for Mealie.
        '';

        type = lib.types.bool;
      };
    };

    extraOptions = lib.mkOption {
      default = [ ];

      description = ''
        Specifies extra command line arguments to pass to mealie (Gunicorn).
      '';

      example = [
        "--log-level"
        "debug"
      ];

      type = lib.types.listOf lib.types.str;
    };

    listenAddress = lib.mkOption {
      default = "0.0.0.0";
      description = "Address on which the service should listen.";
      type = lib.types.str;
    };

    port = lib.mkOption {
      default = 9000;
      description = "Port on which to serve the Mealie service.";
      type = lib.types.port;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration of the Mealie service.

        See [the mealie documentation](https://nightly.mealie.io/documentation/getting-started/installation/backend-config/) for available options and default values.
      '';

      example = {
        ALLOW_SIGNUP = "false";
      };

      type = with lib.types; attrsOf anything;
    };
  };

  config = lib.mkIf cfg.enable {
    services.mealie.settings = lib.mkIf cfg.database.createLocally {
      DB_ENGINE = "postgres";
      POSTGRES_URL_OVERRIDE = "postgresql://mealie:@/mealie?host=/run/postgresql";
    };

    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ "mealie" ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "mealie";
        }
      ];
    };

    systemd.services.mealie = {
      after = [ "network-online.target" ] ++ lib.optional cfg.database.createLocally "postgresql.target";
      description = "Mealie, a self hosted recipe manager and meal planner";

      environment = {
        API_PORT = toString cfg.port;
        BASE_URL = "http://localhost:${toString cfg.port}";
        DATA_DIR = "/var/lib/mealie";
        NLTK_DATA = pkgs.nltk-data.averaged-perceptron-tagger-eng;
        PRODUCTION = "true";
      }
      // (builtins.mapAttrs (_: val: toString val) cfg.settings);

      requires = lib.optional cfg.database.createLocally "postgresql.target";

      serviceConfig = {
        DynamicUser = true;
        EnvironmentFile = lib.mkIf (cfg.credentialsFile != null) cfg.credentialsFile;
        ExecStart = "${lib.getExe pkg} -b ${cfg.listenAddress}:${toString cfg.port} ${lib.escapeShellArgs cfg.extraOptions}";
        ExecStartPre = "${pkg}/libexec/init_db";
        StandardOutput = "journal";
        StateDirectory = "mealie";
        User = "mealie";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
