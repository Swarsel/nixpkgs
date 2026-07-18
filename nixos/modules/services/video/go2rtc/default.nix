{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkOption
    mkPackageOption
    types
    ;

  cfg = config.services.go2rtc;
  opt = options.services.go2rtc;

  format = pkgs.formats.yaml { };
  configFile = format.generate "go2rtc.yaml" cfg.settings;
in

{
  options.services.go2rtc = with types; {
    enable = mkEnableOption "go2rtc streaming server";
    package = mkPackageOption pkgs "go2rtc" { };

    settings = mkOption {
      default = { };

      description = ''
        go2rtc configuration as a Nix attribute set.

        See the [wiki](https://github.com/AlexxIT/go2rtc/wiki/Configuration) for possible configuration options.
      '';

      type = submodule {
        options = {
          # https://github.com/AlexxIT/go2rtc/blob/v1.5.0/README.md#module-api
          api = {
            listen = mkOption {
              default = ":1984";

              description = ''
                API listen address, conforming to a Go address string.
              '';

              example = "127.0.0.1:1984";
              type = str;
            };
          };

          # https://github.com/AlexxIT/go2rtc/blob/v1.5.0/README.md#source-ffmpeg
          ffmpeg = {
            bin = mkOption {
              default = lib.getExe pkgs.ffmpeg-headless;
              defaultText = literalExpression "lib.getExe pkgs.ffmpeg-headless";

              description = ''
                The ffmpeg package to use for transcoding.
              '';

              type = path;
            };
          };

          # TODO: https://github.com/AlexxIT/go2rtc/blob/v1.5.0/README.md#module-rtsp
          rtsp = {
          };

          streams = mkOption {
            default = { };

            description = ''
              Stream source configuration. Multiple source types are supported.

              Check the [configuration reference](https://github.com/AlexxIT/go2rtc/blob/v${cfg.package.version}/README.md#module-streams) for possible options.
            '';

            example = literalExpression ''
              {
                cam1 = "onvif://admin:password@192.168.1.123:2020";
                cam2 = "tcp://192.168.1.123:12345";
              }
            '';

            type = attrsOf (either str (listOf str));
          };

          # TODO: https://github.com/AlexxIT/go2rtc/blob/v1.5.0/README.md#module-webrtc
          webrtc = {
          };
        };

        freeformType = format.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.go2rtc = {
      after = [
        "network-online.target"
      ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/go2rtc -config ${configFile}";
        StateDirectory = "go2rtc";

        SupplementaryGroups = [
          # for v4l2 devices
          "video"
        ];

        User = "go2rtc";
      };

      wantedBy = [
        "multi-user.target"
      ];

      wants = [ "network-online.target" ];
    };
  };

  meta.buildDocsInSandbox = false;
}
