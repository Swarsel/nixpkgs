{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mautrix-signal;
  dataDir = "/var/lib/mautrix-signal";
  registrationFile = "${dataDir}/signal-registration.yaml";
  settingsFile = "${dataDir}/config.yaml";
  settingsFileUnsubstituted = settingsFormat.generate "mautrix-signal-config-unsubstituted.json" cfg.settings;
  settingsFormat = pkgs.formats.json { };
  appservicePort = 29328;

  # to be used with a list of lib.mkIf values
  optOneOf = lib.lists.findFirst (value: value.condition) (lib.mkIf false null);
  mkDefaults = lib.mapAttrsRecursive (n: v: lib.mkDefault v);
  defaultConfig = {
    appservice = {
      as_token = "";

      bot = {
        displayname = "Signal Bridge Bot";
        username = "signalbot";
      };

      hostname = "[::]";
      hs_token = "";
      id = "signal";
      port = appservicePort;
      username_template = "signal_{{.}}";
    };

    bridge = {
      command_prefix = "!signal";
      permissions."*" = "relay";
      relay.enabled = true;
    };

    database = {
      type = "sqlite3";
      uri = "file:${dataDir}/mautrix-signal.db?_txlock=immediate";
    };

    direct_media.server_key = "";

    double_puppet = {
      secrets = { };
      servers = { };
    };

    # By default, the following keys/secrets are set to `generate`. This would break when the service
    # is restarted, since the previously generated configuration will be overwritten everytime.
    # If encryption is enabled, it's recommended to set those keys via `environmentFile`.
    encryption.pickle_key = "";
    homeserver.address = "http://localhost:8448";

    logging = {
      min_level = "info";

      writers = lib.singleton {
        format = "pretty-colored";
        time_format = " ";
        type = "stdout";
      };
    };

    network = {
      displayname_template = "{{or .ProfileName .PhoneNumber \"Unknown user\"}}";
    };

    provisioning.shared_secret = "";
    public_media.signing_key = "";
  };

in
{
  options.services.mautrix-signal = {
    enable = lib.mkEnableOption "mautrix-signal, a Matrix-Signal puppeting bridge";
    package = lib.mkPackageOption pkgs "mautrix-signal" { };

    environmentFile = lib.mkOption {
      default = null;

      description = ''
        File containing environment variables to be passed to the mautrix-signal service.
        If an environment variable `MAUTRIX_SIGNAL_BRIDGE_LOGIN_SHARED_SECRET` is set,
        then its value will be used in the configuration file for the option
        `double_puppet.secrets` without leaking it to the store, using the configured
        `homeserver.domain` as key.
      '';

      type = lib.types.nullOr lib.types.path;
    };

    registerToSynapse = lib.mkOption {
      default = config.services.matrix-synapse.enable;

      defaultText = lib.literalExpression ''
        config.services.matrix-synapse.enable
      '';

      description = ''
        Whether to add the bridge's app service registration file to
        `services.matrix-synapse.settings.app_service_config_files`.
      '';

      type = lib.types.bool;
    };

    serviceDependencies = lib.mkOption {
      default =
        (lib.optional config.services.matrix-synapse.enable config.services.matrix-synapse.serviceUnit)
        ++ (lib.optional config.services.matrix-conduit.enable "conduit.service");

      defaultText = lib.literalExpression ''
        (optional config.services.matrix-synapse.enable config.services.matrix-synapse.serviceUnit)
        ++ (optional config.services.matrix-conduit.enable "conduit.service")
      '';

      description = ''
        List of systemd units to require and wait for when starting the application service.
      '';

      type = with lib.types; listOf str;
    };

    settings = lib.mkOption {
      apply = lib.recursiveUpdate defaultConfig;
      default = defaultConfig;

      description = ''
        {file}`config.yaml` configuration as a Nix attribute set.
        Configuration options should match those described in the example configuration.
        Get an example configuration by executing `mautrix-signal -c example.yaml --generate-example-config`
        Secret tokens should be specified using {option}`environmentFile`
        instead of this world-readable attribute set.
      '';

      example = {
        appservice = {
          ephemeral_events = false;
          id = "signal";
        };

        backfill.enabled = true;

        bridge = {
          mute_only_on_create = false;

          permissions = {
            "example.com" = "user";
          };

          private_chat_portal_meta = true;
        };

        database = {
          type = "postgres";
          uri = "postgresql:///mautrix_signal?host=/run/postgresql";
        };

        encryption = {
          allow = true;
          default = true;
          pickle_key = "$ENCRYPTION_PICKLE_KEY";
          require = true;
        };

        homeserver = {
          address = "http://[::1]:8008";
          domain = "my-domain.tld";
        };

        matrix.message_status_events = true;

        provisioning = {
          shared_secret = "disable";
        };
      };

      type = settingsFormat.type;
    };
  };

  config = lib.mkIf cfg.enable {

    services.matrix-synapse = lib.mkIf cfg.registerToSynapse {
      settings.app_service_config_files = [ registrationFile ];
    };

    # Note: this is defined here to avoid the docs depending on `config`
    services.mautrix-signal.settings.homeserver = optOneOf (
      with config.services;
      [
        (lib.mkIf matrix-synapse.enable (mkDefaults {
          domain = matrix-synapse.settings.server_name;
        }))
        (lib.mkIf matrix-conduit.enable (mkDefaults {
          address = "http://localhost:${toString matrix-conduit.settings.global.port}";
          domain = matrix-conduit.settings.global.server_name;
        }))
      ]
    );

    systemd.services.matrix-synapse = lib.mkIf cfg.registerToSynapse {
      serviceConfig.SupplementaryGroups = [ "mautrix-signal" ];
    };

    systemd.services.mautrix-signal = {
      after = [ "network-online.target" ] ++ cfg.serviceDependencies;
      description = "mautrix-signal, a Matrix-Signal puppeting bridge.";
      # ffmpeg is required for conversion of voice messages
      path = [ pkgs.ffmpeg-headless ];

      preStart = ''
        # substitute the settings file by environment variables
        # in this case read from EnvironmentFile
        test -f '${settingsFile}' && rm -f '${settingsFile}'
        old_umask=$(umask)
        umask 0177
        ${pkgs.envsubst}/bin/envsubst \
          -o '${settingsFile}' \
          -i '${settingsFileUnsubstituted}'
        umask $old_umask

        # generate the appservice's registration file if absent
        if [ ! -f '${registrationFile}' ]; then
          ${cfg.package}/bin/mautrix-signal \
            --generate-registration \
            --config='${settingsFile}' \
            --registration='${registrationFile}'
        fi
        chmod 640 ${registrationFile}

        umask 0177
        # 1. Overwrite registration tokens in config
        # 2. If environment variable MAUTRIX_SIGNAL_BRIDGE_LOGIN_SHARED_SECRET
        #    is set, set it as the login shared secret value for the configured
        #    homeserver domain.
        ${pkgs.yq}/bin/yq -s '.[0].appservice.as_token = .[1].as_token
          | .[0].appservice.hs_token = .[1].hs_token
          | .[0]
          | if env.MAUTRIX_SIGNAL_BRIDGE_LOGIN_SHARED_SECRET then .double_puppet.secrets.[.homeserver.domain] = env.MAUTRIX_SIGNAL_BRIDGE_LOGIN_SHARED_SECRET else . end' \
          '${settingsFile}' '${registrationFile}' > '${settingsFile}.tmp'
        mv '${settingsFile}.tmp' '${settingsFile}'
        umask $old_umask
      '';

      restartTriggers = [ settingsFileUnsubstituted ];

      serviceConfig = {
        EnvironmentFile = cfg.environmentFile;

        ExecStart = ''
          ${cfg.package}/bin/mautrix-signal \
          --config='${settingsFile}' \
          --registration='${registrationFile}'
        '';

        Group = "mautrix-signal";
        LockPersonality = true;
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
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestartSec = "30s";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = baseNameOf dataDir;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = [ "@system-service" ];
        Type = "simple";
        UMask = 27;
        User = "mautrix-signal";
        WorkingDirectory = dataDir;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ] ++ cfg.serviceDependencies;
    };

    users.groups.mautrix-signal = { };

    users.users.mautrix-signal = {
      description = "Mautrix-Signal bridge user";
      group = "mautrix-signal";
      home = dataDir;
      isSystemUser = true;
    };
  };

  meta = {
    buildDocsInSandbox = false;
    doc = ./mautrix-signal.md;

    maintainers = with lib.maintainers; [
      pentane
      frederictobiasc
    ];
  };
}
