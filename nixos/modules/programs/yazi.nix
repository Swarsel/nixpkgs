{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.yazi;

  settingsFormat = pkgs.formats.toml { };

  files = [
    "yazi"
    "theme"
    "keymap"
    "vfs"
  ];
in
{
  options.programs.yazi = {
    enable = lib.mkEnableOption "yazi terminal file manager";
    package = lib.mkPackageOption pkgs "yazi" { };

    flavors = lib.mkOption {
      default = { };

      description = ''
        Pre-made themes.

        See <https://yazi-rs.github.io/docs/flavors/overview/> for documentation.
      '';

      example = lib.literalExpression ''
        {
          foo = ./foo;
          inherit (pkgs.yaziPlugins) bar;
        }
      '';

      type =
        with lib.types;
        attrsOf (oneOf [
          path
          package
        ]);
    };

    initLua = lib.mkOption {
      default = null;

      description = ''
        The init.lua for Yazi itself.
      '';

      example = lib.literalExpression "./init.lua";
      type = with lib.types; nullOr path;
    };

    plugins = lib.mkOption {
      default = { };

      description = ''
        Lua plugins.

        See <https://yazi-rs.github.io/docs/plugins/overview/> for documentation.
      '';

      example = lib.literalExpression ''
        {
          foo = ./foo;
          inherit (pkgs.yaziPlugins) bar;
        }
      '';

      type =
        with lib.types;
        attrsOf (oneOf [
          path
          package
        ]);
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration included in `$YAZI_CONFIG_HOME`.
      '';

      type =
        with lib.types;
        submodule {
          options = lib.genAttrs files (
            name:
            lib.mkOption {
              inherit (settingsFormat) type;
              default = { };

              description = ''
                Configuration included in `${name}.toml`.

                See <https://yazi-rs.github.io/docs/configuration/${name}/> for documentation.
              '';
            }
          );
        };
    };

  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (cfg.package.override {
        inherit (cfg)
          settings
          initLua
          plugins
          flavors
          ;
      })
    ];
  };

  meta = {
    maintainers = with lib.maintainers; [
      linsui
      ryan4yin
    ];
  };
}
