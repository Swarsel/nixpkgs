{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.autorandr;
  hookType = lib.types.lines;

  matrixOf =
    n: m: elemType:
    lib.mkOptionType rec {
      check =
        xss:
        let
          listOfSize = l: xs: lib.isList xs && lib.length xs == l;
        in
        listOfSize n xss && lib.all (xs: listOfSize m xs && lib.all elemType.check xs) xss;

      description = "${toString n}×${toString m} matrix of ${elemType.description}s";

      functor = (
        lib.types.elemTypeFunctor "attrsWith" {
          inherit
            elemType
            name
            ;
        }
      );

      getSubModules = elemType.getSubModules;

      getSubOptions =
        prefix:
        elemType.getSubOptions (
          prefix
          ++ [
            "*"
            "*"
          ]
        );

      merge = lib.mergeOneOption;
      name = "matrixOf";
      substSubModules = mod: matrixOf n m (elemType.substSubModules mod);
    };

  profileModule = lib.types.submodule {
    options = {
      config = lib.mkOption {
        default = { };
        description = "Per output profile configuration.";
        type = lib.types.attrsOf configModule;
      };

      fingerprint = lib.mkOption {
        default = { };

        description = ''
          Output name to EDID mapping.
          Use `autorandr --fingerprint` to get current setup values.
        '';

        type = lib.types.attrsOf lib.types.str;
      };

      hooks = lib.mkOption {
        default = { };
        description = "Profile hook scripts.";
        type = hooksModule;
      };
    };
  };

  configModule = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        default = true;
        description = "Whether to enable the output.";
        type = lib.types.bool;
      };

      crtc = lib.mkOption {
        default = null;
        description = "Output video display controller.";
        example = 0;
        type = lib.types.nullOr lib.types.ints.unsigned;
      };

      dpi = lib.mkOption {
        default = null;
        description = "Output DPI configuration.";
        example = 96;
        type = lib.types.nullOr lib.types.ints.positive;
      };

      gamma = lib.mkOption {
        default = "";
        description = "Output gamma configuration.";
        example = "1.0:0.909:0.833";
        type = lib.types.str;
      };

      mode = lib.mkOption {
        default = "";
        description = "Output resolution.";
        example = "3840x2160";
        type = lib.types.str;
      };

      position = lib.mkOption {
        default = "";
        description = "Output position";
        example = "5760x0";
        type = lib.types.str;
      };

      primary = lib.mkOption {
        default = false;
        description = "Whether output should be marked as primary";
        type = lib.types.bool;
      };

      rate = lib.mkOption {
        default = "";
        description = "Output framerate.";
        example = "60.00";
        type = lib.types.str;
      };

      rotate = lib.mkOption {
        default = null;
        description = "Output rotate configuration.";
        example = "left";

        type = lib.types.nullOr (
          lib.types.enum [
            "normal"
            "left"
            "right"
            "inverted"
          ]
        );
      };

      scale = lib.mkOption {
        default = null;

        description = ''
          Output scale configuration.

          Either configure by pixels or a scaling factor. When using pixel method the
          {manpage}`xrandr(1)`
          option
          `--scale-from`
          will be used; when using factor method the option
          `--scale`
          will be used.

          This option is a shortcut version of the transform option and they are mutually
          exclusive.
        '';

        example = lib.literalExpression ''
          {
            x = 1.25;
            y = 1.25;
          }
        '';

        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              method = lib.mkOption {
                default = "factor";
                description = "Output scaling method.";
                example = "pixel";

                type = lib.types.enum [
                  "factor"
                  "pixel"
                ];
              };

              x = lib.mkOption {
                description = "Horizontal scaling factor/pixels.";
                type = lib.types.either lib.types.float lib.types.ints.positive;
              };

              y = lib.mkOption {
                description = "Vertical scaling factor/pixels.";
                type = lib.types.either lib.types.float lib.types.ints.positive;
              };
            };
          }
        );
      };

      transform = lib.mkOption {
        default = null;

        description = ''
          Refer to
          {manpage}`xrandr(1)`
          for the documentation of the transform matrix.
        '';

        example = lib.literalExpression ''
          [
            [ 0.6 0.0 0.0 ]
            [ 0.0 0.6 0.0 ]
            [ 0.0 0.0 1.0 ]
          ]
        '';

        type = lib.types.nullOr (matrixOf 3 3 lib.types.float);
      };
    };
  };

  hooksModule = lib.types.submodule {
    options = {
      postswitch = lib.mkOption {
        default = { };
        description = "Postswitch hook executed after mode switch.";
        type = lib.types.attrsOf hookType;
      };

      predetect = lib.mkOption {
        default = { };

        description = ''
          Predetect hook executed before autorandr attempts to run xrandr.
        '';

        type = lib.types.attrsOf hookType;
      };

      preswitch = lib.mkOption {
        default = { };
        description = "Preswitch hook executed before mode switch.";
        type = lib.types.attrsOf hookType;
      };
    };
  };

  hookToFile =
    folder: name: hook:
    lib.nameValuePair "xdg/autorandr/${folder}/${name}" {
      source = "${pkgs.writeShellScriptBin "hook" hook}/bin/hook";
    };
  profileToFiles =
    name: profile:
    with profile;
    lib.mkMerge [
      {
        "xdg/autorandr/${name}/config".text = lib.concatStringsSep "\n" (
          lib.mapAttrsToList configToString profile.config
        );

        "xdg/autorandr/${name}/setup".text = lib.concatStringsSep "\n" (
          lib.mapAttrsToList fingerprintToString fingerprint
        );
      }
      (lib.mapAttrs' (hookToFile "${name}/postswitch.d") hooks.postswitch)
      (lib.mapAttrs' (hookToFile "${name}/preswitch.d") hooks.preswitch)
      (lib.mapAttrs' (hookToFile "${name}/predetect.d") hooks.predetect)
    ];
  fingerprintToString = name: edid: "${name} ${edid}";
  configToString =
    name: config:
    if config.enable then
      lib.concatStringsSep "\n" (
        [ "output ${name}" ]
        ++ lib.optional (config.position != "") "pos ${config.position}"
        ++ lib.optional (config.crtc != null) "crtc ${toString config.crtc}"
        ++ lib.optional config.primary "primary"
        ++ lib.optional (config.dpi != null) "dpi ${toString config.dpi}"
        ++ lib.optional (config.gamma != "") "gamma ${config.gamma}"
        ++ lib.optional (config.mode != "") "mode ${config.mode}"
        ++ lib.optional (config.rate != "") "rate ${config.rate}"
        ++ lib.optional (config.rotate != null) "rotate ${config.rotate}"
        ++ lib.optional (config.transform != null) (
          "transform " + lib.concatMapStringsSep "," toString (lib.flatten config.transform)
        )
        ++ lib.optional (config.scale != null) (
          (if config.scale.method == "factor" then "scale" else "scale-from")
          + " ${toString config.scale.x}x${toString config.scale.y}"
        )
      )
    else
      ''
        output ${name}
        off
      '';

in
{

  options = {

    services.autorandr = {
      enable = lib.mkEnableOption "handling of hotplug and sleep events by autorandr";

      defaultTarget = lib.mkOption {
        default = "default";

        description = ''
          Fallback if no monitor layout can be detected. See the docs
          (https://github.com/phillipberndt/autorandr/blob/v1.0/README.md#how-to-use)
          for further reference.
        '';

        type = lib.types.str;
      };

      hooks = lib.mkOption {
        default = { };
        description = "Global hook scripts";

        example = lib.literalExpression ''
          {
            postswitch = {
              "notify-i3" = "''${pkgs.i3}/bin/i3-msg restart";
              "change-background" = readFile ./change-background.sh;
              "change-dpi" = '''
                case "$AUTORANDR_CURRENT_PROFILE" in
                  default)
                    DPI=120
                    ;;
                  home)
                    DPI=192
                    ;;
                  work)
                    DPI=144
                    ;;
                  *)
                    echo "Unknown profle: $AUTORANDR_CURRENT_PROFILE"
                    exit 1
                esac
                echo "Xft.dpi: $DPI" | ''${pkgs.xrdb}/bin/xrdb -merge
              ''';
            };
          }
        '';

        type = hooksModule;
      };

      ignoreLid = lib.mkOption {
        default = false;
        description = "Treat outputs as connected even if their lids are closed";
        type = lib.types.bool;
      };

      matchEdid = lib.mkOption {
        default = false;
        description = "Match displays based on edid instead of name";
        type = lib.types.bool;
      };

      profiles = lib.mkOption {
        default = { };
        description = "Autorandr profiles specification.";

        example = lib.literalExpression ''
          {
            "work" = {
              fingerprint = {
                eDP1 = "<EDID>";
                DP1 = "<EDID>";
              };
              config = {
                eDP1.enable = false;
                DP1 = {
                  enable = true;
                  crtc = 0;
                  primary = true;
                  position = "0x0";
                  mode = "3840x2160";
                  gamma = "1.0:0.909:0.833";
                  rate = "60.00";
                  rotate = "left";
                };
              };
              hooks.postswitch = readFile ./work-postswitch.sh;
            };
          }
        '';

        type = lib.types.attrsOf profileModule;
      };

    };

  };

  config = lib.mkIf cfg.enable {

    environment = {
      etc = lib.mkMerge [
        (lib.mapAttrs' (hookToFile "postswitch.d") cfg.hooks.postswitch)
        (lib.mapAttrs' (hookToFile "preswitch.d") cfg.hooks.preswitch)
        (lib.mapAttrs' (hookToFile "predetect.d") cfg.hooks.predetect)
        (lib.mkMerge (lib.mapAttrsToList profileToFiles cfg.profiles))
      ];

      systemPackages = [ pkgs.autorandr ];
    };

    services.udev.packages = [ pkgs.autorandr ];

    systemd.services.autorandr = {
      after = [ "sleep.target" ];
      description = "Autorandr execution hook";

      serviceConfig = {
        ExecStart = ''
          ${pkgs.autorandr}/bin/autorandr \
            --batch \
            --change \
            --default ${cfg.defaultTarget} \
            ${lib.optionalString cfg.ignoreLid "--ignore-lid"} \
            ${lib.optionalString cfg.matchEdid "--match-edid"}
        '';

        KillMode = "process";
        RemainAfterExit = false;
        Type = "oneshot";
      };

      startLimitBurst = 1;
      startLimitIntervalSec = 5;
      wantedBy = [ "sleep.target" ];
    };

  };

  meta.maintainers = with lib.maintainers; [ alexnortung ];
}
