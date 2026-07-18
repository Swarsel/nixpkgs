{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.commafeed;
in
{
  options.services.commafeed = {
    enable = lib.mkEnableOption "CommaFeed";
    package = lib.mkPackageOption pkgs "commafeed" { };

    environment = lib.mkOption {
      default = { };

      description = ''
        Extra environment variables passed to CommaFeed, refer to
        <https://github.com/Athou/commafeed/blob/master/commafeed-server/config.yml.example>
        for supported values. The default user is `admin` and the default password is `admin`.
        Correct configuration for H2 database is already provided.
      '';

      example = {
        CF_SERVER_APPLICATIONCONNECTORS_0_PORT = 9090;
        CF_SERVER_APPLICATIONCONNECTORS_0_TYPE = "http";
      };

      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.bool
          lib.types.int
          lib.types.str
        ]
      );
    };

    environmentFile = lib.mkOption {
      default = null;

      description = ''
        Environment file as defined in {manpage}`systemd.exec(5)`.
      '';

      example = "/var/lib/commafeed/commafeed.env";
      type = lib.types.nullOr lib.types.path;
    };

    group = lib.mkOption {
      default = "commafeed";
      description = "Group under which CommaFeed runs.";
      type = lib.types.str;
    };

    stateDir = lib.mkOption {
      default = "/var/lib/commafeed";
      description = "Directory holding all state for CommaFeed to run.";
      type = lib.types.path;
    };

    user = lib.mkOption {
      default = "commafeed";
      description = "User under which CommaFeed runs.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.commafeed = {
      after = [ "network.target" ];

      environment = lib.mapAttrs (
        _: v: if lib.isBool v then lib.boolToString v else toString v
      ) cfg.environment;

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = [ "" ];
        DevicePolicy = "closed";
        DynamicUser = true;
        ExecStart = "${lib.getExe cfg.package} server ${cfg.package}/share/config.yml";
        Group = cfg.group;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
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
        ProtectSystem = true;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = baseNameOf cfg.stateDir;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        UMask = "0077";
        User = cfg.user;
        WorkingDirectory = cfg.stateDir;
      }
      // lib.optionalAttrs (cfg.environmentFile != null) { EnvironmentFile = cfg.environmentFile; };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ ];
}
