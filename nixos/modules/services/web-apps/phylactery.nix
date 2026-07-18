{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.phylactery;
in
{
  options.services.phylactery = {
    enable = mkEnableOption "Phylactery server";
    package = mkPackageOption pkgs "phylactery" { };

    host = mkOption {
      default = "localhost";
      description = "Listen host for Phylactery";
      type = types.str;
    };

    library = mkOption {
      description = "Path to CBZ library";
      type = types.path;
    };

    port = mkOption {
      description = "Listen port for Phylactery";
      type = types.port;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.phylactery = {
      environment = {
        PHYLACTERY_ADDRESS = "${cfg.host}:${toString cfg.port}";
        PHYLACTERY_LIBRARY = "${cfg.library}";
      };

      serviceConfig = {
        ConditionPathExists = cfg.library;
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/phylactery";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with maintainers; [ McSinyx ];
}
