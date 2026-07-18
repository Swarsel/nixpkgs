{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.services.imaginary;
in
{
  options.services.imaginary = {
    enable = mkEnableOption "imaginary image processing microservice";

    address = mkOption {
      default = "localhost";

      description = ''
        Bind address. Corresponds to the `-a` flag.
        Set to `""` to bind to all addresses.
      '';

      example = "[::1]";
      type = types.str;
    };

    port = mkOption {
      default = 8088;
      description = "Bind port. Corresponds to the `-p` flag.";
      type = types.port;
    };

    settings = mkOption {
      description = ''
        Command line arguments passed to the imaginary executable, stripped of
        the prefix `-`. See upstream's
        [README](https://github.com/h2non/imaginary#command-line-usage) for all
        options.
      '';

      type = types.submodule {
        options = {
          return-size = mkOption {
            default = false;
            description = "Return the image size in the HTTP headers.";
            type = types.bool;
          };
        };

        freeformType =
          with types;
          attrsOf (oneOf [
            bool
            int
            (nonEmptyListOf str)
            str
          ]);
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !lib.hasAttr "a" cfg.settings;
        message = "Use services.imaginary.address to specify the -a flag.";
      }
      {
        assertion = !lib.hasAttr "p" cfg.settings;
        message = "Use services.imaginary.port to specify the -p flag.";
      }
    ];

    systemd.services.imaginary = {
      after = [ "network.target" ];

      serviceConfig = rec {
        AmbientCapabilities = CapabilityBoundingSet;
        BindReadOnlyPaths = lib.optional (cfg.settings ? mount) cfg.settings.mount;
        CapabilityBoundingSet = if cfg.port < 1024 then [ "CAP_NET_BIND_SERVICE" ] else [ "" ];
        DevicePolicy = "closed";
        DynamicUser = true;

        ExecStart =
          let
            args =
              lib.mapAttrsToList
                (key: val: "-" + key + "=" + lib.concatStringsSep "," (map toString (lib.toList val)))
                (
                  cfg.settings
                  // {
                    a = cfg.address;
                    p = cfg.port;
                  }
                );
          in
          "${pkgs.imaginary}/bin/imaginary ${utils.escapeSystemdExecArgs args}";

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = cfg.port >= 1024;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        TemporaryFileSystem = [ "/:ro" ];
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
