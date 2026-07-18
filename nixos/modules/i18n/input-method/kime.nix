{
  config,
  lib,
  pkgs,
  generators,
  ...
}:
let
  imcfg = config.i18n.inputMethod;
in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "i18n"
      "inputMethod"
      "kime"
      "config"
    ] "Use i18n.inputMethod.kime.* instead")
  ];

  options.i18n.inputMethod.kime = {
    daemonModules = lib.mkOption {
      default = [
        "Xim"
        "Wayland"
        "Indicator"
      ];

      description = ''
        List of enabled daemon modules
      '';

      example = [
        "Xim"
        "Indicator"
      ];

      type = lib.types.listOf (
        lib.types.enum [
          "Xim"
          "Wayland"
          "Indicator"
        ]
      );
    };

    extraConfig = lib.mkOption {
      default = "";

      description = ''
        extra kime configuration. Refer to <https://github.com/Riey/kime/blob/v${pkgs.kime.version}/docs/CONFIGURATION.md> for details on supported values.
      '';

      type = lib.types.lines;
    };

    iconColor = lib.mkOption {
      default = "Black";

      description = ''
        Color of the indicator icon
      '';

      example = "White";

      type = lib.types.enum [
        "Black"
        "White"
      ];
    };
  };

  config = lib.mkIf (imcfg.enable && imcfg.type == "kime") {
    environment.etc."xdg/kime/config.yaml".text = ''
      daemon:
        modules: [${lib.concatStringsSep "," imcfg.kime.daemonModules}]
      indicator:
        icon_color: ${imcfg.kime.iconColor}
    ''
    + imcfg.kime.extraConfig;

    environment.variables = {
      GTK_IM_MODULE = "kime";
      QT_IM_MODULE = "kime";
      XMODIFIERS = "@im=kime";
    };

    i18n.inputMethod.package = pkgs.kime;
  };

  # uses attributes of the linked package
  meta.buildDocsInSandbox = false;
}
