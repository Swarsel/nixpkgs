{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.chrony;
  chronyPkg = cfg.package;

  stateDir = cfg.directory;
  driftFile = "${stateDir}/chrony.drift";
  keyFile = "${stateDir}/chrony.keys";
  rtcFile = "${stateDir}/chrony.rtc";

  configFile = pkgs.writeText "chrony.conf" ''
    ${lib.concatMapStringsSep "\n" (
      server:
      (if lib.strings.hasInfix "pool" server then "pool " else "server ")
      + server
      + " "
      + cfg.serverOption
      + lib.optionalString (cfg.enableNTS) " nts"
    ) cfg.servers}

    ${lib.optionalString (
      cfg.initstepslew.enabled && (cfg.servers != [ ])
    ) "initstepslew ${toString cfg.initstepslew.threshold} ${lib.concatStringsSep " " cfg.servers}"}

    ${lib.optionalString cfg.makestep.enable "makestep ${toString cfg.makestep.threshold} ${toString cfg.makestep.limit}"}

    driftfile ${driftFile}
    keyfile ${keyFile}
    ${lib.optionalString (cfg.enableRTCTrimming) "rtcfile ${rtcFile}"}
    ${lib.optionalString (cfg.enableNTS) "ntsdumpdir ${stateDir}"}

    ${lib.optionalString (cfg.enableRTCTrimming) "rtcautotrim ${toString cfg.autotrimThreshold}"}
    ${lib.optionalString (!config.time.hardwareClockInLocalTime) "rtconutc"}

    ${cfg.extraConfig}
  '';

  chronyFlags = [
    "-n"
    "-u"
    "chrony"
    "-f"
    "${configFile}"
  ]
  ++ lib.optional cfg.enableMemoryLocking "-m"
  ++ cfg.extraFlags;

  dispatcherScriptFile = pkgs.callPackage (
    {
      runCommand,
      srcOnly,
    }:
    runCommand "10-chrony-onoffline" { } ''
      cp ${srcOnly chronyPkg}/examples/chrony.nm-dispatcher.onoffline $out
      substituteInPlace $out \
        --replace-fail '/usr/bin/chronyc' '${chronyPkg}/bin/chronyc'
      chmod +x $out
      patchShebangs $out
    ''
  ) { };
in
{
  options = {
    services.chrony = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to synchronise your machine's time using chrony.
          Make sure you disable NTP if you enable this service.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "chrony" { };

      autotrimThreshold = lib.mkOption {
        default = 30;

        description = ''
          Maximum estimated error threshold for the `rtcautotrim` command.
          When reached, the RTC will be trimmed.
          Only used when [](#opt-services.chrony.enableRTCTrimming) is enabled.
        '';

        example = 10;
        type = lib.types.ints.positive;
      };

      directory = lib.mkOption {
        default = "/var/lib/chrony";
        description = "Directory where chrony state is stored.";
        type = lib.types.str;
      };

      dispatcherScript = lib.mkOption {
        default = config.networking.networkmanager.enable;
        defaultText = lib.literalExpression "config.networking.networkmanager.enable";

        description = ''
          Whether to install the chrony NetworkManager dispatcher script
          to handle connectivity changes.
        '';

        type = lib.types.bool;
      };

      enableMemoryLocking = lib.mkOption {
        default =
          config.environment.memoryAllocator.provider != "graphene-hardened"
          && config.environment.memoryAllocator.provider != "graphene-hardened-light";

        defaultText = lib.literalExpression ''config.environment.memoryAllocator.provider != "graphene-hardened" && config.environment.memoryAllocator.provider != "graphene-hardened-light"'';

        description = ''
          Whether to add the `-m` flag to lock memory.
        '';

        type = lib.types.bool;
      };

      enableNTS = lib.mkOption {
        default = false;

        description = ''
          Whether to enable Network Time Security authentication.
          Make sure it is supported by your selected NTP server(s).
        '';

        type = lib.types.bool;
      };

      enableRTCTrimming = lib.mkOption {
        default = true;

        description = ''
          Enable tracking of the RTC offset to the system clock and automatic trimming.
          See also [](#opt-services.chrony.autotrimThreshold)

          ::: {.note}
          This is not compatible with the `rtcsync` directive, which naively syncs the RTC time every 11 minutes.

          Tracking the RTC drift will allow more precise timekeeping,
          especially on intermittently running devices, where the RTC is very relevant.
          :::
        '';

        type = lib.types.bool;
      };

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Extra configuration directives that should be added to
          {file}`chrony.conf`
        '';

        type = lib.types.lines;
      };

      extraFlags = lib.mkOption {
        default = [ ];
        description = "Extra flags passed to the chronyd command.";
        example = [ "-s" ];
        type = lib.types.listOf lib.types.str;
      };

      initstepslew = {
        enabled = lib.mkOption {
          default = false;

          description = ''
            DEPRECATED. Consider using `services.chrony.makestep` instead.
            Allow chronyd to make a rapid measurement of the system clock error
            at boot time, and to correct the system clock by stepping before
            normal operation begins.
          '';

          type = lib.types.bool;
        };

        threshold = lib.mkOption {
          default = 1000; # by default, same threshold as 'ntpd -g' (1000s)

          description = ''
            The threshold of system clock error (in seconds) above which the
            clock will be stepped. If the correction required is less than the
            threshold, a slew is used instead.
          '';

          type = lib.types.either lib.types.float lib.types.int;
        };
      };

      makestep = {
        enable = lib.mkOption {
          default = true;

          description = ''
            Allow chronyd to step the system clock if the error is larger than
            the specified threshold.
          '';

          type = lib.types.bool;
        };

        limit = lib.mkOption {
          default = 3;

          description = ''
            The maximum number of times the system clock will be stepped.
          '';

          type = lib.types.ints.positive;
        };

        threshold = lib.mkOption {
          default = 0.1;

          description = ''
            The threshold of system clock error (in seconds) above which the
            clock will be stepped. If the correction required is less than the
            threshold, a slew is used instead.
          '';

          type = lib.types.either lib.types.float lib.types.int;
        };
      };

      serverOption = lib.mkOption {
        default = "iburst";

        description = ''
          Set option for server directives.

          Use "iburst" to rapidly poll on startup. Recommended if your machine
          is consistently online.

          Use "offline" to prevent polling on startup. Recommended if your
          machine boots offline or is otherwise frequently offline.
        '';

        type = lib.types.enum [
          "iburst"
          "offline"
        ];
      };

      servers = lib.mkOption {
        default = config.networking.timeServers;
        defaultText = lib.literalExpression "config.networking.timeServers";

        description = ''
          The set of NTP servers from which to synchronise.
        '';

        type = lib.types.listOf lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          !(
            cfg.enableRTCTrimming
            && builtins.any (line: (builtins.match "^ *rtcsync" line) != null) (
              lib.strings.splitString "\n" cfg.extraConfig
            )
          );

        message = ''
          The chrony module now configures `rtcfile` and `rtcautotrim` for you.
          These options conflict with `rtcsync` and cause chrony to crash.
          Unless you are very sure the former isn't what you want, please remove
          `rtcsync` from `services.chrony.extraConfig`.
          Alternatively, disable this behaviour by `services.chrony.enableRTCTrimming = false;`
        '';
      }
    ];

    environment.systemPackages = [ chronyPkg ];

    networking.networkmanager.dispatcherScripts = lib.mkIf cfg.dispatcherScript [
      {
        source = dispatcherScriptFile;
        type = "basic";
      }
    ];

    services.timesyncd.enable = lib.mkForce false;

    systemd.services.chronyd = {
      after = [
        "network.target"
        "nss-lookup.target"
      ];

      before = [ "time-sync.target" ];

      conflicts = [
        "ntpd.service"
        "systemd-timesyncd.service"
      ];

      description = "chrony NTP daemon";
      path = [ chronyPkg ];

      serviceConfig = {
        # Capabilities
        CapabilityBoundingSet = [
          "CAP_CHOWN"
          "CAP_DAC_OVERRIDE"
          "CAP_NET_BIND_SERVICE"
          "CAP_SETGID"
          "CAP_SETUID"
          "CAP_SYS_RESOURCE"
          "CAP_SYS_TIME"
        ];

        # Device Access
        DeviceAllow = [
          "char-pps rw"
          "char-ptp rw"
          "char-rtc rw"
        ];

        DevicePolicy = "closed";
        ExecStart = "${chronyPkg}/bin/chronyd ${toString chronyFlags}";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        # Security
        NoNewPrivileges = true;
        PrivateDevices = false;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = false;
        # Proc filesystem
        ProcSubset = "pid";
        ProtectClock = false;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        # Sandboxing
        ProtectSystem = "full";
        # Access write directories
        ReadWritePaths = [ "${stateDir}" ];
        RemoveIPC = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        # System Call Filtering
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "~@cpu-emulation @debug @keyring @mount @obsolete @privileged @resources"
          "@clock"
          "@setuid"
          "capset"
          "@chown"
        ];

        Type = "notify";
        UMask = "0027";
      };

      unitConfig = lib.mkIf (!lib.elem "-x" cfg.extraFlags && !cfg.enableRTCTrimming) {
        ConditionCapability = "CAP_SYS_TIME";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "time-sync.target" ];
    };

    systemd.services.systemd-timedated.environment = {
      SYSTEMD_TIMEDATED_NTP_SERVICES = "chronyd.service";
    };

    systemd.tmpfiles.rules = [
      "d ${stateDir} 0750 chrony chrony - -"
      "f ${driftFile} 0640 chrony chrony - -"
      "f ${keyFile} 0640 root chrony - -"
    ]
    ++ lib.optionals cfg.enableRTCTrimming [
      "f ${rtcFile} 0640 chrony chrony - -"
    ];

    users.groups.chrony.gid = config.ids.gids.chrony;

    users.users.chrony = {
      description = "chrony daemon user";
      group = "chrony";
      home = stateDir;
      uid = config.ids.uids.chrony;
    };
  };

  meta.maintainers = with lib.maintainers; [
    thoughtpolice
    vifino
  ];
}
