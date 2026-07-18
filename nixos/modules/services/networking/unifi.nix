{
  config,
  lib,
  pkgs,
  options,
  utils,
  jdk25_headless,
  ...
}:
let
  cfg = config.services.unifi;
  stateDir = "/var/lib/unifi";
  cmd = lib.escapeShellArgs (
    [
      "@${cfg.jrePackage}/bin/java"
      "java"
      "--add-opens=java.base/java.lang=ALL-UNNAMED"
      "--add-opens=java.base/java.time=ALL-UNNAMED"
      "--add-opens=java.base/sun.security.util=ALL-UNNAMED"
      "--add-opens=java.base/java.io=ALL-UNNAMED"
      "--add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED"
    ]
    ++ (lib.optional (cfg.initialJavaHeapSize != null) "-Xms${(toString cfg.initialJavaHeapSize)}m")
    ++ (lib.optional (cfg.maximumJavaHeapSize != null) "-Xmx${(toString cfg.maximumJavaHeapSize)}m")
    ++ cfg.extraJvmOptions
    ++ [
      "-jar"
      "${stateDir}/lib/ace.jar"
    ]
  );
in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "unifi"
      "dataDir"
    ] "You should move contents of dataDir to /var/lib/unifi/data")
    (lib.mkRenamedOptionModule [ "services" "unifi" "openPorts" ] [ "services" "unifi" "openFirewall" ])
  ];

  options = {
    services.unifi.enable = lib.mkEnableOption "UniFi controller service";

    services.unifi.extraJvmOptions = lib.mkOption {
      default = [ ];

      description = ''
        Set extra options to pass to the JVM.
      '';

      example = lib.literalExpression ''["-Xlog:gc"]'';
      type = with lib.types; listOf str;
    };

    services.unifi.initialJavaHeapSize = lib.mkOption {
      default = null;

      description = ''
        Set the initial heap size for the JVM in MB. If this option isn't set, the
        JVM will decide this value at runtime.
      '';

      example = 1024;
      type = with lib.types; nullOr int;
    };

    services.unifi.jrePackage = lib.mkOption {
      default = cfg.unifiPackage.passthru.jrePackage or jdk25_headless;
      defaultText = lib.literalExpression "unifiPackage.passthru.jrePackage";

      description = ''
        Which Java runtime to use.
      '';

      type = lib.types.package;
    };

    services.unifi.maximumJavaHeapSize = lib.mkOption {
      default = null;

      description = ''
        Set the maximum heap size for the JVM in MB. If this option isn't set, the
        JVM will decide this value at runtime.
      '';

      example = 4096;
      type = with lib.types; nullOr int;
    };

    services.unifi.mongodbPackage = lib.mkPackageOption pkgs "mongodb" {
      default = "mongodb-7_0";
    };

    services.unifi.openFirewall = lib.mkOption {
      default = false;

      description = ''
        Whether or not to open the minimum required ports on the firewall.

        This is necessary to allow firmware upgrades and device discovery to
        work. For remote login, you should additionally open (or forward) port
        8443.
      '';

      type = lib.types.bool;
    };

    services.unifi.unifiPackage = lib.mkPackageOption pkgs "unifi" { };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          lib.versionAtLeast config.system.stateVersion "24.11"
          || (
            options.services.unifi.unifiPackage.highestPrio < (lib.mkOptionDefault { }).priority
            && options.services.unifi.mongodbPackage.highestPrio < (lib.mkOptionDefault { }).priority
          );

        message = ''
          Support for UniFi < 8 has been dropped; please explicitly set
          `services.unifi.unifiPackage` and `services.unifi.mongodbPackage`.

          Note that the previous default MongoDB version was 5.0 and MongoDB
          only supports migrating one major version at a time; therefore, you
          may wish to set `services.unifi.mongodbPackage = pkgs.mongodb-6_0;`
          and activate your configuration before upgrading again to the default
          `mongodb-7_0` supported by `unifi`.

          For more information, see the MongoDB upgrade notes:
          <https://www.mongodb.com/docs/manual/release-notes/7.0-upgrade-standalone/#upgrade-recommendations-and-checklists>
        '';
      }
    ];

    # https://help.ubnt.com/hc/en-us/articles/218506997
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        8080 # Port for UAP to inform controller.
        8880 # Port for HTTP portal redirect, if guest portal is enabled.
        8843 # Port for HTTPS portal redirect, ditto.
        6789 # Port for UniFi mobile speed test.
      ];

      allowedUDPPorts = [
        3478 # UDP port used for STUN.
        10001 # UDP port used for device discovery.
      ];
    };

    systemd.services.unifi = {
      after = [ "network.target" ];
      description = "UniFi controller daemon";
      # This a HACK to fix missing dependencies of dynamic libs extracted from jars
      environment.LD_LIBRARY_PATH = with pkgs.stdenv; "${cc.cc.lib}/lib";

      # Make sure package upgrades trigger a service restart
      restartTriggers = [
        cfg.unifiPackage
        cfg.mongodbPackage
      ];

      serviceConfig = {
        # Hardening
        AmbientCapabilities = "";

        # We must create the binary directories as bind mounts instead of symlinks
        # This is because the controller resolves all symlinks to absolute paths
        # to be used as the working directory.
        BindPaths = [
          "/var/log/unifi:${stateDir}/logs"
          "/run/unifi:${stateDir}/run"
          "${cfg.unifiPackage}/dl:${stateDir}/dl"
          "${cfg.unifiPackage}/lib:${stateDir}/lib"
          "${cfg.mongodbPackage}/bin:${stateDir}/bin"
          "${cfg.unifiPackage}/webapps/ROOT:${stateDir}/webapps/ROOT"
        ];

        CacheDirectory = "unifi";
        CapabilityBoundingSet = "";
        # ProtectClock= adds DeviceAllow=char-rtc r
        DeviceAllow = "";
        DevicePolicy = "closed";
        ExecStart = "${cmd} start";

        ExecStop = [
          "${cmd} stop"
          "${lib.getExe' pkgs.util-linux "waitpid"} -t 30 -e $MAINPID"
        ];

        LockPersonality = true;
        LogsDirectory = "unifi";
        # Cannot be true due to OpenJDK
        MemoryDenyWriteExecute = false;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        # Needs network access
        PrivateNetwork = false;
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
        RemoveIPC = true;
        Restart = "always";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "unifi";
        StateDirectory = "unifi";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = [ "@system-service" ];

        TemporaryFileSystem = [
          # required as we want to create bind mounts below
          "${stateDir}/webapps:rw"
        ];

        Type = "notify";
        UMask = "0077";
        User = "unifi";
        WorkingDirectory = "${stateDir}";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.unifi = { };

    users.users.unifi = {
      description = "UniFi controller daemon user";
      group = "unifi";
      home = "${stateDir}";
      isSystemUser = true;
    };
  };
}
