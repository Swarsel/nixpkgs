{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.wyoming.satellite;

  inherit (lib)
    elem
    escapeShellArgs
    getExe
    literalExpression
    mkOption
    mkEnableOption
    mkIf
    mkPackageOption
    optional
    optionals
    types
    ;

  finalPackage = cfg.package.overridePythonAttrs (oldAttrs: {
    dependencies =
      oldAttrs.dependencies
      # for audio enhancements like auto-gain, noise suppression
      ++ cfg.package.optional-dependencies.webrtc
      # vad is currently optional, because it is broken on aarch64-linux
      ++ optionals cfg.vad.enable cfg.package.optional-dependencies.silerovad;
  });
in

{
  options.services.wyoming.satellite = with types; {
    enable = mkEnableOption "Wyoming Satellite";
    package = mkPackageOption pkgs "wyoming-satellite" { };

    area = mkOption {
      default = null;

      description = ''
        Area to the satellite.
      '';

      example = "Kitchen";
      type = nullOr str;
    };

    extraArgs = mkOption {
      default = [ ];

      description = ''
        Extra arguments to pass to the executable.

        Check `wyoming-satellite --help` for possible options.
      '';

      type = listOf str;
    };

    group = mkOption {
      default = "users";

      description = ''
        Group to run wyoming-satellite under.
      '';

      type = str;
    };

    microphone = {
      autoGain = mkOption {
        default = 5;

        description = ''
          Automatic gain control in dbFS, with 31 being the loudest value. Set to 0 to disable.
        '';

        example = 15;
        type = ints.between 0 31;
      };

      command = mkOption {
        default = "arecord -r 16000 -c 1 -f S16_LE -t raw";

        description = ''
          Program to run for audio input.
        '';

        type = str;
      };

      noiseSuppression = mkOption {
        default = 2;

        description = ''
          Noise suppression level with 4 being the maximum suppression,
          which may cause audio distortion. Set to 0 to disable.
        '';

        example = 3;
        type = ints.between 0 4;
      };
    };

    name = mkOption {
      default = config.networking.hostName;

      defaultText = literalExpression ''
        config.networking.hostName
      '';

      description = ''
        Name of the satellite.
      '';

      type = str;
    };

    sound = {
      command = mkOption {
        default = "aplay -r 22050 -c 1 -f S16_LE -t raw";

        description = ''
          Program to run for sound output.
        '';

        type = nullOr str;
      };
    };

    sounds = {
      awake = mkOption {
        default = null;

        description = ''
          Path to audio file in WAV format to play when wake word is detected.
        '';

        type = nullOr path;
      };

      done = mkOption {
        default = null;

        description = ''
          Path to audio file in WAV format to play when voice command recording has ended.
        '';

        type = nullOr path;
      };
    };

    uri = mkOption {
      default = "tcp://0.0.0.0:10700";

      description = ''
        URI where wyoming-satellite will bind its socket.
      '';

      type = str;
    };

    user = mkOption {
      description = ''
        User to run wyoming-satellite under.
      '';

      example = "alice";
      type = str;
    };

    vad = {
      enable = mkOption {
        default = true;

        description = ''
          Whether to enable voice activity detection.

          Enabling will result in only streaming audio, when speech gets
          detected.
        '';

        type = bool;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services."wyoming-satellite" = {
      after = [
        "network-online.target"
        "sound.target"
      ];

      description = "Wyoming Satellite";

      path = with pkgs; [
        alsa-utils
      ];

      script =
        let
          optionalParam =
            param: argument:
            optionals
              (
                !elem argument [
                  null
                  0
                  false
                ]
              )
              [
                param
                argument
              ];
        in
        ''
          export XDG_RUNTIME_DIR=/run/user/$UID
          ${escapeShellArgs (
            [
              (getExe finalPackage)
              "--uri"
              cfg.uri
              "--name"
              cfg.name
              "--mic-command"
              cfg.microphone.command
            ]
            ++ optionalParam "--mic-auto-gain" cfg.microphone.autoGain
            ++ optionalParam "--mic-noise-suppression" cfg.microphone.noiseSuppression
            ++ optionalParam "--area" cfg.area
            ++ optionalParam "--snd-command" cfg.sound.command
            ++ optionalParam "--awake-wav" cfg.sounds.awake
            ++ optionalParam "--done-wav" cfg.sounds.done
            ++ optional cfg.vad.enable "--vad"
            ++ cfg.extraArgs
          )}
        '';

      serviceConfig = {
        # https://github.com/rhasspy/hassio-addons/blob/master/assist_microphone/rootfs/etc/s6-overlay/s6-rc.d/assist_microphone/run
        CapabilityBoundingSet = "";
        DeviceAllow = "";
        DevicePolicy = "closed";
        Group = cfg.group;
        LockPersonality = true;
        MemoryDenyWriteExecute = false; # onnxruntime/capi/onnxruntime_pybind11_state.so: cannot enable executable stack as shared object requires: Operation not permitted
        PrivateDevices = true;
        PrivateUsers = true;
        ProcSubset = "all"; # Error in cpuinfo: failed to parse processor information from /proc/cpuinfo
        ProtectControlGroups = true;
        ProtectHome = false; # Would deny access to local pulse/pipewire server
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
          "AF_NETLINK"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;

        SupplementaryGroups = [
          "audio"
        ];

        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        UMask = "0077";
        User = cfg.user;
      };

      wantedBy = [
        "multi-user.target"
      ];

      wants = [
        "network-online.target"
        "sound.target"
      ];
    };
  };

  meta.buildDocsInSandbox = false;
}
