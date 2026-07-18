{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  globalCfg = config.services.scion;
  cfg = config.services.scion.scion-ip-gateway;
  toml = pkgs.formats.toml { };
  json = pkgs.formats.json { };
  connectionDir = if globalCfg.stateless then "/run" else "/var/lib";
  defaultConfig = {
    gateway = {
      traffic_policy_file = "${trafficConfigFile}";
    };

    tunnel = { };
  };
  defaultTrafficConfig = {
    ASes = { };
    ConfigVersion = 9001;
  };
  configFile = toml.generate "scion-ip-gateway.toml" (recursiveUpdate defaultConfig cfg.config);
  trafficConfigFile = json.generate "scion-ip-gateway-traffic.json" (
    recursiveUpdate defaultTrafficConfig cfg.trafficConfig
  );
in
{
  options.services.scion.scion-ip-gateway = {
    config = mkOption {
      default = { };

      description = ''
        scion-ip-gateway daemon configuration
      '';

      example = literalExpression ''
        {
          tunnel = {
            src_ipv4 = "172.16.100.1";
          };
        }
      '';

      type = toml.type;
    };

    enable = mkEnableOption "the scion-ip-gateway service";

    trafficConfig = mkOption {
      default = { };

      description = ''
        scion-ip-gateway traffic configuration
      '';

      example = literalExpression ''
        {
          ASes = {
            "2-ffaa:0:b" = {
              Nets = [
                  "172.16.1.0/24"
              ];
            };
          };
          ConfigVersion = 9001;
        }
      '';

      type = json.type;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.scion-ip-gateway = {
      after = [
        "network-online.target"
        "scion-dispatcher.service"
      ];

      description = "SCION IP Gateway Service";

      serviceConfig = {
        AmbientCapabilities = [ "CAP_NET_ADMIN" ];
        DynamicUser = true;
        ExecStart = "${globalCfg.package}/bin/scion-ip-gateway --config ${configFile}";
        Group = if (config.services.scion.scion-dispatcher.enable == true) then "scion" else null;
        KillMode = "control-group";
        RemainAfterExit = false;
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
