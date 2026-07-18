{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkIf
    mkDefault
    getExe
    maintainers
    mkEnableOption
    mkOption
    mkPackageOption
    boolToString
    escapeXML
    nameValuePair
    optionalString
    concatMapStringsSep
    escapeShellArg
    literalExpression
    ;
  inherit (lib.types)
    bool
    enum
    ints
    nullOr
    path
    str
    submodule
    ;
  cfg = config.services.jellyfin;
  filteredDecodingCodecs = builtins.filter (
    c: c != "hevcRExt10bit" && c != "hevcRExt12bit" && cfg.transcoding.hardwareDecodingCodecs.${c}
  ) (builtins.attrNames cfg.transcoding.hardwareDecodingCodecs);
  encodingXmlText = ''
    <?xml version="1.0" encoding="utf-8"?>
    <EncodingOptions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
      <HardwareAccelerationType>${cfg.hardwareAcceleration.type}</HardwareAccelerationType>
      ${optionalString (
        cfg.hardwareAcceleration.type == "vaapi" && cfg.hardwareAcceleration.device != null
      ) "<VaapiDevice>${escapeXML cfg.hardwareAcceleration.device}</VaapiDevice>"}
      ${optionalString (
        cfg.hardwareAcceleration.type == "qsv" && cfg.hardwareAcceleration.device != null
      ) "<OpenclDevice>${escapeXML cfg.hardwareAcceleration.device}</OpenclDevice>"}
      <EncodingThreadCount>${
        if cfg.transcoding.threadCount != null then toString cfg.transcoding.threadCount else "-1"
      }</EncodingThreadCount>
      <EnableThrottling>${boolToString cfg.transcoding.throttleTranscoding}</EnableThrottling>
      <EnableTonemapping>${boolToString cfg.transcoding.enableToneMapping}</EnableTonemapping>
      <EnableSubtitleExtraction>${boolToString cfg.transcoding.enableSubtitleExtraction}</EnableSubtitleExtraction>
      <H264Crf>${toString cfg.transcoding.h264Crf}</H264Crf>
      <H265Crf>${toString cfg.transcoding.h265Crf}</H265Crf>
      <EnableHardwareEncoding>${boolToString cfg.transcoding.enableHardwareEncoding}</EnableHardwareEncoding>
      <AllowHevcEncoding>${boolToString cfg.transcoding.hardwareEncodingCodecs.hevc}</AllowHevcEncoding>
      <AllowAv1Encoding>${boolToString cfg.transcoding.hardwareEncodingCodecs.av1}</AllowAv1Encoding>
      <EnableIntelLowPowerH264HwEncoder>${boolToString cfg.transcoding.enableIntelLowPowerEncoding}</EnableIntelLowPowerH264HwEncoder>
      <EnableIntelLowPowerHevcHwEncoder>${boolToString cfg.transcoding.enableIntelLowPowerEncoding}</EnableIntelLowPowerHevcHwEncoder>
      <EnableDecodingColorDepth10HevcRext>${boolToString cfg.transcoding.hardwareDecodingCodecs.hevcRExt10bit}</EnableDecodingColorDepth10HevcRext>
      <EnableDecodingColorDepth12HevcRext>${boolToString cfg.transcoding.hardwareDecodingCodecs.hevcRExt12bit}</EnableDecodingColorDepth12HevcRext>
      <HardwareDecodingCodecs>
        ${concatMapStringsSep "\n    " (
          codec: "<string>${escapeXML codec}</string>"
        ) filteredDecodingCodecs}
      </HardwareDecodingCodecs>
    </EncodingOptions>
  '';
  encodingXmlFile = pkgs.writeText "encoding.xml" encodingXmlText;
  codecListToType =
    desc: list:
    submodule {
      options = builtins.listToAttrs (
        map (
          name:
          nameValuePair name (mkOption {
            default = false;
            description = "Enable ${desc} for ${name} codec.";
            type = bool;
          })
        ) list
      );
    };
in
{
  options = {
    services.jellyfin = {
      enable = mkEnableOption "Jellyfin Media Server";
      package = mkPackageOption pkgs "jellyfin" { };

      cacheDir = mkOption {
        default = "/var/cache/jellyfin";

        description = ''
          Directory containing the jellyfin server cache,
          passed with `--cachedir` see [#cache-directory](https://jellyfin.org/docs/general/administration/configuration/#cache-directory)
        '';

        type = path;
      };

      configDir = mkOption {
        default = "${cfg.dataDir}/config";
        defaultText = literalExpression ''"''${cfg.dataDir}/config"'';

        description = ''
          Directory containing the server configuration files,
          passed with `--configdir` see [configuration-directory](https://jellyfin.org/docs/general/administration/configuration/#configuration-directory)
        '';

        type = path;
      };

      dataDir = mkOption {
        default = "/var/lib/jellyfin";

        description = ''
          Base data directory,
          passed with `--datadir` see [#data-directory](https://jellyfin.org/docs/general/administration/configuration/#data-directory)
        '';

        type = path;
      };

      forceEncodingConfig = mkOption {
        default = false;

        description = ''
          Whether to overwrite Jellyfin's `encoding.xml` configuration file on each service start.

          When enabled, the encoding configuration specified in {option}`services.jellyfin.transcoding`
          and {option}`services.jellyfin.hardwareAcceleration` will be applied on every service restart.
          A backup of the existing `encoding.xml` will be created at `encoding.xml.backup-$timestamp`.

          ::: {.warning}
          Enabling this option means that any changes made to transcoding settings through
          Jellyfin's web dashboard will be lost on the next service restart. The NixOS configuration
          becomes the single source of truth for encoding settings.
          :::

          When disabled (the default), the encoding configuration is only written if no `encoding.xml`
          exists yet. This allows settings to be changed through Jellyfin's web dashboard and persist
          across restarts, but means the NixOS configuration options will be ignored after the initial setup.
        '';

        type = bool;
      };

      group = mkOption {
        default = "jellyfin";
        description = "Group under which jellyfin runs.";
        type = str;
      };

      hardwareAcceleration = {
        enable = mkEnableOption "hardware acceleration for video transcoding";

        device = mkOption {
          default = null;

          description = ''
            Path to the hardware acceleration device that Jellyfin should use.
            For obscure configurations, additional devices can be added via
            {option}`systemd.services.jellyfin.serviceConfig.DeviceAllow`.
          '';

          example = "/dev/dri/renderD128";
          type = nullOr path;
        };

        # see MediaBrowser.Model/Entities/HardwareAccelerationType.cs in jellyfin source
        type = mkOption {
          default = "none";

          description = ''
            The method of hardware acceleration. See [Hardware Acceleration](https://jellyfin.org/docs/general/post-install/transcoding/hardware-acceleration) for more details.
          '';

          type = enum [
            "none"
            "amf"
            "qsv"
            "nvenc"
            "v4l2m2m"
            "vaapi"
            # videotoolbox is MacOS-only
            "rkmpp"
          ];
        };
      };

      logDir = mkOption {
        default = "${cfg.dataDir}/log";
        defaultText = literalExpression ''"''${cfg.dataDir}/log"'';

        description = ''
          Directory where the Jellyfin logs will be stored,
          passed with `--logdir` see [#log-directory](https://jellyfin.org/docs/general/administration/configuration/#log-directory)
        '';

        type = path;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Open the default ports in the firewall for the media server. The
          HTTP/HTTPS ports can be changed in the Web UI, so this option should
          only be used if they are unchanged, see [Port Bindings](https://jellyfin.org/docs/general/networking/#port-bindings).
        '';

        type = bool;
      };

      transcoding = {
        deleteSegments = mkOption {
          default = true;

          description = ''
            Delete transcoding segments when finished.
          '';

          type = bool;
        };

        enableHardwareEncoding = mkOption {
          default = false;

          description = ''
            Enable hardware encoding for video transcoding.
          '';

          type = bool;
        };

        enableIntelLowPowerEncoding = mkOption {
          default = false;

          description = ''
            Enable low-power encoding mode for Intel Quick Sync Video.
            Requires i915 HuC firmware to be configured.
          '';

          type = bool;
        };

        enableSubtitleExtraction = mkOption {
          default = true;

          description = ''
            Embedded subtitles can be extracted from videos and delivered to clients in plain text, in order to help prevent video transcoding. On some systems this can take a long time and cause video playback to stall during the extraction process. Disable this to have embedded subtitles burned in with video transcoding when they are not natively supported by the client device.
          '';

          type = bool;
        };

        enableToneMapping = mkOption {
          default = true;

          description = ''
            Enable tone mapping when transcoding HDR content.
          '';

          type = bool;
        };

        encodingPreset = mkOption {
          default = "auto";

          description = ''
            Encoder preset for transcoding.
            Lower presets sacrifice quality for speed, higher presets optimize quality.
          '';

          type = enum [
            "auto"
            "veryslow"
            "slower"
            "slow"
            "medium"
            "fast"
            "faster"
            "veryfast"
            "superfast"
            "ultrafast"
          ];
        };

        h264Crf = mkOption {
          default = 23;

          description = ''
            Constant Rate Factor (CRF) for H.264 encoding. Lower values result in better quality. Range: 0-51.
          '';

          type = ints.between 0 51;
        };

        h265Crf = mkOption {
          default = 28;

          description = ''
            Constant Rate Factor (CRF) for H.265 encoding. Lower values result in better quality. Range: 0-51.
          '';

          type = ints.between 0 51;
        };

        hardwareDecodingCodecs = mkOption {
          default = { };

          description = ''
            Which codecs to enable for hardware decoding.
          '';

          example = {
            h264 = true;
            vp9 = true;
          };

          type = codecListToType "hardware decoding" [
            "h264"
            "hevc"
            "mpeg2"
            "vc1"
            "vp8"
            "vp9"
            "av1"
            "hevc10bit"
            "hevcRExt10bit"
            "hevcRExt12bit"
          ];
        };

        hardwareEncodingCodecs = mkOption {
          default = { };

          description = ''
            Which codecs to enable for hardware encoding. h264 is always enabled.
          '';

          example = {
            av1 = true;
          };

          type = codecListToType "hardware encoding" [
            "hevc"
            "av1"
          ];
        };

        maxConcurrentStreams = mkOption {
          default = null;

          description = ''
            Maximum number of concurrent transcoding streams.
            Set to null for unlimited (limited by hardware capabilities).
          '';

          example = 2;
          type = nullOr ints.positive;
        };

        threadCount = mkOption {
          default = null;

          description = ''
            Number of threads to use when transcoding.
            Set to null to use automatic detection.
          '';

          example = 4;
          type = nullOr ints.positive;
        };

        throttleTranscoding = mkOption {
          default = false;

          description = ''
            When a transcode or remux gets far enough ahead from the current playback position, pause the process so it will consume fewer resources. This is most useful when watching without seeking often. Turn this off if you experience playback issues.
          '';

          type = bool;
        };
      };

      user = mkOption {
        default = "jellyfin";
        description = "User account under which Jellyfin runs.";
        type = str;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.hardwareAcceleration.enable -> cfg.hardwareAcceleration.device != null;
        message = "services.jellyfin.hardwareAcceleration.device cannot be null when hardware acceleration is enabled.";
      }
    ];

    networking.firewall = mkIf cfg.openFirewall {
      # from https://jellyfin.org/docs/general/networking/index.html
      allowedTCPPorts = [
        8096
        8920
      ];

      allowedUDPPorts = [
        1900
        7359
      ];
    };

    systemd = {
      services.jellyfin = {
        after = [ "network-online.target" ];
        description = "Jellyfin Media Server";

        preStart = mkIf cfg.hardwareAcceleration.enable (
          ''
            configDir=${escapeShellArg cfg.configDir}
            encodingXml="$configDir/encoding.xml"
          ''
          + (
            if cfg.forceEncodingConfig then
              ''
                if [[ -e $encodingXml ]]; then
                  # this intentionally removes trailing newlines
                  currentText="$(<"$encodingXml")"
                  configuredText="$(<${encodingXmlFile})"
                  if [[ $currentText == "$configuredText" ]]; then
                    # don't need to do anything
                    exit 0
                  else
                    encodingXmlBackup="$configDir/encoding.xml.backup-$(date -u +"%FT%H_%M_%SZ")"
                    mv --update=none-fail -T "$encodingXml" "$encodingXmlBackup"
                  fi
                fi
                cp --update=none-fail -T ${encodingXmlFile} "$encodingXml"
                chmod u+w "$encodingXml"
              ''
            else
              ''
                if [[ -e $encodingXml ]]; then
                  # this intentionally removes trailing newlines
                  currentText="$(<"$encodingXml")"
                  configuredText="$(<${encodingXmlFile})"
                  if [[ $currentText != "$configuredText" ]]; then
                    echo "WARN: $encodingXml already exists and is different from the configured settings. transcoding options NOT applied." >&2
                    echo "WARN: Set config.services.jellyfin.forceEncodingConfig = true to override." >&2
                  fi
                else
                  cp --update=none-fail -T ${encodingXmlFile} "$encodingXml"
                  chmod u+w "$encodingXml"
                fi
              ''
          )
        );

        # This is mostly follows: https://github.com/jellyfin/jellyfin/blob/master/fedora/jellyfin.service
        # Upstream also disable some hardenings when running in LXC, we do the same with the isContainer option
        serviceConfig = {
          # Security options:
          CapabilityBoundingSet = [ "" ];
          DeviceAllow = mkIf cfg.hardwareAcceleration.enable [ "${cfg.hardwareAcceleration.device} rw" ];
          ExecStart = "${getExe cfg.package} --datadir '${cfg.dataDir}' --configdir '${cfg.configDir}' --cachedir '${cfg.cacheDir}' --logdir '${cfg.logDir}'";
          Group = cfg.group;
          LockPersonality = true;
          NoNewPrivileges = true;
          # needed for hardware acceleration
          # PrivateDevices defaults to false for backwards compatibility - users may have
          # hardware acceleration set up outside of NixOS configuration
          PrivateDevices = mkDefault false;
          PrivateTmp = !config.boot.isContainer;
          PrivateUsers = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = !config.boot.isContainer;
          ProtectHostname = true;
          ProtectKernelLogs = !config.boot.isContainer;
          ProtectKernelModules = !config.boot.isContainer;
          ProtectKernelTunables = !config.boot.isContainer;
          ProtectProc = "invisible";
          ProtectSystem = true;
          RemoveIPC = true;
          Restart = "on-failure";

          # AF_NETLINK needed because Jellyfin monitors the network connection
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
          ];

          RestrictNamespaces = !config.boot.isContainer;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;

          SuccessExitStatus = [
            "0"
            "143"
          ];

          SystemCallArchitectures = "native";
          SystemCallErrorNumber = "EPERM";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
          ];

          TimeoutSec = 15;
          Type = "simple";
          UMask = "0077";
          User = cfg.user;
          WorkingDirectory = cfg.dataDir;
        };

        unitConfig.RequiresMountsFor = [
          cfg.configDir
          cfg.logDir
          cfg.cacheDir
        ];

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
      };

      tmpfiles.settings.jellyfinDirs = {
        "${cfg.cacheDir}"."d" = {
          inherit (cfg) user group;
          mode = "700";
        };

        "${cfg.configDir}"."d" = {
          inherit (cfg) user group;
          mode = "700";
        };

        "${cfg.dataDir}"."d" = {
          inherit (cfg) user group;
          mode = "700";
        };

        "${cfg.logDir}"."d" = {
          inherit (cfg) user group;
          mode = "700";
        };
      };
    };

    users.groups = mkIf (cfg.group == "jellyfin") {
      jellyfin = { };
    };

    users.users = mkIf (cfg.user == "jellyfin") {
      jellyfin = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    };

  };

  meta.maintainers = with maintainers; [
    minijackson
    fsnkty
  ];
}
