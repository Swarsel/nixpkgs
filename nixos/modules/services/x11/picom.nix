{
  config,
  lib,
  pkgs,
  options,
  ...
}:

with lib;

let

  cfg = config.services.picom;
  opt = options.services.picom;

  pairOf =
    x:
    with types;
    addCheck (listOf x) (y: length y == 2) // { description = "pair of ${x.description}"; };

  mkDefaultAttrs = mapAttrs (n: v: mkDefault v);

  # Basically a tinkered lib.generators.mkKeyValueDefault
  # It either serializes a top-level definition "key: { values };"
  # or an expression "key = { values };"
  mkAttrsString =
    top:
    mapAttrsToList (
      k: v:
      let
        sep = if (top && isAttrs v) then ":" else "=";
      in
      "${escape [ sep ] k}${sep}${mkValueString v};"
    );

  # This serializes a Nix expression to the libconfig format.
  mkValueString =
    v:
    if types.bool.check v then
      boolToString v
    else if types.int.check v then
      toString v
    else if types.float.check v then
      toString v
    else if types.str.check v then
      "\"${escape [ "\"" ] v}\""
    else if builtins.isList v then
      "[ ${concatMapStringsSep " , " mkValueString v} ]"
    else if types.attrs.check v then
      "{ ${concatStringsSep " " (mkAttrsString false v)} }"
    else
      throw ''
        invalid expression used in option services.picom.settings:
        ${v}
      '';

  toConf = attrs: concatStringsSep "\n" (mkAttrsString true cfg.settings);

  configFile = pkgs.writeText "picom.conf" (toConf cfg.settings);

