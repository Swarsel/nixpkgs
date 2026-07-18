{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.wyoming.openwakeword;

  inherit (lib)
    concatMap
    mkOption
    mkEnableOption
    mkIf
    mkPackageOption
    mkRemovedOptionModule
    types
    ;

  inherit (builtins)
    toString
    ;

  inherit (utils)
    escapeSystemdExecArgs
    ;
in

{
  imports = [
    (mkRemovedOptionModule [
      "services"
      "wymoing"
      "openwakeword"
      "preLoadModels"
    ] "Passing a list of models to preload was removed in wyoming-openwakeword 2.0")
  ];

  options.services.wyoming.openwakeword = with types; {
    enable = mkEnableOption "Wyoming protocol server for openWakeWord wake word detection system";
    package = mkPackageOption pkgs "wyoming-openwakeword" { };

    customModelsDirectories = mkOption {
      default = [ ];

      description = ''
        Paths to directories with custom wake word models (*.tflite model files).
      '';

      type = listOf types.path;
    };

    extraArgs = mkOption {
      default = [ ];

      description = ''
        Extra arguments to pass to the server commandline.
      '';

      type = listOf str;
    };

    refractorySeconds = mkOption {
      apply = toString;
      default = 2;

      description = ''
        Duration in seconds before a wake word can be detected again.
      '';

      example = 1.5;
      type = either int float;
    };

    threshold = mkOption {
      apply = toString;
      default = 0.5;

      description = ''
        Activation threshold (0.0-1.0), where higher means fewer activations.

        See trigger level for the relationship between activations and
        wake word detections.
      '';

      type = numbers.between 0.0 1.0;
    };

    triggerLevel = mkOption {
      apply = toString;
      default = 1;

      description = ''
        Number of activations before a detection is registered.

        A higher trigger level means fewer detections.
      '';

      type = ints.unsigned;
    };

    uri = mkOption {
      default = "tcp://0.0.0.0:10400";

      description = ''
        URI to bind the wyoming server to.
      '';

      example = "tcp://192.0.2.1:5000";
      type = strMatching "^(tcp|unix)://.*$";
    };
  };

  config = mkIf cfg.enable {
    systemd.services."wyoming-openwakeword" = {
      after = [
        "network-online.target"
      ];

      description = "Wyoming openWakeWord server";

      serviceConfig = {
        CapabilityBoundingSet = "";
        DeviceAllow = "";
        DevicePolicy = "closed";
        DynamicUser = true;

        # https://github.com/home-assistant/addons/blob/master/openwakeword/rootfs/etc/s6-overlay/s6-rc.d/openwakeword/run
        ExecStart = escapeSystemdExecArgs (
          [
            (lib.getExe cfg.package)
            "--uri"
            cfg.uri
            "--threshold"
            cfg.threshold
            "--trigger-level"
            cfg.triggerLevel
            "--refractory-seconds"
            cfg.refractorySeconds
          ]
          ++ (concatMap (dir: [
            "--custom-model-dir"
            (toString dir)
          ]) cfg.customModelsDirectories)
          ++ cfg.extraArgs
        );

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProcSubset = "all"; # reads /proc/cpuinfo
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RuntimeDirectory = "wyoming-openwakeword";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        UMask = "0077";
        User = "wyoming-openwakeword";
      };

      wantedBy = [
        "multi-user.target"
      ];

      wants = [
        "network-online.target"
      ];
    };
  };
}
