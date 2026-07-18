{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.wastebin;
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkIf
    mkOption
    types
    mapAttrs
    isBool
    getExe
    boolToString
    optionalAttrs
    ;
in
{

  options.services.wastebin = {

    enable = mkEnableOption "Wastebin, a pastebin service";
    package = mkPackageOption pkgs "wastebin" { };

    secretFile = mkOption {
      default = null;

      description = ''
        Path to file containing sensitive environment variables.
        Some variables that can be considered secrets are:

        - WASTEBIN_PASSWORD_SALT:
          salt used to hash user passwords used for encrypting pastes.

        - WASTEBIN_SIGNING_KEY:
          sets the key to sign cookies. If not set, a random key will be
          generated which means cookies will become invalid after restarts and
          paste creators will not be able to delete their pastes anymore.
      '';

      example = "/run/secrets/wastebin.env";
      type = types.nullOr types.path;
    };

    settings = mkOption {

      default = { };

      description = ''
        Additional configuration for wastebin, see
        <https://github.com/matze/wastebin#usage> for supported values.
        For secrets use secretFile option instead.
      '';

      example = {
        WASTEBIN_TITLE = "My awesome pastebin";
      };

      type = types.submodule {

        options = {

          RUST_LOG = mkOption {
            default = "info";

            description = ''
              Influences logging. Besides the typical trace, debug, info etc.
              keys, you can also set the tower_http key to some log level to get
              additional information request and response logs.
            '';

            type = types.str;
          };

          WASTEBIN_ADDRESS_PORT = mkOption {
            default = "0.0.0.0:8088";
            description = "Address and port to bind to";
            type = types.str;
          };

          WASTEBIN_BASE_URL = mkOption {
            default = "http://localhost";

            description = ''
              Base URL for the QR code display. If not set, the user agent's Host
              header field is used as an approximation.
            '';

            example = "https://myhost.tld";
            type = types.str;
          };

          WASTEBIN_CACHE_SIZE = mkOption {
            default = 128;
            description = "Number of rendered syntax highlight items to cache. Can be disabled by setting to 0.";
            type = types.int;
          };

          WASTEBIN_DATABASE_PATH = mkOption {
            default = "/var/lib/wastebin/sqlite3.db"; # TODO make this default to stateDir/sqlite3.db
            description = "Path to the sqlite3 database file. If not set, an in-memory database is used.";
            type = types.str;
          };

          WASTEBIN_HTTP_TIMEOUT = mkOption {
            default = 5;
            description = "Maximum number of seconds a request can be processed until wastebin responds with 408";
            type = types.int;
          };

          WASTEBIN_MAX_BODY_SIZE = mkOption {
            default = 1048576;
            description = "Number of bytes to accept for POST requests";
            type = types.int;
          };

          WASTEBIN_TITLE = mkOption {
            default = "wastebin";
            description = "Overrides the HTML page title";
            type = types.str;
          };
        };

        freeformType =
          with types;
          attrsOf (oneOf [
            bool
            int
            str
          ]);
      };
    };

    stateDir = mkOption {
      default = "/var/lib/wastebin";
      description = "State directory of the daemon.";
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.wastebin = {
      after = [ "network.target" ];
      environment = mapAttrs (_: v: if isBool v then boolToString v else toString v) cfg.settings;

      serviceConfig = {
        DevicePolicy = "closed";
        DynamicUser = true;
        ExecStart = "${getExe cfg.package}";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ReadWritePaths = cfg.stateDir;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = baseNameOf cfg.stateDir;
        SystemCallArchitectures = [ "native" ];
        SystemCallFilter = [ "@system-service" ];
      }
      // optionalAttrs (cfg.secretFile != null) {
        EnvironmentFile = cfg.secretFile;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ pinpox ];
}
