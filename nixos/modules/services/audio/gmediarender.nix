{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.gmediarender;
in
{
  options.services.gmediarender = {
    enable = lib.mkEnableOption "the gmediarender DLNA renderer";

    package = lib.mkPackageOption pkgs "gmediarender" {
      default = "gmrender-resurrect";
    };

    audioDevice = lib.mkOption {
      default = null;

      description = ''
        The audio device to use.
      '';

      type = lib.types.nullOr lib.types.str;
    };

    audioSink = lib.mkOption {
      default = null;

      description = ''
        The audio sink to use.
      '';

      type = lib.types.nullOr lib.types.str;
    };

    friendlyName = lib.mkOption {
      default = null;

      description = ''
        A "friendly name" for identifying the endpoint.
      '';

      type = lib.types.nullOr lib.types.str;
    };

    initialVolume = lib.mkOption {
      default = 0;

      description = ''
        A default volume attenuation (in dB) for the endpoint.
      '';

      type = lib.types.nullOr lib.types.int;
    };

    port = lib.mkOption {
      default = null;
      description = "Port that will be used to accept client connections.";
      type = lib.types.nullOr lib.types.port;
    };

    uuid = lib.mkOption {
      default = null;

      description = ''
        A UUID for uniquely identifying the endpoint.  If you have
        multiple renderers on your network, you MUST set this.
      '';

      type = lib.types.nullOr lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      services.gmediarender = {
        after = [ "network-online.target" ];
        description = "gmediarender server daemon";

        environment = {
          XDG_CACHE_HOME = "%t/gmediarender";
        };

        serviceConfig = {
          # Security options:
          CapabilityBoundingSet = "";
          DynamicUser = true;

          ExecStart =
            "${cfg.package}/bin/gmediarender "
            + lib.optionalString (
              cfg.audioDevice != null
            ) "--gstout-audiodevice=${utils.escapeSystemdExecArg cfg.audioDevice} "

            + lib.optionalString (
              cfg.audioSink != null
            ) "--gstout-audiosink=${utils.escapeSystemdExecArg cfg.audioSink} "

            + lib.optionalString (
              cfg.friendlyName != null
            ) "--friendly-name=${utils.escapeSystemdExecArg cfg.friendlyName} "

            + lib.optionalString (cfg.initialVolume != 0) "--initial-volume=${toString cfg.initialVolume} "
            + lib.optionalString (cfg.port != null) "--port=${toString cfg.port} "
            + lib.optionalString (cfg.uuid != null) "--uuid=${utils.escapeSystemdExecArg cfg.uuid} ";

          Group = "gmediarender";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          # PrivateDevices = true;
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
          Restart = "always";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RuntimeDirectory = "gmediarender";
          SupplementaryGroups = [ "audio" ];
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
          ];

          UMask = 66;
          User = "gmediarender";
        };

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
      };
    };
  };
}
