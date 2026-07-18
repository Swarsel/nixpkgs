{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.matrix-conduit;

  format = pkgs.formats.toml { };
  configFile = format.generate "conduit.toml" cfg.settings;
in
{
  options.services.matrix-conduit = {
    enable = lib.mkEnableOption "matrix-conduit";
    package = lib.mkPackageOption pkgs "matrix-conduit" { };

    extraEnvironment = lib.mkOption {
      default = { };
      description = "Extra Environment variables to pass to the conduit server.";

      example = {
        RUST_BACKTRACE = "yes";
      };

      type = lib.types.attrsOf lib.types.str;
    };

    secretFile = lib.mkOption {
      default = null;

      description = ''
        Path to a file containing sensitive environment as described in {manpage}`systemd.exec(5).
        Some variables that can be considered secrets are:

        - CONDUIT_JWT_SECRET:
          The secret used to enable JWT login. Without it a 400 error will be returned.

        - CONDUIT_TURN_SECRET:
          The TURN secret
      '';

      example = "/run/secrets/matrix-conduit.env";
      type = lib.types.nullOr lib.types.path;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Generates the conduit.toml configuration file. Refer to
        <https://docs.conduit.rs/configuration.html>
        for details on supported values.
        Note that database_path can not be edited because the service's reliance on systemd StateDir.
        For secrets use the `secretFile` option instead.
      '';

      type = lib.types.submodule {
        options = {
          global.address = lib.mkOption {
            default = "::1";
            description = "Address to listen on for connections by the reverse proxy/tls terminator.";
            type = lib.types.str;
          };

          global.allow_check_for_updates = lib.mkOption {
            default = false;

            description = ''
              Whether to allow Conduit to automatically contact
              <https://conduit.rs> hourly to check for important Conduit news.

              Disabled by default because nixpkgs handles updates.
            '';

            type = lib.types.bool;
          };

          global.allow_encryption = lib.mkOption {
            default = true;
            description = "Whether new encrypted rooms can be created. Note: existing rooms will continue to work.";
            type = lib.types.bool;
          };

          global.allow_federation = lib.mkOption {
            default = true;

            description = ''
              Whether this server federates with other servers.
            '';

            type = lib.types.bool;
          };

          global.allow_registration = lib.mkOption {
            default = false;
            description = "Whether new users can register on this server.";
            type = lib.types.bool;
          };

          global.database_backend = lib.mkOption {
            default = "sqlite";

            description = ''
              The database backend for the service. Switching it on an existing
              instance will require manual migration of data.
            '';

            example = "rocksdb";

            type = lib.types.enum [
              "sqlite"
              "rocksdb"
            ];
          };

          global.database_path = lib.mkOption {
            default = "/var/lib/matrix-conduit/";

            description = ''
              Path to the conduit database, the directory where conduit will save its data.
              Note that due to using the DynamicUser feature of systemd, this value should not be changed
              and is set to be read only.
            '';

            readOnly = true;
            type = lib.types.str;
          };

          global.max_request_size = lib.mkOption {
            default = 20000000;
            description = "Max request size in bytes. Don't forget to also change it in the proxy.";
            type = lib.types.ints.positive;
          };

          global.port = lib.mkOption {
            default = 6167;
            description = "The port Conduit will be running on. You need to set up a reverse proxy in your web server (e.g. apache or nginx), so all requests to /_matrix on port 443 and 8448 will be forwarded to the Conduit instance running on this port";
            type = lib.types.port;
          };

          global.server_name = lib.mkOption {
            description = "The server_name is the name of this server. It is used as a suffix for user # and room ids.";
            example = "example.com";
            type = lib.types.str;
          };

          global.trusted_servers = lib.mkOption {
            default = [ "matrix.org" ];
            description = "Servers trusted with signing server keys.";
            type = lib.types.listOf lib.types.str;
          };
        };

        freeformType = format.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.conduit = {
      after = [ "network-online.target" ];
      description = "Conduit Matrix Server";
      documentation = [ "https://gitlab.com/famedly/conduit/" ];

      environment = lib.mkMerge [
        { CONDUIT_CONFIG = configFile; }
        cfg.extraEnvironment
      ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/conduit";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        Restart = "on-failure";
        RestartSec = 10;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "matrix-conduit";
        StateDirectoryMode = "0700";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        UMask = "077";
        User = "conduit";
      }
      // lib.optionalAttrs (cfg.secretFile != null) {
        EnvironmentFile = cfg.secretFile;
      };

      unitConfig = {
        StartLimitBurst = 5;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    pstn
    SchweGELBin
  ];
}
