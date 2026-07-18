{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.linkwarden;
  isPostgresUnixSocket = lib.hasPrefix "/" cfg.database.host;

  inherit (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    ;

  commonServiceConfig = {
    CacheDirectory = "linkwarden";
    # Hardening
    CapabilityBoundingSet = "";
    EnvironmentFile = cfg.environmentFile;
    Group = cfg.group;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateMounts = true;
    PrivateTmp = true;
    PrivateUsers = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    Restart = "on-failure";
    RestartSec = 3;

    RestrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
      "AF_UNIX"
    ];

    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    StateDirectory = "linkwarden";
    Type = "simple";
    User = cfg.user;
  };

  secret = types.nullOr (
    types.str
    // {
      # We don't want users to be able to pass a path literal here but
      # it should look like a path.
      check = it: lib.isString it && lib.types.path.check it;
    }
  );

  startupScript =
    arg:
    if cfg.secretFiles == { } then
      "${lib.getExe cfg.package}" + arg
    else
      pkgs.writeShellScript "linkwarden-env" ''
        ${lib.strings.concatStringsSep "\n" (
          lib.attrsets.mapAttrsToList (key: path: "export ${key}=$(< \"${path}\")") cfg.secretFiles
        )}
        ${lib.getExe cfg.package}${arg}
      '';
