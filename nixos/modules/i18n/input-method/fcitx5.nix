{
  config,
  lib,
  pkgs,
  ...
}:
let
  imcfg = config.i18n.inputMethod;
  cfg = imcfg.fcitx5;
  fcitx5Package = pkgs.qt6Packages.fcitx5-with-addons.override { inherit (cfg) addons; };
  settingsFormat = pkgs.formats.ini { };
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "i18n" "inputMethod" "fcitx5" "enableRimeData" ] ''
      RIME data is now included in `fcitx5-rime` by default, and can be customized using `fcitx5-rime.override { rimeDataPkgs = ...; }`
    '')
    (lib.mkRemovedOptionModule [ "i18n" "inputMethod" "fcitx5" "plasma6Support" ] ''
      qt6 is the only one used for fcitx5-configtool now.
    '')
  ];

  options = {
    i18n.inputMethod.fcitx5 = {
      addons = lib.mkOption {
        default = [ ];

        description = ''
          Enabled Fcitx5 addons.
        '';

        example = lib.literalExpression "with pkgs; [ fcitx5-rime ]";
        type = with lib.types; listOf package;
      };

      ignoreUserConfig = lib.mkOption {
        default = false;

        description = ''
          Ignore the user configures. **Warning**: When this is enabled, the
          user config files are totally ignored and the user dict can't be saved
          and loaded.
        '';

        type = lib.types.bool;
      };

      quickPhrase = lib.mkOption {
        default = { };
        description = "Quick phrases.";

        example = lib.literalExpression ''
          {
            smile = "（・∀・）";
            angry = "(￣ー￣)";
          }
        '';

        type = with lib.types; attrsOf str;
      };

      quickPhraseFiles = lib.mkOption {
        default = { };
        description = "Quick phrase files.";

        example = lib.literalExpression ''
          {
            words = ./words.mb;
            numbers = ./numbers.mb;
          }
        '';

        type = with lib.types; attrsOf path;
      };

      settings = {
        addons = lib.mkOption {
          default = { };

          description = ''
            The addon configures in `conf` folder in ini format with global sections.
            Each item is written to the corresponding file.
          '';

          example = lib.literalExpression "{ pinyin.globalSection.EmojiEnabled = \"True\"; }";
          type = with lib.types; (attrsOf anything);
        };

        globalOptions = lib.mkOption {
          default = { };

          description = ''
            The global options in `config` file in ini format.
          '';

          type = lib.types.submodule {
            freeformType = settingsFormat.type;
          };
        };

        inputMethod = lib.mkOption {
          default = { };

          description = ''
            The input method configure in `profile` file in ini format.
          '';

          type = lib.types.submodule {
            freeformType = settingsFormat.type;
          };
        };
      };

      waylandFrontend = lib.mkOption {
        default = false;

        description = ''
          Use the Wayland input method frontend.
          See [Using Fcitx 5 on Wayland](https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland).
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf (imcfg.enable && imcfg.type == "fcitx5") {
    environment.etc =
      let
        optionalFile =
          p: f: v:
          lib.optionalAttrs (v != { }) {
            "xdg/fcitx5/${p}".text = f v;
          };
      in
      lib.attrsets.mergeAttrsList [
        (optionalFile "config" (lib.generators.toINI { }) cfg.settings.globalOptions)
        (optionalFile "profile" (lib.generators.toINI { }) cfg.settings.inputMethod)
        (lib.concatMapAttrs (
          name: value: optionalFile "conf/${name}.conf" (lib.generators.toINIWithGlobalSection { }) value
        ) cfg.settings.addons)
      ];

    environment.sessionVariables = lib.mkIf cfg.ignoreUserConfig {
      SKIP_FCITX_USER_PATH = "1";
    };

    environment.variables = {
      QT_PLUGIN_PATH = [ "${fcitx5Package}/${pkgs.qt6.qtbase.qtPluginPrefix}" ];
      XMODIFIERS = "@im=fcitx";
    }
    // lib.optionalAttrs (!cfg.waylandFrontend) {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
    };

    i18n.inputMethod.fcitx5.addons =
      lib.optionals (cfg.quickPhrase != { }) [
        (pkgs.writeTextDir "share/fcitx5/data/QuickPhrase.mb" (
          lib.concatStringsSep "\n" (
            lib.mapAttrsToList (
              name: value:
              "${name} \"${builtins.replaceStrings [ "\\" "\n" "\"" ] [ "\\\\" "\\n" "\\\"" ] value}\""
            ) cfg.quickPhrase
          )
        ))
      ]
      ++ lib.optionals (cfg.quickPhraseFiles != { }) [
        (pkgs.linkFarm "quickPhraseFiles" (
          lib.mapAttrs' (
            name: value: lib.nameValuePair "share/fcitx5/data/quickphrase.d/${name}.mb" value
          ) cfg.quickPhraseFiles
        ))
      ];

    i18n.inputMethod.package = fcitx5Package;
  };
}