in
{

  imports = [
    (mkAliasOptionModule [ "services" "compton" ] [ "services" "picom" ])
    (mkRemovedOptionModule [ "services" "picom" "refreshRate" ] ''
      This option corresponds to `refresh-rate`, which has been unused
      since picom v6 and was subsequently removed by upstream.
      See https://github.com/yshui/picom/commit/bcbc410
    '')
    (mkRemovedOptionModule [ "services" "picom" "experimentalBackends" ] ''
      This option was removed by upstream since picom v10.
    '')
  ];

  options.services.picom = {
    enable = mkOption {
      default = false;

      description = ''
        Whether or not to enable Picom as the X.org composite manager.
      '';

      type = types.bool;
    };

    package = mkPackageOption pkgs "picom" { };

    activeOpacity = mkOption {
      default = 1.0;

      description = ''
        Opacity of active windows.
      '';

      example = 0.8;
      type = types.numbers.between 0 1;
    };

    backend = mkOption {
      default = "xrender";

      description = ''
        Backend to use: `egl`, `glx`, `xrender` or `xr_glx_hybrid`.
      '';

      type = types.enum [
        "egl"
        "glx"
        "xrender"
        "xr_glx_hybrid"
      ];
    };

    fade = mkOption {
      default = false;

      description = ''
        Fade windows in and out.
      '';

      type = types.bool;
    };

    fadeDelta = mkOption {
      default = 10;

      description = ''
        Time between fade animation step (in ms).
      '';

      example = 5;
      type = types.ints.positive;
    };

    fadeExclude = mkOption {
      default = [ ];

      description = ''
        List of conditions of windows that should not be faded.
        See {manpage}`picom(1)` man page for more examples.
      '';

      example = [
        "window_type *= 'menu'"
        "name ~= 'Firefox$'"
        "focused = 1"
      ];

      type = types.listOf types.str;
    };

    fadeSteps = mkOption {
      default = [
        0.028
        0.03
      ];

      description = ''
        Opacity change between fade steps (in and out).
      '';

      example = [
        0.04
        0.04
      ];

      type = pairOf (types.numbers.between 0.01 1);
    };

    inactiveOpacity = mkOption {
      default = 1.0;

      description = ''
        Opacity of inactive windows.
      '';

      example = 0.8;
      type = types.numbers.between 0.1 1;
    };

    menuOpacity = mkOption {
      default = 1.0;

      description = ''
        Opacity of dropdown and popup menu.
      '';

      example = 0.8;
      type = types.numbers.between 0 1;
    };

    opacityRules = mkOption {
      default = [ ];

      description = ''
        Rules that control the opacity of windows, in format PERCENT:PATTERN.
      '';

      example = [
        "95:class_g = 'URxvt' && !_NET_WM_STATE@:32a"
        "0:_NET_WM_STATE@:32a *= '_NET_WM_STATE_HIDDEN'"
      ];

      type = types.listOf types.str;
    };

    settings =
      with types;
      let
        scalar =
          oneOf [
            bool
            int
            float
            str
          ]
          // {
            description = "scalar types";
          };

        libConfig =
          oneOf [
            scalar
            (listOf libConfig)
            (attrsOf libConfig)
          ]
          // {
            description = "libconfig type";
          };

        topLevel = attrsOf libConfig // {
          description = ''
            libconfig configuration. The format consists of an attributes
            set (called a group) of settings. Each setting can be a scalar type
            (boolean, integer, floating point number or string), a list of
            scalars or a group itself
          '';
        };

      in
      mkOption {
        default = { };

        description = ''
          Picom settings. Use this option to configure Picom settings not exposed
          in a NixOS option or to bypass one.  For the available options see the
          CONFIGURATION FILES section at {manpage}`picom(1)`.
        '';

        example = literalExpression ''
          blur =
            { method = "gaussian";
              size = 10;
              deviation = 5.0;
            };
        '';

        type = topLevel;
      };

    shadow = mkOption {
      default = false;

      description = ''
        Draw window shadows.
      '';

      type = types.bool;
    };

    shadowExclude = mkOption {
      default = [ ];

      description = ''
        List of conditions of windows that should have no shadow.
        See {manpage}`picom(1)` man page for more examples.
      '';

      example = [
        "window_type *= 'menu'"
        "name ~= 'Firefox$'"
        "focused = 1"
      ];

      type = types.listOf types.str;
    };

    shadowOffsets = mkOption {
      default = [
        (-15)
        (-15)
      ];

      description = ''
        Left and right offset for shadows (in pixels).
      '';

      example = [
        (-10)
        (-15)
      ];

      type = pairOf types.int;
    };

    shadowOpacity = mkOption {
      default = 0.75;

      description = ''
        Window shadows opacity.
      '';

      example = 0.8;
      type = types.numbers.between 0 1;
    };

    vSync = mkOption {
      apply =
        x:
        let
          res = x != "none";
          msg =
            "The type of services.picom.vSync has changed to bool:"
            + " interpreting ${x} as ${boolToString res}";
        in
        if isBool x then x else warn msg res;

      default = false;

      description = ''
        Enable vertical synchronization. Chooses the best method
        (drm, opengl, opengl-oml, opengl-swc, opengl-mswc) automatically.
        The bool value should be used, the others are just for backwards compatibility.
      '';

      type =
        with types;
        either bool (enum [
          "none"
          "drm"
          "opengl"
          "opengl-oml"
          "opengl-swc"
          "opengl-mswc"
        ]);
    };

    wintypes = mkOption {
      default = {
        dropdown_menu = {
          opacity = cfg.menuOpacity;
        };

        popup_menu = {
          opacity = cfg.menuOpacity;
        };
      };

      defaultText = literalExpression ''
        {
          popup_menu = { opacity = config.${opt.menuOpacity}; };
          dropdown_menu = { opacity = config.${opt.menuOpacity}; };
        }
      '';

      description = ''
        Rules for specific window types.
      '';

      example = { };
      type = types.attrs;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    services.picom.settings = mkDefaultAttrs {
      # opacity
      active-opacity = cfg.activeOpacity;
      # other options
      backend = cfg.backend;
      fade-delta = cfg.fadeDelta;
      fade-exclude = cfg.fadeExclude;
      fade-in-step = elemAt cfg.fadeSteps 0;
      fade-out-step = elemAt cfg.fadeSteps 1;
      # fading
      fading = cfg.fade;
      inactive-opacity = cfg.inactiveOpacity;
      opacity-rule = cfg.opacityRules;
      # shadows
      shadow = cfg.shadow;
      shadow-exclude = cfg.shadowExclude;
      shadow-offset-x = elemAt cfg.shadowOffsets 0;
      shadow-offset-y = elemAt cfg.shadowOffsets 1;
      shadow-opacity = cfg.shadowOpacity;
      vsync = cfg.vSync;
      wintypes = cfg.wintypes;
    };

    systemd.user.services.picom = {
      description = "Picom composite manager";

      # Temporarily fixes corrupt colours with Mesa 18
      environment = mkIf (cfg.backend == "glx") {
        allow_rgb10_configs = "false";
      };

      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = "${getExe cfg.package} --config ${configFile}";
        Restart = "always";
        RestartSec = 3;
      };

      wantedBy = [ "graphical-session.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ rnhmjoj ];

}
