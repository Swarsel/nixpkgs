{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.go-csp-collector;

  inherit (lib)
    boolToString
    concatStringsSep
    getExe
    isBool
    literalExpression
    maintainers
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;

  settingsToArgs =
    settings:
    concatStringsSep " " (
      mapAttrsToList (
        name: value:
        let
          flag = "-${name}";
        in
        if isBool value then "${flag}=${boolToString value}" else "${flag} ${toString value}"
      ) settings
    );
in
{
  options.services.go-csp-collector = {
    enable = mkEnableOption "go-csp-collector, a content security policy violation collector";
    package = mkPackageOption pkgs "go-csp-collector" { };

    settings = mkOption {
      default = { };

      description = ''
        Settings for go-csp-collector. See
        <https://github.com/jacobbednarz/go-csp-collector> for supported options.
      '';

      example = literalExpression ''
        {
          debug = true;
          health-check-path = "/health";
        }
      '';

      type = types.submodule {
        options = {
          output-format = mkOption {
            default = "text";
            description = "Define how the violation reports are formatted for output.";
            example = "text";

            type = types.enum [
              "text"
              "json"
            ];
          };

          port = mkOption {
            default = 8080;
            description = "The port to listen on.";
            example = 8080;
            type = types.port;
          };
        };

        freeformType =
          with types;
          attrsOf (oneOf [
            bool
            path
            str
          ]);
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.packages = [ cfg.package ];

    systemd.services.go-csp-collector = {
      after = [ "network.target" ];
      description = "CSP violation collector";

      serviceConfig = {
        ExecStart = [
          ""
          "${getExe cfg.package} ${settingsToArgs cfg.settings}"
        ];

        ReadOnlyPaths = cfg.settings.filter-file or "";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with maintainers; [ stepbrobd ];
}
