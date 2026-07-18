{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.porxie;
in
{
  options.services.porxie = {
    enable = lib.mkEnableOption "Porxie, an ATProto blob proxy for secure content delivery";
    package = lib.mkPackageOption pkgs "porxie" { };

    environmentFiles = lib.mkOption {
      default = [ ];

      description = ''
        Files to load environment variables from. Use for secrets such as
        {env}`PORXIE_SERVER_ADMIN_PASSWORD` and {env}`PORXIE_POLICY_REQUEST_HEADERS`.
      '';

      type = lib.types.listOf lib.types.path;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration for Porxie as environment variables. See the
        [README](https://codeberg.org/Blooym/porxie/src/branch/main/README.md)
        for detailed information about application configuration.

        Secrets such as {option}`settings.PORXIE_SERVER_ADMIN_PASSWORD` should be set via
        {option}`environmentFiles` rather than here, as values set here will
        be readable in the Nix store.
      '';

      type = lib.types.submodule {
        options = {
          # Blobs.
          PORXIE_BLOB_ALLOWED_MIMETYPES = lib.mkOption {
            apply = v: if v != null then lib.concatStringsSep "," v else null;
            default = null;

            description = ''
              Blob mimetypes that can be served. Wildcards are supported "*/*", "image/*", etc.

              Validation is done loosely via content sniffing. Further validation can be done by a layer
              above this proxy, such as an image transformation service. When inference fails, the blob's
              type falls back to `application/octet-stream`. When that type is allowed, blobs failing
              inference can still be served.
            '';

            type = lib.types.nullOr (lib.types.listOf lib.types.str);
          };

          PORXIE_BLOB_CACHE_HEADER = lib.mkOption {
            default = null;

            description = ''
              The Cache-Control header value to send alongside blob responses.

              This does not affect internal cache lifetimes, only how downstream clients such as CDNs
              and browsers are instructed to cache responses.
            '';

            type = lib.types.nullOr lib.types.str;
          };

          PORXIE_BLOB_HTTP_TIMEOUT = lib.mkOption {
            default = null;
            description = "Maximum duration before blob fetch requests are timed out.";
            type = lib.types.nullOr lib.types.str;
          };

          PORXIE_BLOB_MAX_SIZE = lib.mkOption {
            default = null;

            description = ''
              Maximum blob size that can be served.

              This value cannot be set higher than the system's total memory.
            '';

            type = lib.types.nullOr lib.types.str;
          };

          PORXIE_BLOB_PROCESSING_TIMEOUT = lib.mkOption {
            default = null;
            description = "Maximum duration a blob can be processed by this server before aborting.";
            type = lib.types.nullOr lib.types.str;
          };

          # Cache.
          PORXIE_CACHE_ALLOCATION = lib.mkOption {
            default = null;

            description = ''
              Total memory allocation for the internal cache.

              Blobs are cached using an LFU policy. The most frequently requested blobs are kept longest when the cache reaches maximum size.

              For production deployments, a CDN or caching layer in front of this server is
              recommended for lower latency and better global availability.

              The minimum value is 8mb and the maximum is the system's total memory.
            '';

            type = lib.types.nullOr lib.types.str;
          };

          PORXIE_CACHE_BLOB_TTI = lib.mkOption {
            default = null;
            description = "How long blobs can be idle in the cache before expiring.";
            type = lib.types.nullOr lib.types.str;
          };

          PORXIE_CACHE_IDENTITY_TTL = lib.mkOption {
            default = null;
            description = "How long identity lookups (DID resolution, etc.) can be cached before expiring.";
            type = lib.types.nullOr lib.types.str;
          };

          PORXIE_CACHE_OWNERSHIP_TTL = lib.mkOption {
            default = null;
            description = "How long blob ownership can be cached before expiring.";
            type = lib.types.nullOr lib.types.str;
          };

          PORXIE_CACHE_POLICY_TTL = lib.mkOption {
            default = null;
            description = "How long policy decisions can be cached before expiring.";
            type = lib.types.nullOr lib.types.str;
          };

          # Identity.
          PORXIE_IDENTITY_PLC_URL = lib.mkOption {
            default = null;
            description = "URL of the PLC instance used for `did:plc` lookups.";
            type = lib.types.nullOr lib.types.str;
          };

          PORXIE_POLICY_FAIL_OPEN = lib.mkOption {
            apply = v: if v != null then lib.boolToString v else null;
            default = null;

            description = ''
              Allow requests to proceed even if the policy service is unavailable.

              Warning: enabling this means restricted blobs may be served when the policy service
              is unavailable.
            '';

            type = lib.types.nullOr lib.types.bool;
          };

          PORXIE_POLICY_REQUEST_HEADERS = lib.mkOption {
            apply = v: if v != null then lib.concatStringsSep "|" v else null;
            default = null;

            description = ''
              Headers sent alongside requests to the policy service.

              Each header must be in the format `Name: value`.

              As pipes are used as a delimiter, they cannot be contained in headers.

              Should be set via {option}`environmentFiles` for sensitive values such as API keys.
            '';

            type = lib.types.nullOr (lib.types.listOf lib.types.str);
          };

          # Policy.
          PORXIE_POLICY_URL = lib.mkOption {
            default = null;

            description = ''
              Policy service URL that DID+CID pairs will be checked against.

              Requests are sent via XRPC to `<url>/xrpc/dev.blooym.porxie.getBlobPolicy`.
            '';

            type = lib.types.nullOr lib.types.str;
          };

          # Server.
          PORXIE_SERVER_ADDRESS = lib.mkOption {
            default = "ip:127.0.0.1:6314";

            description = ''
              Address to bind the server to.

              Use the `ip:` prefix for an IP address (e.g. `ip:127.0.0.1:6314`), or on UNIX
              systems, the `unix:` prefix for a UNIX socket path (e.g. `unix:/run/porxie/porxie.sock`).
            '';

            type = lib.types.str;
          };

          PORXIE_SERVER_ADMIN_PASSWORD = lib.mkOption {
            default = null;

            description = ''
              Admin password for authenticating privileged requests.

              Authenticated requests always expect the username `admin` as per specification.

              When not set, authenticated endpoints will be unavailable.

              Should be set via {option}`environmentFiles` rather than directly.
            '';

            type = lib.types.nullOr lib.types.str;
          };
        };

        freeformType = lib.types.attrsOf (
          lib.types.nullOr (
            lib.types.oneOf [
              lib.types.str
              lib.types.bool
              lib.types.int
            ]
          )
        );
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          (cfg.settings.PORXIE_POLICY_REQUEST_HEADERS != null || cfg.settings.PORXIE_POLICY_FAIL_OPEN != null)
          -> cfg.settings.PORXIE_POLICY_URL != null;

        message = "services.porxie: PORXIE_POLICY_URL must be set when using any other policy options";
      }
    ];

    systemd.services.porxie = {
      after = [ "network-online.target" ];
      description = "Porxie - ATProto blob proxy";

      serviceConfig = {
        AmbientCapabilities = "";
        DynamicUser = true;

        Environment = lib.mapAttrsToList (k: v: "${k}=${lib.escapeShellArg (toString v)}") (
          lib.filterAttrs (_: v: v != null) cfg.settings
        );

        EnvironmentFile = cfg.environmentFiles;
        ExecStart = lib.getExe cfg.package;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "all";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "on-failure";
        RestartSec = 5;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "porxie";
        RuntimeDirectoryMode = "0750";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        UMask = "0077";
        User = "porxie";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ blooym ];
}
