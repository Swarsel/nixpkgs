{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.vscode;
  jsonFormat = pkgs.formats.json { };
in
{
  options.programs.vscode = {
    enable = lib.mkEnableOption "VSCode editor";

    package = lib.mkPackageOption pkgs "vscode" {
      extraDescription = "The final package will be customized with extensions from {option}`programs.vscode.extensions`";
    };

    defaultEditor = lib.mkEnableOption "" // {
      description = ''
        When enabled, configures VSCode to be the default editor
        using the EDITOR environment variable.
      '';
    };

    enterprisePolicies = lib.mkOption {
      default = { };

      description = ''
        System-wide policies for VSCode in `/etc/vscode/policy.json`.
        See <https://code.visualstudio.com/docs/setup/enterprise#_centrally-manage-vs-code-settings> for more information.
      '';

      example = lib.literalExpression ''
        {
          "UpdateMode" = "none";
          "TelemetryLevel" = "off";
        }
      '';

      type = jsonFormat.type;
    };

    extensions = lib.mkOption {
      default = [ ];
      description = "List of extensions to install.";

      example = lib.literalExpression ''
        with pkgs.vscode-extensions; [
          bbenoist.nix
          golang.go
          twxs.cmake
        ]
      '';

      type = lib.types.listOf lib.types.package;
    };

    finalPackage = lib.mkOption {
      description = "Resulting customized VSCode package.";
      readOnly = true;
      type = lib.types.package;
      visible = false;
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      etc."vscode/policy.json" = lib.mkIf (cfg.enterprisePolicies != { }) {
        source = jsonFormat.generate "vscode-policy.json" cfg.enterprisePolicies;
      };

      sessionVariables.EDITOR = lib.mkIf cfg.defaultEditor (
        lib.mkOverride 900 cfg.finalPackage.meta.mainProgram
      );

      systemPackages = [
        cfg.finalPackage
      ];
    };

    programs.vscode.finalPackage = pkgs.vscode-with-extensions.override {
      vscode = cfg.package;
      vscodeExtensions = cfg.extensions;
    };
  };

  meta.maintainers = with lib.maintainers; [ ethancedwards8 ];
}
