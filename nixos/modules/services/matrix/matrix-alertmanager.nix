{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.matrix-alertmanager;
  rooms = room: lib.concatStringsSep "/" (room.receivers ++ [ room.roomId ]);
  concatenatedRooms = lib.concatStringsSep "|" (map rooms cfg.matrixRooms);
in
{
  options.services.matrix-alertmanager = {
    enable = lib.mkEnableOption "matrix-alertmanager";
    package = lib.mkPackageOption pkgs "matrix-alertmanager" { };

    homeserverUrl = lib.mkOption {
      description = "URL of the Matrix homeserver to use.";
      example = "https://matrix.example.com";
      type = lib.types.str;
    };

    matrixRooms = lib.mkOption {
      description = ''
        Combination of Alertmanager receiver(s) and rooms for the bot to join.
        Each Alertmanager receiver can be mapped to post to a matrix room.

        Note, you must use a room ID and not a room alias/name. Room IDs start
        with a "!".
      '';

      example = [
        {
          receivers = [
            "receiver1"
            "receiver2"
          ];

          roomId = "!roomid@example.com";
        }
        {
          receivers = [ "receiver3" ];
          roomId = "!differentroomid@example.com";
        }
      ];

      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            receivers = lib.mkOption {
              description = "List of receivers for this room";
              type = lib.types.listOf lib.types.str;
            };

            roomId = lib.mkOption {
              apply =
                x:
                assert lib.assertMsg (lib.hasPrefix "!" x) "Matrix room ID must start with a '!'. Got: ${x}";
                x;

              description = "Matrix room ID";
              type = lib.types.str;
            };
          };
        }
      );
    };

    matrixUser = lib.mkOption {
      description = "Matrix user to use for the bot.";
      example = "@alertmanageruser:example.com";
      type = lib.types.str;
    };

    mention = lib.mkOption {
      default = false;
      description = "Makes the bot mention @room when posting an alert";
      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 3000;
      description = "Port that matrix-alertmanager listens on.";
      type = lib.types.port;
    };

    secretFile = lib.mkOption {
      description = "File that contains a secret for the Alertmanager webhook.";
      type = lib.types.externalPath;
    };

    tokenFile = lib.mkOption {
      description = "File that contains a valid Matrix token for the Matrix user.";
      type = lib.types.externalPath;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.matrix-alertmanager = {
      after = [ "network.target" ];
      description = "A bot to receive Alertmanager webhook events and forward them to chosen rooms.";

      environment = {
        APP_PORT = toString cfg.port;
        MATRIX_HOMESERVER_URL = cfg.homeserverUrl;
        MATRIX_ROOMS = concatenatedRooms;
        MATRIX_USER = cfg.matrixUser;
        MENTION_ROOM = if cfg.mention then "1" else "0";
        NODE_ENV = "production";
      };

      script = ''
        # shellcheck disable=SC2155
        export APP_ALERTMANAGER_SECRET=$(cat "''${CREDENTIALS_DIRECTORY}/secret")
        # shellcheck disable=SC2155
        export MATRIX_TOKEN=$(cat "''${CREDENTIALS_DIRECTORY}/token")
        exec ${lib.getExe cfg.package}
      '';

      serviceConfig = {
        DynamicUser = true;

        LoadCredential = [
          "token:${cfg.tokenFile}"
          "secret:${cfg.secretFile}"
        ];

        Restart = "always";
        RestartSec = "10s";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.erethon ];
}
