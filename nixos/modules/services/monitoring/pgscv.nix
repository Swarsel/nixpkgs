{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;

  cfg = config.services.pgscv;

  settingsFormat = pkgs.formats.yaml { };
  configFile = settingsFormat.generate "config.yaml" cfg.settings;
in
{
  options.services.pgscv = {
    enable = mkEnableOption "pgSCV, a PostgreSQL ecosystem metrics collector";
    package = mkPackageOption pkgs "pgscv" { };

    logLevel = mkOption {
      default = "info";
      description = "Log level for pgSCV.";

      type = types.enum [
        "debug"
        "info"
        "warn"
        "error"
      ];
    };

    settings = mkOption {
      default = { };

      description = ''
        Configuration for pgSCV, in YAML format.

        See [configuration reference](https://github.com/cherts/pgscv/wiki/Configuration-settings-reference).
      '';

      type = settingsFormat.type;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.pgscv = {
      after = [ "network-online.target" ];
      description = "pgSCV - PostgreSQL ecosystem metrics collector";
      path = [ pkgs.glibc ]; # shells out to getconf
      requires = [ "network-online.target" ];

      serviceConfig = {
        ExecStart = utils.escapeSystemdExecArgs [
          (lib.getExe cfg.package)
          "--log-level=${cfg.logLevel}"
          "--config-file=${configFile}"
        ];

        Group = "postgres";
        KillMode = "control-group";
        OOMScoreAdjust = 1000;
        Restart = "on-failure";
        RestartSec = 10;
        TimeoutSec = 5;
        User = "postgres";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
