{
  config,
  lib,
  pkgs,
  ...
}:
let
  defaultDataDir = "/var/lib/mautrix-discord";
  cfg = config.services.mautrix-discord;
  dataDir = cfg.dataDir;
  format = pkgs.formats.yaml { };
  serviceDependencies = [
    "mautrix-discord-registration.service"
  ]
  ++ (lib.lists.optional config.services.matrix-synapse.enable config.services.matrix-synapse.serviceUnit)
  ++ (lib.lists.optional config.services.matrix-conduit.enable "matrix-conduit.service")
  ++ (lib.lists.optional config.services.dendrite.enable "dendrite.service");

  registrationFile = "${dataDir}/discord-registration.yaml";

  settingsFile = "${dataDir}/config.yaml";
  settingsFileUnformatted = format.generate "discord-config-unsubstituted.yaml" cfg.settings;
  default_token = "This value is generated when generating the registration";
  settingsDefault = {
    appservice = {
      address = "http://localhost:29334";
      as_token = default_token;

      bot = {
        avatar = "mxc://maunium.net/nIdEykemnwdisvHbpxflpDlC";
        displayname = "Discord bridge bot";
        username = "discordbot";
      };

      database = {
        type = "sqlite3";
        uri = "file:${defaultDataDir}/mautrix-discord.db?_txlock=immediate";
      };

      hostname = "0.0.0.0";
      hs_token = default_token;
      id = "discord";
      port = 29334;
    };

    bridge.permissions."*" = "relay";

    homeserver = {
      address = "";
      domain = "";
    };

    logging = {
      min_level = "info";

      writers = [
        {
          format = "pretty-colored";
          time_format = " ";
          type = "stdout";
        }
      ];
    };
  };
