{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.bluesky-pds;

  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    escapeShellArgs
    concatMapStringsSep
    types
    literalExpression
    optional
    ;

  pdsadminWrapper =
    let
      cfgSystemd = config.systemd.services.bluesky-pds.serviceConfig;
    in
    pkgs.writeShellScriptBin "pdsadmin" ''
      DUMMY_PDS_ENV_FILE="$(mktemp)"
      trap 'rm -f "$DUMMY_PDS_ENV_FILE"' EXIT
      env "PDS_ENV_FILE=$DUMMY_PDS_ENV_FILE"                                                   \
          ${escapeShellArgs cfgSystemd.Environment}                                            \
          ${concatMapStringsSep " " (envFile: "$(cat ${envFile})") cfgSystemd.EnvironmentFile} \
          ${getExe pkgs.bluesky-pdsadmin} "$@"
    '';
in
# All defaults are from https://github.com/bluesky-social/pds/blob/0b5cd1179f4fcf2643e5ead5cf4ac56c5cdeda3b/installer.sh
{
  imports = [
    (lib.mkRenamedOptionModule [ "services" "pds" "enable" ] [ "services" "bluesky-pds" "enable" ])
    (lib.mkRenamedOptionModule [ "services" "pds" "package" ] [ "services" "bluesky-pds" "package" ])
    (lib.mkRenamedOptionModule [ "services" "pds" "settings" ] [ "services" "bluesky-pds" "settings" ])
    (lib.mkRenamedOptionModule
      [ "services" "pds" "environmentFiles" ]
      [ "services" "bluesky-pds" "environmentFiles" ]
    )
    (lib.mkRenamedOptionModule [ "services" "pds" "pdsadmin" ] [ "services" "bluesky-pds" "pdsadmin" ])
  ];

  options.services.bluesky-pds = {
    enable = mkEnableOption "pds";
    package = mkPackageOption pkgs "bluesky-pds" { };

    environmentFiles = mkOption {
      default = [ ];

      description = ''
        File to load environment variables from. Loaded variables override
        values set in {option}`environment`.

        Use it to set values of `PDS_JWT_SECRET`, `PDS_ADMIN_PASSWORD`,
        and `PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX` secrets.
        `PDS_JWT_SECRET` and `PDS_ADMIN_PASSWORD` can be generated with
        ```
        openssl rand --hex 16
        ```
        `PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX` can be generated with
        ```
        openssl ecparam --name secp256k1 --genkey --noout --outform DER | tail --bytes=+8 | head --bytes=32 | xxd --plain --cols 32
        ```
      '';

      type = types.listOf types.path;
    };

    goat = {
      enable = mkOption {
        default = cfg.enable;
        defaultText = literalExpression "config.services.bluesky-pds.enable";
        description = "Add goat to PATH";
        type = types.bool;
      };
    };

    pdsadmin = {
      enable = mkOption {
        default = false;
        defaultText = false;
        description = "Add pdsadmin script to PATH";
        type = types.bool;
      };
    };

    settings = mkOption {
      description = ''
        Environment variables to set for the service. Secrets should be
        specified using {option}`environmentFile`.

        Refer to <https://github.com/bluesky-social/atproto/blob/main/packages/pds/src/config/env.ts> for available environment variables.
      '';

      type = types.submodule {
        options = {
          LOG_ENABLED = mkOption {
            default = "true";
            description = "Enable logging";
            type = types.nullOr types.str;
          };

          PDS_BLOBSTORE_DISK_LOCATION = mkOption {
            default = "/var/lib/pds/blocks";
            description = "Store blobs at this location, set to null to use e.g. S3";
            type = types.nullOr types.str;
          };

          PDS_BLOB_UPLOAD_LIMIT = mkOption {
            default = "104857600";
            description = "Size limit of uploaded blobs in bytes";
            type = types.str;
          };

          PDS_BSKY_APP_VIEW_DID = mkOption {
            default = "did:web:api.bsky.app";
            description = "DID of bsky frontend";
            type = types.str;
          };

          PDS_BSKY_APP_VIEW_URL = mkOption {
            default = "https://api.bsky.app";
            description = "URL of bsky frontend";
            type = types.str;
          };

          PDS_CRAWLERS = mkOption {
            default = "https://bsky.network";
            description = "URL of crawlers";
            type = types.str;
          };

          PDS_DATA_DIRECTORY = mkOption {
            default = "/var/lib/pds";
            description = "Directory to store state";
            type = types.str;
          };

          PDS_DID_PLC_URL = mkOption {
            default = "https://plc.directory";
            description = "URL of DID PLC directory";
            type = types.str;
          };

          PDS_HOSTNAME = mkOption {
            description = "Instance hostname (base domain name)";
            example = "pds.example.com";
            type = types.str;
          };

          PDS_INVITE_REQUIRED = mkOption {
            default = "true";
            description = "Require invite code for registration";
            type = types.nullOr types.str;
          };

          PDS_PORT = mkOption {
            default = 3000;
            description = "Port to listen on";
            type = types.port;
          };

          PDS_RATE_LIMITS_ENABLED = mkOption {
            default = "true";
            description = "Enable rate limiting";
            type = types.nullOr types.str;
          };

          PDS_REPORT_SERVICE_DID = mkOption {
            default = "did:plc:ar7c4by46qjdydhdevvrndac";
            description = "DID of mod service";
            type = types.str;
          };

          PDS_REPORT_SERVICE_URL = mkOption {
            default = "https://mod.bsky.app";
            description = "URL of mod service";
            type = types.str;
          };
        };

        freeformType = types.attrsOf (
          types.oneOf [
            (types.nullOr types.str)
            types.port
          ]
        );
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      optional cfg.pdsadmin.enable pdsadminWrapper ++ optional cfg.goat.enable pkgs.atproto-goat;

    systemd.services.bluesky-pds = {
      after = [ "network-online.target" ];
      description = "bluesky pds";

      serviceConfig = {
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        DeviceAllow = [ "" ];

        Environment = lib.mapAttrsToList (k: v: "${k}=${if builtins.isInt v then toString v else v}") (
          lib.filterAttrs (_: v: v != null) cfg.settings
        );

        EnvironmentFile = cfg.environmentFiles;
        ExecStart = getExe cfg.package;
        Group = "pds";
        LockPersonality = true;
        MemoryDenyWriteExecute = false; # required by V8 JIT
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        # Hardening
        RemoveIPC = true;
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "pds";
        StateDirectoryMode = "0755";
        SystemCallArchitectures = [ "native" ];
        UMask = "0077";
        User = "pds";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    users = {
      groups.pds = { };

      users.pds = {
        group = "pds";
        isSystemUser = true;
      };
    };

  };

  meta.maintainers = with lib.maintainers; [ t4ccer ];
}
