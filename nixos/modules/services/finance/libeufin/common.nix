# TODO: create a common module generator for Taler and Libeufin?
libeufinComponent:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.services.libeufin.${libeufinComponent} = {
    enable = lib.mkEnableOption "libeufin core banking system and web interface";
    package = lib.mkPackageOption pkgs "libeufin" { };
    createLocalDatabase = lib.mkEnableOption "automatic creation of a local postgres database";
    debug = lib.mkEnableOption "debug logging";

    openFirewall = lib.mkOption {
      default = false;
      description = "Whether to open ports in the firewall";
      type = lib.types.bool;
    };
  };

  config =
    let
      cfg = cfgMain.${libeufinComponent};
      cfgMain = config.services.libeufin;

      configFile = config.environment.etc."libeufin/libeufin.conf".source;
      serviceName = "libeufin-${libeufinComponent}";
      isNexus = libeufinComponent == "nexus";

      # get database name from config
      # TODO: should this always be the same db? In which case, should this be an option directly under `services.libeufin`?
      dbName =
        lib.removePrefix "postgresql:///"
          cfg.settings."libeufin-${libeufinComponent}db-postgres".CONFIG;

      bankPort = cfg.settings."${if isNexus then "nexus-httpd" else "libeufin-bank"}".PORT;
      bankHost = lib.elemAt (lib.splitString "/" cfg.settings.libeufin-bank.BASE_URL) 2;
    in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion =
            cfg.createLocalDatabase || (cfg.settings."libeufin-${libeufinComponent}db-postgres" ? CONFIG);

          message = "Libeufin ${libeufinComponent} database is not configured.";
        }
      ];

      environment.systemPackages = [ cfg.package ];

      networking.firewall = lib.mkIf cfg.openFirewall {
        allowedTCPPorts = [
          bankPort
        ];
      };

      services.libeufin.settings = cfg.settings;

      services.postgresql = lib.mkIf cfg.createLocalDatabase {
        enable = true;
        ensureDatabases = [ dbName ];

        ensureUsers = [
          { name = serviceName; }
          {
            ensureDBOwnership = true;
            name = dbName;
          }
        ];
      };

      # TODO add system-libeufin.slice?
      systemd.services = {
        # Main service
        "${serviceName}" = {
          after = [ "libeufin-dbinit.service" ];
          requires = [ "libeufin-dbinit.service" ];

          serviceConfig = {
            DynamicUser = true;

            ExecStart =
              let
                args = lib.cli.toCommandLineShellGNU { } {
                  L = if cfg.debug then "debug" else null;
                  c = configFile;
                };
              in
              "${lib.getExe' cfg.package "libeufin-${libeufinComponent}"} serve ${args}";

            Restart = "on-failure";
            RestartSec = "10s";
          };

          wantedBy = [ "multi-user.target" ];
        };

        # Database Initialisation
        libeufin-dbinit =
          let
            dbScript = pkgs.writers.writeText "libeufin-db-permissions.sql" ''
              GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA libeufin_bank TO "${serviceName}";
              GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA libeufin_nexus TO "${serviceName}";
              GRANT USAGE ON SCHEMA libeufin_bank TO "${serviceName}";
              GRANT USAGE ON SCHEMA libeufin_nexus TO "${serviceName}";
            '';

            # Accounts to be created after the bank database initialization.
            #
            # For example, if the bank's currency conversion is enabled, it's
            # required that the exchange account is registered before the
            # service starts.
            initialAccountRegistration = lib.concatMapStringsSep "\n" (
              account:
              let
                args = lib.cli.toCommandLineShellGNU { } {
                  inherit (account) username password name;
                  c = configFile;
                  exchange = lib.toLower account.username == "exchange";
                  payto_uri = "payto://x-taler-bank/${bankHost}/${account.username}?receiver-name=${account.name}";
                };
              in
              "${lib.getExe' cfg.package "libeufin-bank"} create-account ${args}"
            ) cfg.initialAccounts;

            args = lib.cli.toCommandLineShellGNU { } {
              L = if cfg.debug then "debug" else null;
              c = configFile;
            };
          in
          {
            after = [ "network.target" ] ++ lib.optionals cfg.createLocalDatabase [ "postgresql.target" ];

            path = [
              (if cfg.createLocalDatabase then config.services.postgresql.package else pkgs.postgresql)
            ];

            # Grant DB permissions after schemas have been created
            postStart = ''
              psql -U "${dbName}" -f "${dbScript}"
            ''
            + lib.optionalString ((!isNexus) && (cfg.initialAccounts != [ ])) ''
              # only register initial accounts once
              if [ ! -e /var/lib/libeufin-dbinit/init ]; then
                ${initialAccountRegistration}

                touch /var/lib/libeufin-dbinit/init
                echo "Bank initialisation complete"
              fi
            '';

            requires = lib.optionals cfg.createLocalDatabase [ "postgresql.target" ];

            script = lib.optionalString cfg.enable ''
              ${lib.getExe' cfg.package "libeufin-${libeufinComponent}"} dbinit ${args}
            '';

            serviceConfig = {
              DynamicUser = true;
              StateDirectory = "libeufin-dbinit";
              StateDirectoryMode = "0750";
              Type = "oneshot";
              User = dbName;
            };
          };
      };

    };
}
