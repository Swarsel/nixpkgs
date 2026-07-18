{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.gotosocial;
  settingsFormat = pkgs.formats.yaml { };
  configFile = settingsFormat.generate "config.yml" cfg.settings;
  defaultSettings = {
    application-name = "gotosocial";
    bind-address = "127.0.0.1";
    db-address = "/var/lib/gotosocial/database.sqlite";
    db-type = "sqlite";
    port = 8080;
    protocol = "https";
    storage-local-base-path = "/var/lib/gotosocial/storage";
  };
  gotosocial-admin = pkgs.writeShellScriptBin "gotosocial-admin" ''
    exec systemd-run \
      -u gotosocial-admin.service \
      -p Group=gotosocial \
      -p User=gotosocial \
      -q -t -G --wait --service-type=exec \
      ${cfg.package}/bin/gotosocial --config-path ${configFile} admin "$@"
  '';
in
{
  options.services.gotosocial = {
    enable = lib.mkEnableOption "ActivityPub social network server";
    package = lib.mkPackageOption pkgs "gotosocial" { };

    environmentFile = lib.mkOption {
      default = null;

      description = ''
        File path containing environment variables for configuring the GoToSocial service
        in the format of an EnvironmentFile as described by {manpage}`systemd.exec(5)`.

        This option could be used to pass sensitive configuration to the GoToSocial daemon.

        Please refer to the Environment Variables section in the
        [documentation](https://docs.gotosocial.org/en/latest/configuration/).
      '';

      example = "/root/nixos/secrets/gotosocial.env";
      type = lib.types.nullOr lib.types.path;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Open the configured port in the firewall.
        Using a reverse proxy instead is highly recommended.
      '';

      type = lib.types.bool;
    };

    settings = lib.mkOption {
      default = defaultSettings;

      description = ''
        Contents of the GoToSocial YAML config.

        Please refer to the
        [documentation](https://docs.gotosocial.org/en/latest/configuration/)
        and
        [example config](https://github.com/superseriousbusiness/gotosocial/blob/main/example/config.yaml).

        Please note that the `host` option cannot be changed later so it is important to configure this correctly before you start GoToSocial.
      '';

      example = {
        application-name = "My GoToSocial";
        host = "gotosocial.example.com";
      };

      type = settingsFormat.type;
    };

    setupPostgresqlDB = lib.mkOption {
      default = false;

      description = ''
        Whether to setup a local postgres database and populate the
        `db-type` fields in `services.gotosocial.settings`.
      '';

      type = lib.types.bool;
    };

  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.settings.host or null != null;

        message = ''
          You have to define a hostname for GoToSocial (`services.gotosocial.settings.host`), it cannot be changed later without starting over!
        '';
      }
    ];

    environment.systemPackages = [ gotosocial-admin ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.settings.port ];
    };

    services.gotosocial.settings =
      (lib.mapAttrs (name: lib.mkDefault) (
        defaultSettings
        // {
          web-asset-base-dir = "${cfg.package}/share/gotosocial/web/assets/";
          web-template-base-dir = "${cfg.package}/share/gotosocial/web/template/";
        }
      ))
      // (lib.optionalAttrs cfg.setupPostgresqlDB {
        db-address = "/run/postgresql";
        db-database = "gotosocial";
        db-type = "postgres";
        db-user = "gotosocial";
      });

    services.postgresql = lib.mkIf cfg.setupPostgresqlDB {
      enable = true;
      ensureDatabases = [ "gotosocial" ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "gotosocial";
        }
      ];
    };

    systemd.services.gotosocial = {
      after = [ "network.target" ] ++ lib.optional cfg.setupPostgresqlDB "postgresql.target";
      description = "ActivityPub social network server";
      requires = lib.optional cfg.setupPostgresqlDB "postgresql.target";
      restartTriggers = [ configFile ];

      serviceConfig = {
        # Security options:
        # Based on https://github.com/superseriousbusiness/gotosocial/blob/v0.8.1/example/gotosocial.service
        AmbientCapabilities = lib.optional (cfg.settings.port < 1024) "CAP_NET_BIND_SERVICE";
        DevicePolicy = "closed";
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = "${cfg.package}/bin/gotosocial --config-path ${configFile} server start";
        Group = "gotosocial";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "full";
        Restart = "on-failure";
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "gotosocial";
        User = "gotosocial";
        WorkingDirectory = "/var/lib/gotosocial";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.gotosocial = { };

    users.users.gotosocial = {
      group = "gotosocial";
      isSystemUser = true;
    };
  };

  meta.doc = ./gotosocial.md;
  meta.maintainers = with lib.maintainers; [ blakesmith ];
}
