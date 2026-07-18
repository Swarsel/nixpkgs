{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.vikunja;
  format = pkgs.formats.yaml { };
  configFile = format.generate "config.yaml" cfg.settings;
  useMysql = cfg.database.type == "mysql";
  usePostgresql = cfg.database.type == "postgres";
in
{
  imports = [
    (mkRemovedOptionModule [ "services" "vikunja" "setupNginx" ]
      "services.vikunja no longer supports the automatic set up of a nginx virtual host. Set up your own webserver config with a proxy pass to the vikunja service."
    )
  ];

  options.services.vikunja = with lib; {
    enable = mkEnableOption "vikunja service";
    package = mkPackageOption pkgs "vikunja" { };

    address = mkOption {
      default = "";
      description = "The IP address to bind to.";
      type = types.str;
    };

    database = {
      database = mkOption {
        default = "vikunja";
        description = "Database name.";
        type = types.str;
      };

      host = mkOption {
        default = "localhost";
        description = "Database host address. Can also be a socket.";
        type = types.str;
      };

      path = mkOption {
        default = "/var/lib/vikunja/vikunja.db";
        description = "Path to the sqlite3 database file.";
        type = types.str;
      };

      type = mkOption {
        default = "sqlite";
        description = "Database engine to use.";
        example = "postgres";

        type = types.enum [
          "sqlite"
          "mysql"
          "postgres"
        ];
      };

      user = mkOption {
        default = "vikunja";
        description = "Database user.";
        type = types.str;
      };
    };

    environmentFiles = mkOption {
      default = [ ];

      description = ''
        List of environment files set in the vikunja systemd service.
        For example passwords should be set in one of these files.
      '';

      type = types.listOf types.path;
    };

    frontendHostname = mkOption {
      description = "The Hostname under which the frontend is running.";
      type = types.str;
    };

    frontendScheme = mkOption {
      description = ''
        Whether the site is available via http or https.
      '';

      type = types.enum [
        "http"
        "https"
      ];
    };

    port = mkOption {
      default = 3456;
      description = "The TCP port exposed by the API.";
      type = types.port;
    };

    settings = mkOption {
      default = { };

      description = ''
        Vikunja configuration. Refer to
        <https://vikunja.io/docs/config-options/>
        for details on supported values.
      '';

      type = format.type;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."vikunja/config.yaml".source = configFile;

    environment.systemPackages = [
      cfg.package # for admin `vikunja` CLI
    ];

    services.vikunja.settings = {
      database = {
        inherit (cfg.database)
          type
          host
          user
          database
          path
          ;
      };

      files = {
        basepath = "/var/lib/vikunja/files";
      };

      service = {
        interface = "${cfg.address}:${toString cfg.port}";
        publicurl = "${cfg.frontendScheme}://${cfg.frontendHostname}/";
      };
    };

    systemd.services.vikunja = {
      after = [
        "network.target"
      ]
      ++ lib.optional usePostgresql "postgresql.target"
      ++ lib.optional useMysql "mysql.service";

      description = "vikunja";
      path = [ cfg.package ];
      restartTriggers = [ configFile ];

      serviceConfig = {
        DynamicUser = true;
        EnvironmentFile = cfg.environmentFiles;
        ExecStart = "${cfg.package}/bin/vikunja";
        Restart = "always";
        StateDirectory = "vikunja";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
