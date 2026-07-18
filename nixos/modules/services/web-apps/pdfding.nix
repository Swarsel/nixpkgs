{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    mapAttrsToList
    mkEnableOption
    mkPackageOption
    mkOption
    optionalAttrs
    optionalString
    types
    ;

  cfg = config.services.pdfding;

  stateDir = "/var/lib/pdfding";

  usePostgres = cfg.database.type == "postgres";

  envVars = {
    DATABASE_TYPE = "";
    DATA_DIR = stateDir;
    # HOST_IP is used in the package derivation
    HOST_IP = cfg.hostName;
    HOST_NAME = concatStringsSep "," cfg.allowedHosts;
    HOST_PORT = toString cfg.port;
  }
  // optionalAttrs usePostgres {
    DATABASE_TYPE = "POSTGRES";
    # Django Uses the unix domain socket
    # if host is set to empty see https://docs.djangoproject.com/en/6.0/ref/settings/#host
    POSTGRES_HOST = lib.optionalString (!cfg.database.createLocally) cfg.database.host;
    POSTGRES_NAME = cfg.database.name;
    POSTGRES_PORT = toString cfg.database.port;
    POSTGRES_USER = cfg.database.user;
  }
  // optionalAttrs cfg.consume.enable {
    CONSUME_ENABLE = "TRUE";
    CONSUME_SCHEDULE = cfg.consume.schedule;
  }
  // optionalAttrs cfg.backup.enable {
    BACKUP_ENABLE = "TRUE";
    BACKUP_ENDPOINT = cfg.backup.endpoint;
    BACKUP_SCHEDULE = cfg.backup.schedule;
  }
  // cfg.extraEnvironment;

  envFile = pkgs.writeText "pdfding.env" (
    lib.pipe envVars [
      (mapAttrsToList (name: value: "${name}=\"${toString value}\""))
      (concatStringsSep "\n")
    ]
  );

  loadCreds =
    optionalString (usePostgres && !cfg.database.createLocally) ''
      export POSTGRES_PASSWORD="$(<${cfg.database.passwordFile})"
    ''
    + ''
      export SECRET_KEY="$(<${cfg.secretKeyFile})"
    '';

  secretRecommendation = "Consider using a secret managing scheme such as `agenix` or `sops-nix` to generate this file.";
