{ lib, config, ... }:
let
  /*
    transform all plugins into an attrset
    { optional = bool; plugin = package; }
  */
  normalizePlugins =
    plugins:
    let
      defaultPlugin = {
        config = null;
        optional = false;
        plugin = null;
        type = "viml";
      };
    in
    map (x: defaultPlugin // (if x ? plugin then x else { plugin = x; })) plugins;

  pluginWithConfigType =
    with lib;
    types.submodule {
      options = {
        config = mkOption {
          default = null;
          description = "viml configuration associated with this plugin.";
          example = "set title";
          type = types.nullOr types.lines;
        };

        optional = mkEnableOption "optional" // {
          description = "Don't load automatically on startup (load with :packadd)";
        };

        plugin = mkOption {
          description = "vim plugin";
          example = lib.literalExpression "vimPlugins.vim-fugitive";
          type = types.package;
        };

        type = lib.mkOption {
          default = "viml";
          description = "Language used in config. Configurations are aggregated per-language.";

          type = lib.types.either (lib.types.enum [
            "lua"
            "viml"
          ]) lib.types.str;
        };
      };
    };

in
{
  config =
    let
      pluginsNormalized = config.plugins;

      userPluginConfigs =
        let
          grouped = lib.groupBy (x: x.type) pluginsNormalized;
          configsOnly = lib.foldl (acc: p: if p.config != null then acc ++ [ p.config ] else acc) [ ];
        in
        lib.mapAttrs (_name: vals: lib.concatStringsSep "\n" (configsOnly vals)) grouped;
    in
    {
      inherit userPluginConfigs;

      luaDependencies =
        let
          op = acc: p: acc ++ (p.plugin.requiredLuaModules or [ ]);
        in
        lib.foldl' op [ ] pluginsNormalized;

      pluginAdvisedLua =
        let
          op =
            acc: normalizedPlugin:
            acc
            ++ lib.optional (
              normalizedPlugin.plugin.passthru ? initLua
            ) normalizedPlugin.plugin.passthru.initLua;
        in
        lib.foldl' op [ ] pluginsNormalized;

      pluginPython3Packages = map (plugin: plugin.python3Dependencies or (_: [ ])) pluginsNormalized;

      runtimeDeps =
        let
          op = acc: normalizedPlugin: acc ++ normalizedPlugin.plugin.runtimeDeps or [ ];
        in
        lib.foldl' op [ ] pluginsNormalized;

      userPluginViml = userPluginConfigs.viml or null;
    };

  options = {
    luaDependencies = lib.mkOption {
      description = ''
        Lua dependencies required by the plugins.
      '';

      example = lib.literalExpression "[ (lp: [ lp.mpack ]) ]";
      readOnly = true;
      type = lib.types.listOf (lib.types.nullOr lib.types.package);
    };

    pluginAdvisedLua = lib.mkOption {
      description = ''
        Recommended configuration set in vim plugins via ".passthru.initLua".
      '';

      readOnly = true;
      type = lib.types.listOf lib.types.lines;
    };

    pluginPython3Packages = lib.mkOption {
      description = ''
        Packages required by the plugins to work with the python3 provider.
      '';

      example = lib.literalExpression "[ (ps: [ ps.python-language-server ]) ]";
      readOnly = true;
      type = lib.types.listOf (lib.types.functionTo (lib.types.listOf lib.types.package));
    };

    plugins = lib.mkOption {
      apply = normalizePlugins;
      default = [ ];

      description = ''
        List of vim plugins to install optionally associated with
        configuration to be placed in init.vim.
      '';

      example = lib.literalExpression ''
        with pkgs.vimPlugins; [
          yankring
          vim-nix
          { plugin = vim-startify;
            config = "let g:startify_change_to_vcs_root = 0";
          }
        ]
      '';

      type = with lib.types; listOf (either package pluginWithConfigType);
    };

    runtimeDeps = lib.mkOption {
      description = ''
        List of derivations required at runtime
      '';

      readOnly = true;
      type = with lib.types; listOf package;
    };

    userPluginConfigs = lib.mkOption {
      description = ''
        The user configurations (viml, lua, ...) set by the user.
      '';

      readOnly = true;
      type = lib.types.attrsOf lib.types.lines;
    };

    userPluginViml = lib.mkOption {
      description = ''
        The viml config set by the user.
      '';

      readOnly = true;
      type = lib.types.nullOr lib.types.lines;
    };
  };
}
