{
  config,
  lib,
  pkgs,
  ...
}:

let

  cfg = config.programs.less;

  configText =
    if (cfg.configFile != null) then
      (builtins.readFile cfg.configFile)
    else
      ''
        #command
        ${builtins.concatStringsSep "\n" (
          lib.mapAttrsToList (command: action: "${command} ${action}") cfg.commands
        )}
        ${lib.optionalString cfg.clearDefaultCommands "#stop"}

        #line-edit
        ${builtins.concatStringsSep "\n" (
          lib.mapAttrsToList (command: action: "${command} ${action}") cfg.lineEditingKeys
        )}

        #env
        ${builtins.concatStringsSep "\n" (
          lib.mapAttrsToList (variable: values: "${variable}=${values}") cfg.envVariables
        )}
      '';

  lessKey = pkgs.writeText "lessconfig" configText;

in

{
  options = {

    programs.less = {

      # note that environment.nix sets PAGER=less, and
      # therefore also enables this module
      enable = lib.mkEnableOption "less, a file pager";
      package = lib.mkPackageOption pkgs "less" { };

      clearDefaultCommands = lib.mkOption {
        default = false;

        description = ''
          Clear all default commands.
          You should remember to set the quit key.
          Otherwise you will not be able to leave less without killing it.
        '';

        type = lib.types.bool;
      };

      commands = lib.mkOption {
        default = { };
        description = "Defines new command keys.";

        example = {
          h = "noaction 5\\e(";
          l = "noaction 5\\e)";
        };

        type = lib.types.attrsOf lib.types.str;
      };

      configFile = lib.mkOption {
        default = null;

        description = ''
          Path to lesskey configuration file.

          {option}`configFile` takes precedence over {option}`commands`,
          {option}`clearDefaultCommands`, {option}`lineEditingKeys`, and
          {option}`envVariables`.
        '';

        example = lib.literalExpression ''"''${pkgs.my-configs}/lesskey"'';
        type = lib.types.nullOr lib.types.path;
      };

      envVariables = lib.mkOption {
        default = {
          LESS = "-R";
        };

        description = "Defines environment variables.";

        example = {
          LESS = "--quit-if-one-screen";
        };

        type = lib.types.attrsOf lib.types.str;
      };

      lessclose = lib.mkOption {
        default = null;

        description = ''
          When less closes a file opened in such a way, it will call another program, called the input postprocessor,
          which may perform any desired clean-up action (such as deleting the replacement file created by LESSOPEN).
        '';

        type = lib.types.nullOr lib.types.str;
      };

      lessopen = lib.mkOption {
        default = null;

        description = ''
          Before less opens a file, it first gives your input preprocessor a chance to modify the way the contents of the file are displayed.
        '';

        example = lib.literalExpression ''"|''${pkgs.lesspipe}/bin/lesspipe.sh %s"'';
        type = lib.types.nullOr lib.types.str;
      };

      lineEditingKeys = lib.mkOption {
        default = { };
        description = "Defines new line-editing keys.";

        example = {
          e = "abort";
        };

        type = lib.types.attrsOf lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    environment.variables = {
      LESSKEYIN_SYSTEM = toString lessKey;
    }
    // lib.optionalAttrs (cfg.lessopen != null) {
      LESSOPEN = cfg.lessopen;
    }
    // lib.optionalAttrs (cfg.lessclose != null) {
      LESSCLOSE = cfg.lessclose;
    };

    warnings =
      lib.optional
        (cfg.clearDefaultCommands && (builtins.all (x: x != "quit") (builtins.attrValues cfg.commands)))
        ''
          config.programs.less.clearDefaultCommands clears all default commands of less but there is no alternative binding for exiting.
          Consider adding a binding for 'quit'.
        '';
  };

  meta.maintainers = with lib.maintainers; [ johnazoidberg ];

}