in
{
  options.services.pdfding = {
    enable = mkEnableOption "PdfDing service" // {
      description = ''
        Whether to enable PdfDing service.

        To use the pdfding-manage CLI, add your user to the pdfding group:
          users.users.<youruser>.extraGroups = [ "pdfding" ];
      '';
    };

    package = mkPackageOption pkgs "pdfding" { };

    allowedHosts = mkOption {
      default = [
        "127.0.0.1"
        "localhost"
      ];

      description = "Domains where PdfDing is allowed to run";
      type = types.listOf types.str;
    };

    backup = {
      enable = mkEnableOption "Backup functionality" // {
        description = ''
          Automatic backup of important data to a AWS S3 (or compatible) instance.

          When enabled and properly configured via environment variables,
          important data is periodically uploaded to the specified s3
          instance via cronjob.
        '';
      };

      endpoint = mkOption {
        default = null;
        description = "The s3 endpoint for backups";
        example = "127.0.0.1:9000";
        type = types.nullOr types.str;
      };

      schedule = mkOption {
        default = "0 2 * * *";

        description = ''
          The cron schedule for the consume task to trigger.
          The format is "minute hour day month day_of_week"
          Read
            - https://github.com/mrmn2/PdfDing/blob/d0f21ec2f9fbee4b1a2f6b7e0e6c7ea7784ab1bc/pdfding/base/task_helpers.py#L5
            - https://huey.readthedocs.io/en/latest/api.html#crontab
        '';

        type = types.str;
      };
    };

    consume = {
      enable = mkEnableOption "Consume functionality" // {
        description = ''
          Bulk PDF import from consume directory.

          When enabled, administrators can create per-user directories like /var/lib/pdfding/consume/<user_id>
          with permissions allowing the pdfding user to read and write.
          PDFs placed in these directories are automatically imported into user accounts.

          PDFs are imported periodically via cronjob and successfully imported files
          are automatically deleted from the consume directory.
        '';
      };

      schedule = mkOption {
        default = "*/5 * * * *";

        description = ''
          The cron schedule for the consume task to trigger.
          The format is "minute hour day month day_of_week"
          Read
            - https://github.com/mrmn2/PdfDing/blob/d0f21ec2f9fbee4b1a2f6b7e0e6c7ea7784ab1bc/pdfding/base/task_helpers.py#L5
            - https://huey.readthedocs.io/en/latest/api.html#crontab
        '';

        type = types.str;
      };
    };

    database = {
      createLocally = mkOption {
        default = false;
        description = "Whether to create a local PostgreSQL database automatically";
        type = types.bool;
      };

      host = mkOption {
        default = "";
        description = "PostgreSQL host";
        type = types.str;
      };

      name = mkOption {
        default = "pdfding";
        description = "PostgreSQL database name";
        type = types.str;
      };

      passwordFile = mkOption {
        default = null;
        description = "File containing POSTGRES_PASSWORD. ${secretRecommendation}";
        example = "/run/secrets/pdfding-db-password";
        type = types.nullOr types.path;
      };

      port = mkOption {
        default = 5432;
        description = "PostgreSQL port";
        type = types.port;
      };

      type = mkOption {
        default = "sqlite";
        description = "Database type to use";

        type = types.enum [
          "sqlite"
          "postgres"
        ];
      };

      user = mkOption {
        default = "pdfding";
        description = "PostgreSQL user";
        type = types.str;
      };
    };

    envFiles = mkOption {
      default = [ ];
      description = "Environment variable files";
      type = types.listOf types.path;
    };

    extraEnvironment = mkOption {
      default = { };
      description = "Additional environment variables";
      type = types.attrsOf types.str;
    };

    group = mkOption {
      default = "pdfding";
      description = "Group under which PdfDing runs";
      type = types.str;
    };

    gunicorn.extraArgs = mkOption {
      default = [ ];
      description = "Command line arguments passed to Gunicorn server.";
      type = types.listOf types.str;
    };

    hostName = mkOption {
      default = "0.0.0.0";
      description = "Listen address for PdfDing";
      example = "pdfding.example.com";
      type = types.str;
    };

    installTestHelpers = mkOption {
      default = false;
      description = "Adds a few helper commands to systemPackages for nixos tests";
      internal = true;
      type = types.bool;
    };

    openFirewall = lib.mkOption {
      default = false;
      description = "Open ports in the firewall for the PdfDing web interface.";
      type = types.bool;
    };

    port = mkOption {
      default = 8000;
      description = "Port on which PdfDing listens";
      type = types.port;
    };

    secretKeyFile = mkOption {
      default = null;
      description = "File containing the Django SECRET_KEY. ${secretRecommendation}";
      example = "/run/secrets/pdfding-secret-key";
      type = types.path;
    };

    user = mkOption {
      default = "pdfding";
      description = "User account under which PdfDing runs";
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.secretKeyFile != null;
        message = "services.pdfding.secretKeyFile must be set when using PdfDing";
      }
      {
        assertion = cfg.backup.enable -> envVars.BACKUP_ENDPOINT != null;
        message = "services.pdfding.extraEnvironment.BACKUP_ENDPOINT must be set when backup is enabled";
      }
      {
        assertion = cfg.database.createLocally -> usePostgres;
        message = "services.pdfding.database.createLocally is enabled but not database.type is not postgres";
      }
      {
        assertion = cfg.database.createLocally -> cfg.database.host == "";
        message = "services.pdfding.database.host must be empty when services.pdfding.database.createLocally is enabled";
      }
      {
        assertion = cfg.database.createLocally -> cfg.database.passwordFile == null;
        message = "specifying services.pdfding.database.passwordFile is not supported when used along with a local db setup";
      }
      {
        assertion =
          cfg.database.createLocally
          -> cfg.database.user == cfg.user && cfg.database.user == cfg.database.name;

        message = "services.pdfding.database.user should be the same as services.pdfding.user as well as services.pdfding.database.name when running a local db setup";
      }
    ];

    environment.systemPackages =
      let
        genWrapper =
          name: cmd:
          pkgs.writeShellScriptBin name ''
            set -eou pipefail
            set -a
            ${lib.toShellVars cfg.extraEnvironment}
            ${lib.concatMapStringsSep "\n" (f: "source ${f}") cfg.envFiles}
            set +a
            ${loadCreds}
            sudo=exec
            if [[ "$USER" != ${cfg.user} ]]; then
              sudo='${config.security.wrapperDir}/sudo -E -u ${cfg.user}'
            fi
            ${cmd}
          '';
        commands.pdfding-manage = ''
          $sudo ${lib.getExe cfg.package} "$@"
        '';
        commands.consume-immediate = ''
          echo "from pdf.tasks import consume_function; consume_function(True)" | \
            $sudo ${lib.getExe cfg.package} shell
        '';
        commands.backup-immediate = ''
          echo "from backup.tasks import backup_function; backup_function()" | \
            $sudo ${lib.getExe cfg.package} shell
        '';
        packages = lib.genAttrs (lib.attrNames commands) (name: genWrapper name commands.${name});
      in
      lib.mkMerge [
        [
          packages.pdfding-manage
        ]
        (lib.mkIf cfg.installTestHelpers [
          packages.consume-immediate
          packages.backup-immediate
        ])
      ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    services.pdfding.envFiles = [ envFile ];

    services.pdfding.extraEnvironment = {
      DEFAULT_THEME = "dark";
      DEFAULT_THEME_COLOR = "green";
    };

    services.pdfding.gunicorn.extraArgs = [
      "--workers=4"
      "--max-requests=1200"
      "--max-requests-jitter=50"
      "--log-level=error"
    ];

    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ cfg.database.name ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = cfg.database.user;
        }
      ];
    };

    systemd.services.pdfding = {
      after = [
        "network.target"
      ]
      ++ lib.optionals (usePostgres && cfg.database.createLocally) [ "postgresql.target" ];

      description = "PdfDing Web Service";

      preStart = ''
        ${loadCreds}
        ${optionalString (usePostgres && cfg.database.createLocally)
          # bash
          ''
            count=0
            timeout=30
            until ${pkgs.postgresql}/bin/pg_isready -p ${toString cfg.database.port}; do
              if [ $count -ge $timeout ]; then
                echo "Timed out waiting for PostgreSQL after $timeout seconds."
                exit 1
              fi
              echo "Waiting for PostgreSQL... ($count/$timeout)"
              sleep 1
              count=$((count+1))
            done
          ''
        }

        ${cfg.package}/bin/pdfding-manage migrate
        ${cfg.package}/bin/pdfding-manage clean_up
      '';

      script = ''
        ${loadCreds}
        exec ${cfg.package}/bin/pdfding-start ${toString cfg.gunicorn.extraArgs}
      '';

      serviceConfig = {
        EnvironmentFile = cfg.envFiles;
        Group = cfg.group;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestartSec = "5s";

        StateDirectory = [
          "pdfding"
          "pdfding/db"
          "pdfding/media"
        ]
        ++ lib.optional cfg.consume.enable "pdfding/consume";

        Type = "exec";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.pdfding-background = lib.mkIf (cfg.consume.enable || cfg.backup.enable) {
      after = [ "pdfding.service" ];
      description = "PdfDing Background Tasks (Huey)";

      script = ''
        ${loadCreds}
        exec ${cfg.package}/bin/pdfding-manage run_huey
      '';

      serviceConfig = {
        EnvironmentFile = cfg.envFiles;
        Group = cfg.group;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ stateDir ];
        Restart = "on-failure";
        RestartSec = "5s";
        TimeoutStopSec = 30;
        Type = "exec";
        User = cfg.user;
        WorkingDirectory = stateDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      group = cfg.group;
      isSystemUser = true;
    };
  };

  meta.maintainers = lib.teams.ngi.members;
}