in
{
  options.services.linkwarden = {
    enable = mkEnableOption "Linkwarden";
    package = lib.mkPackageOption pkgs "linkwarden" { };

    cacheLocation = mkOption {
      default = "/var/cache/linkwarden";
      description = "Directory used as cache. If it is not the default, the directory has to be created manually such that the linkwarden user is able to read and write to it.";
      type = types.path;
    };

    database = {
      createLocally = mkEnableOption "the automatic creation of the database for Linkwarden." // {
        default = true;
      };

      host = mkOption {
        default = "/run/postgresql";
        description = "Hostname or address of the postgresql server. If an absolute path is given here, it will be interpreted as a unix socket path.";
        example = "localhost";
        type = types.str;
      };

      name = mkOption {
        default = "linkwarden";
        description = "The name of the Linkwarden database.";
        type = types.str;
      };

      port = mkOption {
        default = 5432;
        description = "Port of the postgresql server.";
        type = types.port;
      };

      user = mkOption {
        default = "linkwarden";
        description = "The database user for Linkwarden.";
        type = types.str;
      };
    };

    enableRegistration = mkEnableOption "registration for new users";

    environment = mkOption {
      default = { };

      description = ''
        Extra configuration environment variables. Refer to the [documentation](https://docs.linkwarden.app/self-hosting/environment-variables) for options.
      '';

      example = {
        PAGINATION_TAKE_COUNT = "50";
      };

      type = types.attrsOf types.str;
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        Path of a file with extra environment variables to be loaded from disk.
        This file is not added to the nix store, so it can be used to pass secrets to linkwarden.
        Refer to the [documentation](https://docs.linkwarden.app/self-hosting/environment-variables) for options.

        Linkwarden needs at least a nextauth secret. To set a database password use POSTGRES_PASSWORD:
        ```
        NEXTAUTH_SECRET=<secret>
        POSTGRES_PASSWORD=<pass>
        ```
      '';

      example = "/run/secrets/linkwarden";
      type = secret;
    };

    group = mkOption {
      default = "linkwarden";
      description = "The group Linkwarden should run as.";
      type = types.str;
    };

    host = mkOption {
      default = "localhost";
      description = "The host that Linkwarden will listen on.";
      type = types.str;
    };

    openFirewall = mkOption {
      default = false;
      description = "Whether to open the Linkwarden port in the firewall";
      type = types.bool;
    };

    port = mkOption {
      default = 3000;
      description = "The port that Linkwarden will listen on.";
      type = types.port;
    };

    secretFiles = mkOption {
      default = { };

      description = ''
        Attribute set containing paths to files to add to the environment of linkwarden.
        The files are not added to the nix store, so they can be used to pass secrets to linkwarden.
        Refer to the [documentation](https://docs.linkwarden.app/self-hosting/environment-variables) for options.

        Linkwarden needs at least a nextauth secret. To set a database password use POSTGRES_PASSWORD:
        ```
        NEXTAUTH_SECRET=<secret>
        POSTGRES_PASSWORD=<pass>
        ```
      '';

      example = {
        NEXTAUTH_SECRET = "/run/secrets/linkwarden_secret";
        POSTGRES_PASSWORD = "/run/secrets/linkwarden_postgres_passwd";
      };

      type = types.attrsOf secret;
    };

    storageLocation = mkOption {
      default = "/var/lib/linkwarden";
      description = "Directory used to store media files. If it is not the default, the directory has to be created manually such that the linkwarden user is able to read and write to it.";
      type = types.path;
    };

    user = mkOption {
      default = "linkwarden";
      description = "The user Linkwarden should run as.";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.database.createLocally -> cfg.database.name == cfg.database.user;
        message = "The postgres module requires the database name and the database user name to be the same.";
      }
      {
        assertion = cfg.environmentFile == null -> cfg.secretFiles ? "NEXTAUTH_SECRET";

        message = ''
          Linkwarden needs at least a nextauth secret to run.
          Use either the environmentFile or secretFiles.NEXTAUTH_SECRET to provide one.
        '';
      }
    ];

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    services.linkwarden.environment = {
      DATABASE_HOST = mkIf (!isPostgresUnixSocket) cfg.database.host;
      DATABASE_NAME = cfg.database.name;
      DATABASE_PORT = toString cfg.database.port;
      DATABASE_URL = mkIf isPostgresUnixSocket "postgresql://${lib.strings.escapeURL cfg.database.user}@localhost/${lib.strings.escapeURL cfg.database.name}?host=${cfg.database.host}";
      DATABASE_USER = cfg.database.user;
      LINKWARDEN_CACHE_DIR = cfg.cacheLocation;
      LINKWARDEN_HOST = cfg.host;
      LINKWARDEN_PORT = toString cfg.port;
      NEXT_PUBLIC_DISABLE_REGISTRATION = mkIf (!cfg.enableRegistration) "true";
      NEXT_TELEMETRY_DISABLED = "1";
      STORAGE_FOLDER = cfg.storageLocation;
    };

    services.postgresql = mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ cfg.database.name ];

      ensureUsers = [
        {
          ensureClauses.login = true;
          ensureDBOwnership = true;
          name = cfg.database.user;
        }
      ];
    };

    systemd.services.linkwarden = {
      after = [
        "network-online.target"
      ]
      ++ lib.optionals cfg.database.createLocally [ "postgresql.target" ];

      description = "Linkwarden (Self-hosted collaborative bookmark manager to collect, organize, and preserve webpages, articles, and more...)";

      environment = cfg.environment // {
        # Required, otherwise chrome dumps core
        CHROME_CONFIG_HOME = cfg.cacheLocation;
      };

      requires = [
        "network-online.target"
      ]
      ++ lib.optionals cfg.database.createLocally [ "postgresql.target" ];

      serviceConfig = commonServiceConfig // {
        ExecStart = startupScript "";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.linkwarden-worker = {
      after = [
        "network-online.target"
        "linkwarden.service"
      ]
      ++ lib.optionals cfg.database.createLocally [ "postgresql.target" ];

      description = "Linkwarden (worker process)";

      environment = cfg.environment // {
        # Required, otherwise chrome dumps core
        CHROME_CONFIG_HOME = cfg.cacheLocation;
      };

      requires = [
        "network-online.target"
        "linkwarden.service"
      ]
      ++ lib.optionals cfg.database.createLocally [ "postgresql.target" ];

      serviceConfig = commonServiceConfig // {
        ExecStart = startupScript " worker";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = mkIf (cfg.group == "linkwarden") { linkwarden = { }; };

    users.users = mkIf (cfg.user == "linkwarden") {
      linkwarden = {
        group = cfg.group;
        isSystemUser = true;
        name = "linkwarden";
      };
    };

    meta.maintainers = with lib.maintainers; [ jvanbruegge ];
  };
}
