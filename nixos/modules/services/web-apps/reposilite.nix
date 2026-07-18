{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.reposilite;
  format = pkgs.formats.cdn { };
  configFile = format.generate "reposilite.cdn" cfg.settings;

  useEmbeddedDb = cfg.database.type == "sqlite" || cfg.database.type == "h2";
  useMySQL = cfg.database.type == "mariadb" || cfg.database.type == "mysql";
  usePostgres = cfg.database.type == "postgresql";

  # db password is appended at runtime by the service script (if needed)
  dbString =
    if useEmbeddedDb then
      "${cfg.database.type} ${cfg.database.path}"
    else
      "${cfg.database.type} ${cfg.database.host}:${toString cfg.database.port} ${cfg.database.dbname} ${cfg.database.user} $(<${cfg.database.passwordFile})";

  certDir = config.security.acme.certs.${cfg.useACMEHost}.directory;

  databaseModule = {
    options = {
      dbname = lib.mkOption {
        default = "reposilite";

        description = ''
          Database name.
        '';

        type = lib.types.str;
      };

      host = lib.mkOption {
        default = "127.0.0.1";

        description = ''
          Database host address.
        '';

        type = lib.types.str;
      };

      passwordFile = lib.mkOption {
        default = null;

        description = ''
          Path to the file containing the password for the database connection.
          This file must be readable by {option}`services.reposilite.user`.
        '';

        type = lib.types.nullOr lib.types.path;
      };

      path = lib.mkOption {
        default = "reposilite.db";

        description = ''
          Path to the embedded database file. Set to `--temporary` to use an in-memory database.
        '';

        type = lib.types.str;
      };

      port = lib.mkOption {
        default = if usePostgres then config.services.postgresql.settings.port else 3306;

        defaultText = lib.literalExpression ''
          if type == "postgresql" then 5432 else 3306
        '';

        description = ''
          Database TCP port.
        '';

        type = lib.types.port;
      };

      type = lib.mkOption {
        default = "sqlite";

        description = ''
          Database engine to use.
        '';

        type = lib.types.enum [
          "h2"
          "mariadb"
          "mysql"
          "postgresql"
          "sqlite"
        ];
      };

      user = lib.mkOption {
        default = "reposilite";

        description = ''
          Database user.
        '';

        type = lib.types.str;
      };
    };
  };

  settingsModule = {
    options = {
      basePath = lib.mkOption {
        default = "/";

        description = ''
          Custom base path for this Reposilite instance.
          It is not recommended changing this, you should instead prioritize using a different subdomain.
        '';

        type = lib.types.str;
      };

      bypassExternalCache = lib.mkOption {
        default = true;

        description = ''
          Add cache bypass headers to responses from /api/* to avoid issues with proxies such as Cloudflare.
        '';

        type = lib.types.bool;
      };

      cachedLogSize = lib.mkOption {
        default = 50;

        description = ''
          Amount of messages stored in the cache logger.
        '';

        type = lib.types.ints.unsigned;
      };

      compressionStrategy = lib.mkOption {
        default = "none";

        description = ''
          Compression algorithm used by this instance of Reposilite.
          `none` reduces usage of CPU & memory, but requires transfering more data.
        '';

        type = lib.types.enum [
          "none"
          "gzip"
        ];
      };

      database = lib.mkOption {
        default = null;

        description = ''
          Database connection string. Please use {option}`services.reposilite.database` instead.
          See <https://reposilite.com/guide/general#local-configuration> for valid values.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      databaseThreadPool = lib.mkOption {
        default = 1;

        description = ''
          Maximum amount of concurrent connections to the database. (one per thread)
          Embedded databases (sqlite, h2) do not support truly concurrent connections, so the value will always be `1` if they are used.
        '';

        type = lib.types.ints.positive;
      };

      debugEnabled = lib.mkOption {
        default = false;

        description = ''
          Whether to enable debug mode.
        '';

        type = lib.types.bool;
      };

      defaultFrontend = lib.mkOption {
        default = true;

        description = ''
          Whether to enable the default included frontend with a dashboard.
        '';

        type = lib.types.bool;
      };

      enforceSsl = lib.mkOption {
        default = false;

        description = ''
          Whether to redirect all traffic to SSL.
        '';

        type = lib.types.bool;
      };

      hostname = lib.mkOption {
        default = "0.0.0.0";

        description = ''
          The hostname to bind to. Set to `0.0.0.0` to accept connections from everywhere, or `127.0.0.1` to restrict to localhost."
        '';

        example = "127.0.0.1";
        type = lib.types.str;
      };

      idleTimeout = lib.mkOption {
        default = 30000;

        description = ''
          Default idle timeout used by Jetty.
        '';

        type = lib.types.ints.unsigned;
      };

      ioThreadPool = lib.mkOption {
        default = 8;

        description = ''
          The IO thread pool handles all tasks that may benefit from non-blocking IO. (min: 2)
          Because most tasks are redirected to IO thread pool, it might be a good idea to keep it at least equal to web thread pool.
        '';

        type = lib.types.ints.between 2 65535;
      };

      keyPassword = lib.mkOption {
        default = null;

        description = ''
          Plaintext password used to unlock the Java KeyStore set in {option}`services.reposilite.settings.keyPath`.
          WARNING: this option is insecure and should not be used to store the password.
          Consider using {option}`services.reposilite.keyPasswordFile` instead.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      keyPath = lib.mkOption {
        default = null;

        description = ''
          Path to the .jsk KeyStore or paths to the PKCS#8 certificate and private key, separated by a space (see example).
          You can use `''${WORKING_DIRECTORY}` to refer to paths relative to Reposilite's working directory.
          If you are using a Java KeyStore, don't forget to specify the password via the {var}`REPOSILITE_LOCAL_KEYPASSWORD` environment variable.
          See <https://reposilite.com/guide/ssl> for more information on how to set SSL up.
        '';

        example = "\${WORKING_DIRECTORY}/cert.pem \${WORKING_DIRECTORY}/key.pem";
        type = lib.types.nullOr lib.types.str;
      };

      port = lib.mkOption {
        default = 3000;

        description = ''
          The TCP port to bind to.
        '';

        type = lib.types.port;
      };

      sslEnabled = lib.mkOption {
        default = false;

        description = ''
          Whether to listen for encrypted connections on {option}`settings.sslPort`.
        '';

        type = lib.types.bool;
      };

      sslPort = lib.mkOption {
        default = 443;
        description = "SSL port to bind to. SSL needs to be enabled explicitly via {option}`settings.enableSsl`.";
        type = lib.types.port; # cant be null
      };

      webThreadPool = lib.mkOption {
        default = 16;

        description = ''
          Maximum amount of threads used by the core thread pool. (min: 5)
          The web thread pool handles the first few steps of incoming HTTP connections, tasks are redirected as soon as possible to the IO thread pool.
        '';

        type = lib.types.ints.between 5 65535;
      };
    };

    freeformType = format.type;
  };
in
{
  options.services.reposilite = {
    enable = lib.mkEnableOption "Reposilite";

    package = lib.mkPackageOption pkgs "reposilite" { } // {
      apply =
        pkg:
        pkg.override (old: {
          plugins = (old.plugins or [ ]) ++ cfg.plugins;
        });
    };

    database = lib.mkOption {
      default = { };
      description = "Database options.";
      type = lib.types.submodule databaseModule;
    };

    extraArgs = lib.mkOption {
      default = [ ];

      description = ''
        Extra arguments/parameters passed to the Reposilite. Can be used for first token generation.
      '';

      example = lib.literalExpression ''[ "--token" "name:tempsecrettoken" ]'';
      type = lib.types.listOf lib.types.str;
    };

    group = lib.mkOption {
      default = "reposilite";

      description = ''
        The group to run Reposilite under.
      '';

      type = lib.types.str;
    };

    keyPasswordFile = lib.mkOption {
      default = null;

      description = ''
        Path the the file containing the password used to unlock the Java KeyStore file specified in {option}`services.reposilite.settings.keyPath`.
        This file must be readable my {option}`services.reposilite.user`.
      '';

      type = lib.types.nullOr lib.types.path;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Whether to open the firewall ports for Reposilite. If SSL is enabled, its port will be opened too.
      '';

      type = lib.types.bool;
    };

    plugins = lib.mkOption {
      default = [ ];

      description = ''
        List of plugins to add to Reposilite.
      '';

      example = "with reposilitePlugins; [ checksum groovy ]";
      type = lib.types.listOf lib.types.package;
    };

    settings = lib.mkOption {
      default = { };
      description = "Configuration written to the reposilite.cdn file";
      type = lib.types.submodule settingsModule;
    };

    useACMEHost = lib.mkOption {
      default = null;

      description = ''
        Host of an existing Let's Encrypt certificate to use for SSL.
        Make sure that the certificate directory is readable by the `reposilite` user or group, for example via {option}`security.acme.certs.<cert>.group`.
        *Note that this option does not create any certificates, nor it does add subdomains to existing ones – you will need to create them manually using {option}`security.acme.certs`*
      '';

      type = lib.types.nullOr lib.types.str;
    };

    user = lib.mkOption {
      default = "reposilite";

      description = ''
        The user to run Reposilite under.
      '';

      type = lib.types.str;
    };

    workingDirectory = lib.mkOption {
      default = "/var/lib/reposilite";

      description = ''
        Working directory for Reposilite.
      '';

      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.settings.sslEnabled -> cfg.settings.keyPath != null;

        message = ''
          Reposilite was configured to enable SSL, but no valid paths to certificate files were provided via `settings.keyPath`.
          Read more about SSL certificates here: <https://reposilite.com/guide/ssl>
        '';
      }
      {
        assertion = cfg.settings.enforceSsl -> cfg.settings.sslEnabled;
        message = "You cannot enforce SSL if SSL is not enabled.";
      }
      {
        assertion = !useEmbeddedDb -> cfg.database.passwordFile != null;
        message = "You need to set `services.reposilite.database.passwordFile` when using MySQL or Postgres.";
      }
    ];

    environment.systemPackages = [ cfg.package ];

    networking.firewall = lib.mkIf cfg.openFirewall (
      lib.mkMerge [
        {
          allowedTCPPorts = [ cfg.settings.port ];
        }
        (lib.mkIf cfg.settings.sslEnabled {
          allowedTCPPorts = [ cfg.settings.sslPort ];
        })
      ]
    );

    services.reposilite.settings.keyPath = lib.mkIf (
      cfg.useACMEHost != null
    ) "${certDir}/fullchain.pem ${certDir}/key.pem";

    systemd.services.reposilite = {
      enable = true;

      after = [
        "network.target"
      ]
      ++ (lib.optional useMySQL "mysql.service")
      ++ (lib.optional usePostgres "postgresql.target");

      script =
        lib.optionalString (cfg.keyPasswordFile != null && cfg.settings.keyPassword == null) ''
          export REPOSILITE_LOCAL_KEYPASSWORD="$(<${cfg.keyPasswordFile})"
        ''
        + ''
          export REPOSILITE_LOCAL_DATABASE="${dbString}"

          ${lib.getExe cfg.package} --local-configuration ${configFile} --local-configuration-mode none --working-directory ${cfg.workingDirectory} ${lib.escapeShellArgs cfg.extraArgs}
        '';

      serviceConfig = lib.mkMerge [
        (lib.mkIf (dirOf cfg.workingDirectory == "/var/lib") {
          StateDirectory = baseNameOf cfg.workingDirectory;
          StateDirectoryMode = "700";
        })
        {
          AmbientCapabilities = "CAP_NET_BIND_SERVICE";
          Group = cfg.group;
          # TODO better hardening
          LimitNOFILE = "1048576";
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";
          Restart = "on-failure";
          Type = "exec";
          User = cfg.user;
          WorkingDirectory = cfg.workingDirectory;
        }
      ];

      wantedBy = [ "multi-user.target" ];
    };

    users = {
      groups.${cfg.group} = lib.mkIf (cfg.group == "reposilite") { };

      users.${cfg.user} = lib.mkIf (cfg.user == "reposilite") {
        group = cfg.group;
        isSystemUser = true;
      };
    };
  };

  meta.maintainers = [ lib.maintainers.uku3lig ];
}
