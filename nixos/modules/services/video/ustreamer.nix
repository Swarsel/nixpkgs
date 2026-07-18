{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optionals
    types
    ;

  cfg = config.services.ustreamer;
in
{
  options.services.ustreamer = {
    enable = mkEnableOption "µStreamer, a lightweight MJPEG-HTTP streamer";
    package = mkPackageOption pkgs "ustreamer" { };

    autoStart = mkOption {
      default = true;

      description = ''
        Wether to start µStreamer on boot. Disabling this will use socket
        activation. The service will stop gracefully after some inactivity.
        Disabling this will set `--exit-on-no-clients=300`
      '';

      example = false;
      type = types.bool;
    };

    device = mkOption {
      default = "/dev/video0";

      description = ''
        The v4l2 device to stream.
      '';

      example = "/dev/v4l/by-id/usb-0000_Dummy_abcdef-video-index0";
      type = types.path;
    };

    extraArgs = mkOption {
      default = [ ];

      description = ''
        Extra arguments to pass to `ustreamer`. See {manpage}`ustreamer(1)`
      '';

      example = [ "--resolution=1920x1080" ];
      type = with types; listOf str;
    };

    listenAddress = mkOption {
      default = "0.0.0.0:8080";

      description = ''
        Address to expose the HTTP server. This accepts values for
        ListenStream= defined in {manpage}`systemd.socket(5)`
      '';

      example = "/run/ustreamer.sock";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    services.ustreamer.extraArgs = [
      "--device=${cfg.device}"
    ]
    ++ optionals (!cfg.autoStart) [
      "--exit-on-no-clients=300"
    ];

    systemd.services."ustreamer" = {
      after = [ "network.target" ];
      description = "µStreamer, a lightweight MJPEG-HTTP streamer";
      requires = [ "ustreamer.socket" ];

      serviceConfig = {
        DeviceAllow = [ cfg.device ];
        DynamicUser = true;

        ExecStart = utils.escapeSystemdExecArgs (
          [
            (getExe cfg.package)
            "--systemd"
          ]
          ++ cfg.extraArgs
        );

        NoNewPrivileges = true;
        ProcSubset = "pid";
        ProtectClock = "yes";
        ProtectProc = "noaccess";
        Restart = if cfg.autoStart then "always" else "on-failure";
        SupplementaryGroups = [ "video" ];
      };

      wantedBy = mkIf cfg.autoStart [ "multi-user.target" ];
    };

    systemd.sockets."ustreamer" = {
      partOf = [ "ustreamer.service" ];

      socketConfig = {
        ListenStream = cfg.listenAddress;
      };

      wantedBy = [ "sockets.target" ];
    };
  };
}
