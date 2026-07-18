{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.mediamtx;
  format = pkgs.formats.yaml { };
in
{
  options = {
    services.mediamtx = {
      enable = lib.mkEnableOption "MediaMTX";
      package = lib.mkPackageOption pkgs "mediamtx" { };

      allowVideoAccess = lib.mkEnableOption ''
        access to video devices like cameras on the system
      '';

      env = lib.mkOption {
        default = { };
        description = "Extra environment variables for MediaMTX";

        example = {
          MTX_CONFKEY = "mykey";
        };

        type = with lib.types; attrsOf anything;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          Settings for MediaMTX. Refer to the defaults at
          <https://github.com/bluenviron/mediamtx/blob/main/mediamtx.yml>.
        '';

        example = {
          paths = {
            cam = {
              runOnInit = "\${lib.getExe pkgs.ffmpeg} -f v4l2 -i /dev/video0 -f rtsp rtsp://localhost:$RTSP_PORT/$RTSP_PATH";
              runOnInitRestart = true;
            };
          };
        };

        type = format.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # NOTE: mediamtx watches this file and automatically reloads if it changes
    environment.etc."mediamtx.yaml".source = format.generate "mediamtx.yaml" cfg.settings;

    systemd.services.mediamtx = {
      after = [ "network.target" ];
      environment = cfg.env;

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/mediamtx /etc/mediamtx.yaml";
        Group = "mediamtx";
        Restart = "on-failure";
        SupplementaryGroups = lib.mkIf cfg.allowVideoAccess "video";
        User = "mediamtx";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ fpletz ];
}
