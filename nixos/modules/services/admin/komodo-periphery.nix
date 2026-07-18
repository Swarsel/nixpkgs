{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.komodo-periphery;
  settingsFormat = pkgs.formats.toml { };

  genFinalSettings =
    let
      baseSettings = {
        bind_ip = cfg.bindIp;
        port = cfg.port;
        repo_dir = "${cfg.rootDirectory}/repos";
        root_directory = cfg.rootDirectory;
        ssl_enabled = cfg.ssl.enable;
        stack_dir = "${cfg.rootDirectory}/stacks";
      }
      // lib.optionalAttrs cfg.ssl.enable {
        ssl_cert_file = cfg.ssl.certFile;
        ssl_key_file = cfg.ssl.keyFile;
      }
      // {
        allowed_ips = cfg.allowedIps;
        container_stats_polling_rate = cfg.containerStatsPollingRate;
        disable_container_exec = cfg.disableContainerExec;
        disable_terminals = cfg.disableTerminals;
        exclude_disk_mounts = cfg.excludeDiskMounts;
        include_disk_mounts = cfg.includeDiskMounts;
        legacy_compose_cli = cfg.legacyComposeCli;

        logging = {
          level = cfg.logging.level;
          stdio = cfg.logging.stdio;
        }
        // lib.optionalAttrs (cfg.logging.otlpEndpoint != "") {
          otlp_endpoint = cfg.logging.otlpEndpoint;
        };

        passkeys = cfg.passkeys;
        stats_polling_rate = cfg.statsPollingRate;
      }
      // cfg.extraSettings;
    in
    lib.filterAttrsRecursive (_: v: v != null && v != { } && v != [ ]) baseSettings;

  configFile =
    if cfg.configFile == null then
      settingsFormat.generate "komodo-periphery.toml" genFinalSettings
    else
      cfg.configFile;