in
{
  options = {
    services.mautrix-discord = {
      enable = lib.mkEnableOption "Mautrix-Discord, a Matrix-Discord puppeting/relay-bot bridge";
      package = lib.mkPackageOption pkgs "mautrix-discord" { };

      dataDir = lib.mkOption {
        default = defaultDataDir;
        defaultText = defaultDataDir;
        description = "Directory to store the bridge's data.";
        type = lib.types.path;
      };

      # TODO: Get upstream to add an environment File option. Refer to https://github.com/NixOS/nixpkgs/pull/404871#issuecomment-2895663652 and https://github.com/mautrix/discord/issues/187
      environmentFile = lib.mkOption {
        default = null;

        description = ''
          File containing environment variables for secret substitution.
          Variables in the config like `$VARIABLE` will be replaced.
        '';

        type = lib.types.nullOr lib.types.path;
      };

      registerToSynapse = lib.mkOption {
        default = config.services.matrix-synapse.enable;
        defaultText = lib.literalExpression "config.services.matrix-synapse.enable";

        description = ''
          Whether to add the bridge's app service registration file to
          `services.matrix-synapse.settings.app_service_config_files`.
        '';

        type = lib.types.bool;
      };

      settings = lib.mkOption {
        apply = lib.recursiveUpdate settingsDefault;
        default = settingsDefault;

        description = ''
          {file}`config.yaml` configuration as a Nix attribute set.

          Configuration options should match those described in
          [example-config.yaml](https://github.com/mautrix/discord/blob/main/example-config.yaml).

          Secret tokens should be specified using {option}`environmentFile`
          instead of this world-readable attribute set.
        '';

        example = lib.literalExpression ''
          {
            homeserver = {
              address = "http://localhost:8008";
              domain = "example.com";
            };

            bridge.permissions = {
              "example.com" = "user";
              "@admin:example.com" = "admin";
            };
          }
        '';

        type = format.type;
      };

    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion =
          cfg.settings.homeserver.address or "" != "" && cfg.settings.homeserver.domain or "" != "";

        message = "services.mautrix-discord.settings.homeserver.{address,domain} must be set.";
      }
    ];

    services.matrix-synapse = lib.mkIf cfg.registerToSynapse {
      settings.app_service_config_files = [ registrationFile ];
    };

    systemd.services = {
      matrix-synapse = lib.mkIf cfg.registerToSynapse {
        after = [ "mautrix-discord-registration.service" ];

        serviceConfig.SupplementaryGroups = [
          "mautrix-discord"
        ];

        # Make synapse depend on the registration service when auto-registering
        wants = [ "mautrix-discord-registration.service" ];
      };

      mautrix-discord = {
        after = [ "network-online.target" ] ++ serviceDependencies;
        description = "Mautrix-Discord, a Matrix-Discord puppeting/relaybot bridge";

        path = [
          pkgs.lottieconverter
          pkgs.ffmpeg-headless
        ];

        restartTriggers = [ settingsFileUnformatted ];

        serviceConfig = {
          EnvironmentFile = cfg.environmentFile;

          ExecStart = ''
            ${lib.getExe cfg.package} \
              --config='${settingsFile}'
          '';

          Group = "mautrix-discord";
          LockPersonality = true;
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
          ReadWritePaths = [ cfg.dataDir ];
          Restart = "on-failure";
          RestartSec = 30;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallErrorNumber = "EPERM";
          SystemCallFilter = "@system-service";
          Type = "simple";
          UMask = "027";
          User = "mautrix-discord";
          WorkingDirectory = dataDir;
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ] ++ serviceDependencies;
      };

      mautrix-discord-registration = {
        before = lib.mkIf cfg.registerToSynapse [ "matrix-synapse.service" ];
        description = "Mautrix-Discord registration generation service";

        path = [
          pkgs.yq
          pkgs.envsubst
          cfg.package
        ];

        restartTriggers = [ settingsFileUnformatted ];

        script = ''
          # substitute the settings file by environment variables
          # in this case read from EnvironmentFile
          rm -f '${settingsFile}'
          old_umask=$(umask)
          umask 0177

          envsubst -o '${settingsFile}' -i '${settingsFileUnformatted}'

          # Check if config has tokens or uses defaults
          as_token=$(yq -r '.appservice.as_token' '${settingsFile}')
          hs_token=$(yq -r '.appservice.hs_token' '${settingsFile}')
          config_has_tokens=$([[ "$as_token" != "${default_token}" && "$as_token" != "null" && "$hs_token" != "${default_token}" && "$hs_token" != "null" ]] && echo "true" || echo "false")

          if [[ -f '${registrationFile}' ]]; then
            registration_exists="true"
          else
            registration_exists="false"
          fi

          echo "Config has tokens: $config_has_tokens, Registration exists: $registration_exists"

          # If config has default tokens but registration exists, restore tokens from registration
          if [[ $config_has_tokens == "false" && $registration_exists == "true" ]]; then
            echo "Restoring tokens from existing registration"
            yq -sY '.[0].appservice.as_token = .[1].as_token | .[0].appservice.hs_token = .[1].hs_token | .[0]' \
              '${settingsFile}' '${registrationFile}' > '${settingsFile}.tmp'
            mv '${settingsFile}.tmp' '${settingsFile}'
          fi

          # If config has default tokens and no registration exists, generate new tokens
          if [[ $config_has_tokens == "false" && $registration_exists == "false" ]]; then
            echo "Generating new tokens for first-time setup"
            # Generate random tokens (64 character alphanumeric strings)
            new_as_token=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 64)
            new_hs_token=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 64)

            # Save generated tokens to config
            yq -Y ".appservice.as_token = \"$new_as_token\" | .appservice.hs_token = \"$new_hs_token\"" \
              '${settingsFile}' > '${settingsFile}.tmp'
            mv '${settingsFile}.tmp' '${settingsFile}'

            # Verify tokens were replaced
            if [[ $(yq -r '.appservice.as_token' '${settingsFile}') == "${default_token}" ]]; then
              echo "ERROR: Failed to replace default tokens"
              exit 1
            fi
            echo "Successfully generated and saved new tokens"
          fi

          # Generate registration file with tokens from config
          cp '${settingsFile}' '${settingsFile}.tmp'
          echo "Generating registration file"
          mautrix-discord --generate-registration --config='${settingsFile}.tmp' --registration='${registrationFile}'
          rm '${settingsFile}.tmp'

          # Ensure registration file has the same tokens as config (mautrix-discord may regenerate them)
          yq -sY '.[1].as_token = .[0].appservice.as_token | .[1].hs_token = .[0].appservice.hs_token | .[1]' \
            '${settingsFile}' '${registrationFile}' > '${registrationFile}.tmp'
          mv '${registrationFile}.tmp' '${registrationFile}'

          # Application services should not be rate limited by default.
          yq -Y '.rate_limited = false' '${registrationFile}' > '${registrationFile}.tmp'
          mv '${registrationFile}.tmp' '${registrationFile}'

          umask $old_umask
          chmod 640 '${registrationFile}'
        '';

        serviceConfig = {
          EnvironmentFile = cfg.environmentFile;
          Group = "mautrix-discord";
          ProtectHome = true;
          ProtectSystem = "strict";
          ReadWritePaths = [ dataDir ];
          RemainAfterExit = true;
          StateDirectory = "mautrix-discord";
          SystemCallFilter = [ "@system-service" ];
          Type = "oneshot";
          UMask = "027";
          User = "mautrix-discord";
        };

        wantedBy = lib.mkIf cfg.registerToSynapse [ "multi-user.target" ];
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 770 mautrix-discord mautrix-discord -"
    ];

    users.groups.mautrix-discord = { };

    users.users.mautrix-discord = {
      description = "Mautrix-Discord bridge user";
      group = "mautrix-discord";
      home = dataDir;
      isSystemUser = true;
    };

  };

  meta = {
    doc = ./mautrix-discord.md;

    maintainers = with lib.maintainers; [
      mistyttm
    ];
  };
}
