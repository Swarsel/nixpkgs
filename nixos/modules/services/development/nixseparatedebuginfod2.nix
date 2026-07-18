{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.nixseparatedebuginfod2;
  address = "127.0.0.1:${toString cfg.port}";
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "nixseparatedebuginfod2" "substituter" ] ''
      Instead of `services.nixseparatedebuginfod2.substituter = "foo"`, set `services.nixseparatedebuginfod2.substituters = [ "foo" ]` (possibly with mkForce to override the default value).
    '')
  ];

  options = {
    services.nixseparatedebuginfod2 = {
      enable = lib.mkEnableOption "nixseparatedebuginfod2, a debuginfod server providing source and debuginfo for nix packages";
      package = lib.mkPackageOption pkgs "nixseparatedebuginfod2" { };

      cacheExpirationDelay = lib.mkOption {
        default = "1d";
        description = "keep unused cache entries for this long. A number followed by a unit";
        type = lib.types.str;
      };

      port = lib.mkOption {
        default = 1949;
        description = "port to listen";
        type = lib.types.port;
      };

      substituters = lib.mkOption {
        default = [
          "local:"
          "https://cache.nixos.org"
        ];

        description = "nix substituter to fetch debuginfo from. Either http/https/file substituters, or `local:` to use debuginfo present in the local store.";
        type = lib.types.listOf lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.debuginfodServers = [ "http://${address}" ];

    systemd.services.nixseparatedebuginfod2 = {
      serviceConfig = {
        CacheDirectory = "nixseparatedebuginfod2";
        # Capabilities
        CapabilityBoundingSet = ""; # Allow no capabilities at all
        DynamicUser = true;

        ExecStart = [
          (utils.escapeSystemdExecArgs (
            [
              (lib.getExe cfg.package)
              "--expiration"
              cfg.cacheExpirationDelay
            ]
            ++ (lib.lists.concatMap (s: [
              "--substituter"
              s
            ]) cfg.substituters)
          ))
        ];

        # Misc
        LockPersonality = true; # Prevent change of the personality
        MemoryDenyWriteExecute = true; # Maybe disable this for interpreters like python
        NoNewPrivileges = true; # Disallow getting more capabilities. This is also implied by other options.
        PrivateDevices = true; # Deny access to most of /dev
        PrivateMounts = true; # Give an own mount namespace
        PrivateTmp = true; # Give an own directory under /tmp
        ProtectClock = true; # Prevent setting the RTC
        ProtectControlGroups = true; # Remount cgroups read-only
        ProtectHome = true; # Prevent accessing /home and /root
        ProtectHostname = true; # Give an own UTS namespace
        ProtectKernelLogs = true; # Prevent access to kernel logs
        # Kernel stuff
        ProtectKernelModules = true; # Prevent loading of kernel modules
        ProtectKernelTunables = true; # Protect some parts of /sys
        ProtectProc = "noaccess";
        # hardening
        # Filesystem stuff
        ProtectSystem = "strict"; # Prevent writing to most of /
        RemoveIPC = true;
        Restart = "on-failure";
        # Networking
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
        RestrictNamespaces = true;
        RestrictRealtime = true; # Prevent switching to RT scheduling
        RestrictSUIDSGID = true; # Prevent creating SETUID/SETGID files
        SystemCallArchitectures = "native"; # Usually no need to disable this
        SystemCallFilter = "@system-service";
        Type = "notify";
        UMask = "0077";

      };
    };

    systemd.sockets.nixseparatedebuginfod2 = {
      socketConfig.ListenStream = [ address ];
      wantedBy = [ "multi-user.target" ];
    };

  };
}