in
{
  options.services.komodo-periphery = {
    enable = lib.mkEnableOption "Periphery, a multi-server Docker and Git deployment agent by Komodo";
    package = lib.mkPackageOption pkgs "komodo" { };

    allowedIps = lib.mkOption {
      default = [ ];
      description = "IP addresses or subnets allowed to call the periphery API. Empty list allows all.";

      example = [
        "::ffff:12.34.56.78"
        "10.0.10.0/24"
      ];

      type = lib.types.listOf lib.types.str;
    };

    bindIp = lib.mkOption {
      default = "[::]";
      description = "IP address to bind to.";
      type = lib.types.str;
    };

    configFile = lib.mkOption {
      default = null;
      description = "Path to the periphery configuration file. If null, a configuration file will be generated from the module options.";

      example = lib.literalExpression ''
        pkgs.writeText "periphery.toml" '''
          port = 8120
          bind_ip = "[::]"
          ssl_enabled = true
          [logging]
          level = "info"
        '''
      '';

      type = lib.types.nullOr lib.types.path;
    };

    containerStatsPollingRate = lib.mkOption {
      default = "30-sec";
      description = "Container stats polling interval.";
      example = "1-min";
      type = lib.types.str;
    };

    disableContainerExec = lib.mkOption {
      default = false;
      description = "Disable remote container shell access through Periphery.";
      type = lib.types.bool;
    };

    disableTerminals = lib.mkOption {
      default = false;
      description = "Disable remote shell access through Periphery.";
      type = lib.types.bool;
    };

    environment = lib.mkOption {
      default = { };
      description = "Environment variables to set for the service.";

      example = {
        DOCKER_HOST = "unix:///var/run/docker.sock";
        RUST_LOG = "komodo=debug";
      };

      type = lib.types.attrsOf lib.types.str;
    };

    environmentFile = lib.mkOption {
      default = null;
      description = "Environment file for additional configuration via environment variables.";
      example = "/run/secrets/komodo-periphery.env";
      type = lib.types.nullOr lib.types.path;
    };

    excludeDiskMounts = lib.mkOption {
      default = [ ];
      description = "Exclude these mount paths from disk reporting.";

      example = [
        "/tmp"
        "/boot"
      ];

      type = lib.types.listOf lib.types.str;
    };

    extraSettings = lib.mkOption {
      default = { };
      description = "Extra settings to add to the generated TOML config.";

      example = {
        secrets.GITHUB_TOKEN = "ghp_xxxx";
      };

      type = settingsFormat.type;
    };

    group = lib.mkOption {
      default = "komodo-periphery";
      description = "Group under which the Periphery agent runs.";
      type = lib.types.str;
    };

    includeDiskMounts = lib.mkOption {
      default = [ ];
      description = "Only include these mount paths in disk reporting.";

      example = [
        "/mnt/data"
        "/mnt/backup"
      ];

      type = lib.types.listOf lib.types.str;
    };

    legacyComposeCli = lib.mkOption {
      default = false;
      description = "Use `docker-compose` instead of `docker compose`.";
      type = lib.types.bool;
    };

    logging = {
      level = lib.mkOption {
        default = "info";
        description = "Logging verbosity level.";

        type = lib.types.enum [
          "off"
          "error"
          "warn"
          "info"
          "debug"
          "trace"
        ];
      };

      otlpEndpoint = lib.mkOption {
        default = "";
        description = "OpenTelemetry OTLP endpoint for traces.";
        example = "http://localhost:4317";
        type = lib.types.str;
      };

      stdio = lib.mkOption {
        default = "standard";
        description = "Logging format for stdout/stderr.";

        type = lib.types.enum [
          "standard"
          "json"
          "none"
        ];
      };
    };

    passkeys = lib.mkOption {
      default = [ ];

      description = ''
        Passkeys required to access the periphery API.
        WARNING: These will be stored in the Nix store in plain text!
      '';

      example = [ "your-secure-passkey" ];
      type = lib.types.listOf lib.types.str;
    };

    port = lib.mkOption {
      default = 8120;
      description = "Port for the Periphery agent to listen on.";
      type = lib.types.port;
    };

    rootDirectory = lib.mkOption {
      default = "/var/lib/komodo-periphery";
      description = "Root directory for Komodo Periphery data.";
      type = lib.types.path;
    };

    ssl = {
      enable = lib.mkEnableOption "SSL/TLS support" // {
        default = true;
      };

      certFile = lib.mkOption {
        default = "${cfg.rootDirectory}/ssl/cert.pem";
        defaultText = lib.literalExpression ''"''${config.services.komodo-periphery.rootDirectory}/ssl/cert.pem"'';
        description = "Path to SSL certificate file.";
        type = lib.types.path;
      };

      keyFile = lib.mkOption {
        default = "${cfg.rootDirectory}/ssl/key.pem";
        defaultText = lib.literalExpression ''"''${config.services.komodo-periphery.rootDirectory}/ssl/key.pem"'';
        description = "Path to SSL key file.";
        type = lib.types.path;
      };
    };

    statsPollingRate = lib.mkOption {
      default = "5-sec";
      description = "System stats polling interval.";
      example = "10-sec";
      type = lib.types.str;
    };

    user = lib.mkOption {
      default = "komodo-periphery";
      description = "User under which the Periphery agent runs.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.komodo-periphery = {
      after = [
        "network-online.target"
        "docker.service"
      ];

      description = "Komodo Periphery - Multi-server Docker and Git deployment agent";

      serviceConfig = {
        Environment = lib.mapAttrsToList (name: value: "${name}=${value}") (
          cfg.environment
          // lib.optionalAttrs (!cfg.disableTerminals) {
            PATH = "/run/current-system/sw/bin:/run/wrappers/bin";
          }
        );

        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;

        ExecStart = lib.escapeShellArgs [
          "${lib.getExe' cfg.package "periphery"}"
          "--config-path"
          (if cfg.configFile != null then cfg.configFile else configFile)
        ];

        Group = cfg.group;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "full";
        Restart = "on-failure";
        RestartSec = "10s";
        StateDirectory = "komodo-periphery";
        StateDirectoryMode = "0755";
        SupplementaryGroups = [ "docker" ];
        Type = "simple";
        User = cfg.user;
        WorkingDirectory = cfg.rootDirectory;
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network-online.target"
        "docker.service"
      ];
    };

    systemd.tmpfiles.settings."10-komodo-periphery" = {
      "${cfg.rootDirectory}".d = {
        group = cfg.group;
        mode = "0755";
        user = cfg.user;
      };

      "${cfg.rootDirectory}/repos".d = {
        group = cfg.group;
        mode = "0755";
        user = cfg.user;
      };

      "${cfg.rootDirectory}/ssl".d = {
        group = cfg.group;
        mode = "0700";
        user = cfg.user;
      };

      "${cfg.rootDirectory}/stacks".d = {
        group = cfg.group;
        mode = "0755";
        user = cfg.user;
      };
    };

    users.groups.${cfg.group} = lib.mkIf (cfg.group == "komodo-periphery") { };

    users.users.${cfg.user} = lib.mkIf (cfg.user == "komodo-periphery") {
      description = "Komodo Periphery service user";
      extraGroups = [ "docker" ];
      group = cfg.group;
      home = cfg.rootDirectory;
      isSystemUser = true;
    };

    virtualisation.docker.enable = true;
  };

  meta.maintainers = with lib.maintainers; [ channinghe ];
}
