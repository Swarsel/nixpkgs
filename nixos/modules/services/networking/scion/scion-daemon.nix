{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  globalCfg = config.services.scion;
  cfg = config.services.scion.scion-daemon;
  toml = pkgs.formats.toml { };
  connectionDir = if globalCfg.stateless then "/run" else "/var/lib";
  defaultConfig = {
    general = {
      config_dir = "/etc/scion";
      id = "sd";
    };

    log.console = {
      level = "info";
    };

    path_db = {
      connection = "${connectionDir}/scion-daemon/sd.path.db";
    };

    trust_db = {
      connection = "${connectionDir}/scion-daemon/sd.trust.db";
    };
  };
  configFile = toml.generate "scion-daemon.toml" (recursiveUpdate defaultConfig cfg.settings);
in
{
  options.services.scion.scion-daemon = {
    enable = mkEnableOption "the scion-daemon service";

    settings = mkOption {
      default = { };

      description = ''
        scion-daemon configuration. Refer to
        <https://docs.scion.org/en/latest/manuals/common.html>
        for details on supported values.
      '';

      example = literalExpression ''
        {
          path_db = {
            connection = "/run/scion-daemon/sd.path.db";
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
    systemd.services.scion-daemon = {
      after = [
        "network-online.target"
        "scion-dispatcher.service"
      ];

      description = "SCION Daemon";

      serviceConfig = {
        ${if globalCfg.stateless then "RuntimeDirectory" else "StateDirectory"} = "scion-daemon";
        DynamicUser = true;
        ExecStart = "${globalCfg.package}/bin/scion-daemon --config ${configFile}";
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
