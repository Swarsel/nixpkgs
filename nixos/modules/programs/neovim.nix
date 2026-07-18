{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.neovim;
in
{
  options.programs.neovim = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Whether to enable Neovim.

        When enabled through this option, Neovim is wrapped to use a
        configuration managed by this module. The configuration file in the
        user's home directory at {file}`~/.config/nvim/init.vim` is no longer
        loaded by default.
      '';

      example = true;
      type = lib.types.bool;
    };

    package = lib.mkPackageOption pkgs "neovim-unwrapped" { };

    configure = lib.mkOption {
      default = { };

      description = ''
        Generate your init file from your list of plugins and custom commands.
        Neovim will then be wrapped to load {command}`nvim -u /nix/store/«hash»-vimrc`
      '';

      example = lib.literalExpression ''
        {
          customRC = '''
            " here your custom VimScript configuration goes!
          ''';
          customLuaRC = '''
            -- here your custom Lua configuration goes!
          ''';
          packages.myVimPackage = with pkgs.vimPlugins; {
            # loaded on launch
            start = [ fugitive ];
            # manually loadable by calling `:packadd $plugin-name`
            opt = [ ];
          };
        }
      '';

      type = lib.types.attrs;
    };

    defaultEditor = lib.mkOption {
      default = false;

      description = ''
        When enabled, installs neovim and configures neovim to be the default editor
        using the EDITOR environment variable.
      '';

      type = lib.types.bool;
    };

    finalPackage = lib.mkOption {
      description = "Resulting customized neovim package.";
      readOnly = true;
      type = lib.types.package;
      visible = false;
    };

    runtime = lib.mkOption {
      default = { };

      description = ''
        Set of files that have to be linked in {file}`runtime`.
      '';

      example = lib.literalExpression ''
        { "ftplugin/c.vim".text = "setlocal omnifunc=v:lua.vim.lsp.omnifunc"; }
      '';

      type =
        with lib.types;
        attrsOf (
          submodule (
            { config, name, ... }:
            {
              options = {

                enable = lib.mkOption {
                  default = true;

                  description = ''
                    Whether this runtime directory should be generated.  This
                    option allows specific runtime files to be disabled.
                  '';

                  type = lib.types.bool;
                };

                source = lib.mkOption {
                  default = null;
                  description = "Path of the source file.";
                  type = lib.types.nullOr lib.types.path;
                };

                target = lib.mkOption {
                  description = ''
                    Name of symlink.  Defaults to the attribute
                    name.
                  '';

                  type = lib.types.str;
                };

                text = lib.mkOption {
                  default = null;
                  description = "Text of the file.";
                  type = lib.types.nullOr lib.types.lines;
                };

              };

              config.target = lib.mkDefault name;
            }
          )
        );

    };

    viAlias = lib.mkOption {
      default = false;

      description = ''
        Symlink {command}`vi` to {command}`nvim` binary.
      '';

      type = lib.types.bool;
    };

    vimAlias = lib.mkOption {
      default = false;

      description = ''
        Symlink {command}`vim` to {command}`nvim` binary.
      '';

      type = lib.types.bool;
    };

    withNodeJs = lib.mkOption {
      default = false;
      description = "Enable Node provider.";
      type = lib.types.bool;
    };

    withPython3 = lib.mkOption {
      default = false;
      description = "Enable Python 3 provider.";
      type = lib.types.bool;
    };

    withRuby = lib.mkOption {
      default = false;
      description = "Enable Ruby provider.";
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc = builtins.listToAttrs (
      builtins.attrValues (
        builtins.mapAttrs (name: value: {
          name = "xdg/nvim/${name}";

          value = removeAttrs (
            value
            // {
              target = "xdg/nvim/${value.target}";
            }
          ) (lib.optionals (isNull value.source) [ "source" ]);
        }) cfg.runtime
      )
    );

    # On most NixOS configurations /share is already included, so it includes
    # this directory as well. But  This makes sure that /share/nvim/site paths
    # from other packages will be used by neovim.
    environment.pathsToLink = [ "/share/nvim" ];
    environment.sessionVariables.EDITOR = lib.mkIf cfg.defaultEditor (lib.mkOverride 900 "nvim");

    environment.systemPackages = [
      cfg.finalPackage
    ];

    programs.neovim.finalPackage = pkgs.wrapNeovim cfg.package {
      inherit (cfg)
        viAlias
        vimAlias
        withPython3
        withNodeJs
        withRuby
        configure
        ;
    };
  };
}
