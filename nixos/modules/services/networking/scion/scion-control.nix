{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  globalCfg = config.services.scion;
  cfg = config.services.scion.scion-control;
  toml = pkgs.formats.toml { };
  connectionDir = if globalCfg.stateless then "/run" else "/var/lib";
  defaultConfig = {
    beacon_db = {
      connection = "${connectionDir}/scion-control/control.beacon.db";
    };

    general = {
      config_dir = "/etc/scion";
      id = "cs";
    };

    log.console = {
      level = "info";
    };

    path_db = {
      connection = "${connectionDir}/scion-control/control.path.db";
    };

    trust_db = {
      connection = "${connectionDir}/scion-control/control.trust.db";
    };
  };
  configFile = toml.generate "scion-control.toml" (recursiveUpdate defaultConfig cfg.settings);
in
{
  options.services.scion.scion-control = {
    enable = mkEnableOption "the scion-control service";

    settings = mkOption {
      default = { };

      description = ''
        scion-control configuration. Refer to
        <https://docs.scion.org/en/latest/manuals/common.html>
        for details on supported values.
      '';

      example = literalExpression ''
        {
          path_db = {
            connection = "/run/scion-control/control.path.db";
          };
          log.console = {
            level = "info";
          };
        }
      '';

      type = toml.type;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.scion-control = {
      after = [
        "network-online.target"
        "scion-dispatcher.service"
      ];

      description = "SCION Control Service";

      serviceConfig = {
        ${if globalCfg.stateless then "RuntimeDirectory" else "StateDirectory"} = "scion-control";
        BindPaths = [ "/dev/shm:/run/shm" ];
        DynamicUser = true;
        ExecStart = "${globalCfg.package}/bin/scion-control --config ${configFile}";
        Group = if (config.services.scion.scion-dispatcher.enable == true) then "scion" else null;
        Restart = "on-failure";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];

      wants = [
        "network-online.target"
        "scion-dispatcher.service"
      ];
    };
  };
}
