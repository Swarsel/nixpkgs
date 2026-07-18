{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.wakapi;

  settingsFormat = pkgs.formats.yaml { };
  settingsFile = settingsFormat.generate "wakapi-settings" cfg.settings;

  inherit (lib)
    getExe
    mkOption
    mkEnableOption
    mkPackageOption
    types
    mkIf
    optional
    singleton
    mkRemovedOptionModule
    ;
in
{
  imports = [
    (mkRemovedOptionModule [
      "services"
      "wakapi"
      "passwordSalt"
    ] "Use services.wakapi.environmentFiles instead.")
    (mkRemovedOptionModule [
      "services"
      "wakapi"
      "passwordSaltFile"
    ] "Use services.wakapi.environmentFiles instead.")
    (mkRemovedOptionModule [
      "services"
      "wakapi"
      "smtpPassword"
    ] "Use services.wakapi.environmentFiles instead.")
    (mkRemovedOptionModule [
      "services"
      "wakapi"
      "smtpPasswordFile"
    ] "Use services.wakapi.environmentFiles instead.")
  ];

  options.services.wakapi = {
    enable = mkEnableOption "Wakapi";
    package = mkPackageOption pkgs "wakapi" { };

    database = {
      createLocally = mkEnableOption ''
        automatic database configuration.

        ::: {.note}
        Only PostgreSQL is supported for the time being.
        :::
      '';

      dialect = mkOption {
        default = cfg.settings.db.dialect or null; # handle case where dialect is not set

        defaultText = ''
          Database dialect from settings if {option}`services.wakatime.settings.db.dialect`
          is set, or `null` otherwise.
        '';

        description = ''
          The database type to use for Wakapi.
        '';

        type = types.nullOr (
          types.enum [
            "postgres"
            "sqlite3"
            "mysql"
            "cockroach"
            "mssql"
          ]
        );
      };

      name = mkOption {
        default = cfg.settings.db.name or "wakapi";

        defaultText = ''
          Database name from settings if {option}`services.wakatime.settings.db.name`
          is set, or "wakapi" otherwise.
        '';

        description = ''
          The name of the database to use for Wakapi.
        '';

        type = types.str;
      };

      user = mkOption {
        default = cfg.settings.db.user or "wakapi";

        defaultText = ''
          User from settings if {option}`services.wakatime.settings.db.user`
          is set, or "wakapi" otherwise.
        '';

        description = ''
          The name of the user to use for Wakapi.
        '';

        type = types.str;
      };
    };

    environmentFiles = mkOption {
      default = [ ];

      description = ''
        Use this to set `WAKAPI_PASSWORD_SALT` and `WAKAPI_MAIL_SMTP_PASS`.
      '';

      type = types.listOf types.path;
    };

    settings = mkOption {
      inherit (settingsFormat) type;
      default = { };

      description = ''
        Settings for Wakapi.

        See [config.default.yml](https://github.com/muety/wakapi/blob/master/config.default.yml) for a list of all possible options.
      '';
    };

    stateDir = mkOption {
      default = "/var/lib/wakapi";

      description = ''
        The state directory where data is stored. Will also be used as the
        working directory for the wakapi service.
      '';

      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.database.createLocally -> cfg.settings.db.dialect != null;
        message = "`services.wakapi.database.createLocally` is true, but a database dialect is not set!";
      }
    ];

    services.postgresql = mkIf (cfg.database.createLocally && cfg.database.dialect == "postgres") {
      enable = true;

      authentication = ''
        host ${cfg.settings.db.name} ${cfg.settings.db.user} 127.0.0.1/32 trust
      '';

      ensureDatabases = singleton cfg.database.name;

      ensureUsers = singleton {
        ensureDBOwnership = true;
        name = cfg.settings.db.user;
      };
    };

    services.wakapi.settings = {
      env = lib.mkDefault "production";
    };

    systemd.services.wakapi = {
      after = [
        "network-online.target"
      ]
      ++ optional (cfg.database.dialect == "postgres") "postgresql.target";

      description = "Wakapi (self-hosted WakaTime-compatible backend)";

      script = ''
        exec ${getExe cfg.package} -config ${settingsFile}
      '';

      serviceConfig = {
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        DynamicUser = true;
        EnvironmentFile = cfg.environmentFiles;
        Group = config.users.users.wakapi.group;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "full";
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "wakapi";
        StateDirectory = "wakapi";
        StateDirectoryMode = "0700";
        User = config.users.users.wakapi.name;
        WorkingDirectory = cfg.stateDir;
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network-online.target"
      ]
      ++ optional (cfg.database.dialect == "postgres") "postgresql.target";
    };

    users = {
      groups.wakapi = { };

      users.wakapi = {
        createHome = false;
        group = "wakapi";
        isSystemUser = true;
      };
    };

    warnings = lib.optional (cfg.database.createLocally && cfg.settings.db.dialect != "postgres") ''
      You have enabled automatic database configuration, but the database dialect is not set to "postgres".

      The Wakapi module only supports PostgreSQL. Please set `services.wakapi.database.createLocally`
      to `false`, or switch to "postgres" as your database dialect.
    '';
  };

  meta.maintainers = with lib.maintainers; [
    isabelroses
    NotAShelf
  ];
}
