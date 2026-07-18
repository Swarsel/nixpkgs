{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let

  inherit (lib)
    attrValues
    concatStringsSep
    filterAttrs
    length
    listToAttrs
    literalExpression
    makeSearchPathOutput
    mkEnableOption
    mkIf
    mkOption
    nameValuePair
    optionals
    types
    ;
  inherit (utils) escapeSystemdPath;

  cfg = config.services.v4l2-relayd;

  kernelPackages = config.boot.kernelPackages;

  gst = (
    with pkgs.gst_all_1;
    [
      gst-plugins-bad
      gst-plugins-base
      gst-plugins-good
      gstreamer.out
    ]
  );

  instanceOpts =
    { name, ... }:
    {
      options = {
        enable = mkEnableOption "this v4l2-relayd instance";

        cardLabel = mkOption {
          description = ''
            The name the camera will show up as.
          '';

          type = types.str;
        };

        extraPackages = mkOption {
          default = [ ];

          description = ''
            Extra packages to add to {env}`GST_PLUGIN_PATH` for the instance.
          '';

          type = with types; listOf package;
        };

        input = {
          format = mkOption {
            default = "YUY2";

            description = ''
              The video-format to read from input-stream.
            '';

            type = types.str;
          };

          framerate = mkOption {
            default = 30;

            description = ''
              The framerate to read from input-stream.
            '';

            type = types.ints.positive;
          };

          height = mkOption {
            default = 720;

            description = ''
              The height to read from input-stream.
            '';

            type = types.ints.positive;
          };

          pipeline = mkOption {
            description = ''
              The gstreamer-pipeline to use for the input-stream.
            '';

            type = types.str;
          };

          width = mkOption {
            default = 1280;

            description = ''
              The width to read from input-stream.
            '';

            type = types.ints.positive;
          };
        };

        name = mkOption {
          default = name;

          description = ''
            The name of the instance.
          '';

          type = types.str;
        };

        output = {
          format = mkOption {
            default = "YUY2";

            description = ''
              The video-format to write to output-stream.
            '';

            type = types.str;
          };
        };

      };
    };

in
{

  options.services.v4l2-relayd = {

    instances = mkOption {
      default = { };

      description = ''
        v4l2-relayd instances to be created.
      '';

      example = literalExpression ''
        {
          example = {
            cardLabel = "Example card";
            input.pipeline = "videotestsrc";
          };
        }
      '';

      type = with types; attrsOf (submodule instanceOpts);
    };

  };

  config =
    let

      mkInstanceService = instance: {
        after = [
          "modprobe@v4l2loopback.service"
          "systemd-logind.service"
        ];

        description = "Streaming relay for v4l2loopback using GStreamer";

        environment = {
          GST_PLUGIN_PATH = makeSearchPathOutput "lib" "lib/gstreamer-1.0" (gst ++ instance.extraPackages);
          V4L2_DEVICE_FILE = "/run/v4l2-relayd-${instance.name}/device";
        };

        postStop = ''
          ${kernelPackages.v4l2loopback.bin}/bin/v4l2loopback-ctl delete $(cat $V4L2_DEVICE_FILE)
          rm -rf $(dirname $V4L2_DEVICE_FILE)
        '';

        preStart = ''
          mkdir -p $(dirname $V4L2_DEVICE_FILE)
          ${kernelPackages.v4l2loopback.bin}/bin/v4l2loopback-ctl add -x 1 -n "${instance.cardLabel}" > $V4L2_DEVICE_FILE
        '';

        script =
          let
            appsrcOptions = concatStringsSep "," [
              "caps=video/x-raw"
              "format=${instance.input.format}"
              "width=${toString instance.input.width}"
              "height=${toString instance.input.height}"
              "framerate=${toString instance.input.framerate}/1"
            ];

            outputPipeline = [
              "appsrc name=appsrc ${appsrcOptions}"
              "videoconvert"
            ]
            ++ optionals (instance.input.format != instance.output.format) [
              "video/x-raw,format=${instance.output.format}"
              "queue"
            ]
            ++ [ "v4l2sink name=v4l2sink device=$(cat $V4L2_DEVICE_FILE)" ];
          in
          ''
            exec ${pkgs.v4l2-relayd}/bin/v4l2-relayd -i "${instance.input.pipeline}" -o "${concatStringsSep " ! " outputPipeline}"
          '';

        serviceConfig = {
          LimitNPROC = 1;
          PrivateNetwork = true;
          PrivateTmp = true;
          Restart = "always";
          Type = "simple";
        };

        wantedBy = [ "multi-user.target" ];
      };

      mkInstanceServices =
        instances:
        listToAttrs (
          map (
            instance:
            nameValuePair "v4l2-relayd-${escapeSystemdPath instance.name}" (mkInstanceService instance)
          ) instances
        );

      enabledInstances = attrValues (filterAttrs (n: v: v.enable) cfg.instances);

    in
    {

      boot = mkIf ((length enabledInstances) > 0) {
        # Prevent v4l2loopback from auto-creating a device at load time. An
        # unconfigured device has a degenerate framerate range that breaks
        # GStreamer caps negotiation. All devices are created at runtime via
        # v4l2loopback-ctl add in each instance's preStart instead.
        extraModprobeConfig = "options v4l2loopback devices=0";
        extraModulePackages = [ kernelPackages.v4l2loopback ];
        kernelModules = [ "v4l2loopback" ];
      };

      systemd.services = mkInstanceServices enabledInstances;

    };

  meta.maintainers = with lib.maintainers; [ betaboon ];
}
