{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  globalCfg = config.services.scion;
  cfg = config.services.scion.scion-router;
  toml = pkgs.formats.toml { };
  defaultConfig = {
    general = {
      config_dir = "/etc/scion";
      id = "br";
    };
  };
  configFile = toml.generate "scion-router.toml" (recursiveUpdate defaultConfig cfg.settings);
in
{
  options.services.scion.scion-router = {
    enable = mkEnableOption "the scion-router service";

    settings = mkOption {
      default = { };

      description = ''
        scion-router configuration. Refer to
        <https://docs.scion.org/en/latest/manuals/common.html>
        for details on supported values.
      '';

      example = literalExpression ''
        {
          general.id = "br";
        }
      '';

      type = toml.type;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.scion-router = {
      after = [ "network-online.target" ];
      description = "SCION Router";

      serviceConfig = {
        ${if globalCfg.stateless then "RuntimeDirectory" else "StateDirectory"} = "scion-router";
        DynamicUser = true;
        ExecStart = "${globalCfg.package}/bin/scion-router --config ${configFile}";
        Restart = "on-failure";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };
}
