{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types mkIf;
  cfg = config.services.screego;
  defaultSettings = {
    SCREEGO_AUTH_MODE = "turn";
    SCREEGO_CLOSE_ROOM_WHEN_OWNER_LEAVES = "true";
    SCREEGO_LOG_LEVEL = "info";
    SCREEGO_SERVER_ADDRESS = "127.0.0.1:5050";
    SCREEGO_SESSION_TIMEOUT_SECONDS = "0";
    SCREEGO_TURN_ADDRESS = "0.0.0.0:3478";
    SCREEGO_TURN_PORT_RANGE = "50000:55000";
  };
in
{
  options.services.screego = {

    enable = lib.mkEnableOption "screego screen-sharing server for developers";

    environmentFile = mkOption {
      default = null;

      description = ''
        Environment file (see {manpage}`systemd.exec(5)` "EnvironmentFile="
        section for the syntax) passed to the service. This option can be
        used to safely include secrets in the configuration.
      '';

      example = "/run/secrets/screego-envfile";
      type = with types; nullOr path;
    };

    openFirewall = mkOption {
      default = false;

      description = ''
        Open the firewall port(s).
      '';

      type = types.bool;
    };

    settings = lib.mkOption {
      default = defaultSettings;

      description = ''
        Screego settings passed as Nix attribute set, they will be merged with
        the defaults. Settings will be passed as environment variables.

        See <https://screego.net/#/config> for possible values
      '';

      example = {
        SCREEGO_EXTERNAL_IP = "dns:example.com";
      };

      type = types.attrsOf types.str;
    };
  };

  config =
    let
      # User-provided settings should be merged with default settings,
      # overwriting where necessary
      mergedConfig = defaultSettings // cfg.settings;
      turnUDPPorts = lib.splitString ":" mergedConfig.SCREEGO_TURN_PORT_RANGE;
      turnPort = lib.toInt (builtins.elemAt (lib.splitString ":" mergedConfig.SCREEGO_TURN_ADDRESS) 1);
    in
    mkIf (cfg.enable) {

      networking.firewall = lib.mkIf cfg.openFirewall {
        allowedTCPPorts = [ turnPort ];

        allowedUDPPortRanges = [
          {
            from = lib.toInt (builtins.elemAt turnUDPPorts 0);
            to = lib.toInt (builtins.elemAt turnUDPPorts 1);
          }
        ];

        allowedUDPPorts = [ turnPort ];
      };

      systemd.services.screego = {
        after = [ "network.target" ];
        description = "screego screen-sharing for developers";
        environment = mergedConfig;

        serviceConfig = {
          DynamicUser = true;
          ExecStart = "${lib.getExe pkgs.screego} serve";
          Restart = "on-failure";
          RestartSec = "5s";
        }
        // lib.optionalAttrs (cfg.environmentFile != null) { EnvironmentFile = cfg.environmentFile; };

        wantedBy = [ "multi-user.target" ];
      };
    };

  meta.maintainers = with lib.maintainers; [ pinpox ];
}
