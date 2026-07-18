{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.heartbeat;

  heartbeatYml = pkgs.writeText "heartbeat.yml" ''
    name: ${cfg.name}
    tags: ${builtins.toJSON cfg.tags}

    ${cfg.extraConfig}
  '';

in
{
  options = {

    services.heartbeat = {

      enable = lib.mkEnableOption "heartbeat, uptime monitoring";

      package = lib.mkPackageOption pkgs "heartbeat" {
        example = "heartbeat7";
      };

      extraConfig = lib.mkOption {
        default = ''
          heartbeat.monitors:
          - type: http
            urls: ["http://localhost:9200"]
            schedule: '@every 10s'
        '';

        description = "Any other configuration options you want to add";
        type = lib.types.lines;
      };

      name = lib.mkOption {
        default = "heartbeat";
        description = "Name of the beat";
        type = lib.types.str;
      };

      stateDir = lib.mkOption {
        default = "/var/lib/heartbeat";
        description = "The state directory. heartbeat's own logs and other data are stored here.";
        type = lib.types.str;
      };

      tags = lib.mkOption {
        default = [ ];
        description = "Tags to place on the shipped log messages";
        type = lib.types.listOf lib.types.str;
      };

    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.heartbeat = {
      description = "heartbeat log shipper";

      serviceConfig = {
        AmbientCapabilities = "cap_net_raw";
        ExecStart = "${cfg.package}/bin/heartbeat -c \"${heartbeatYml}\" -path.data \"${cfg.stateDir}/data\" -path.logs \"${cfg.stateDir}/logs\"";
        ExecStartPre = "${lib.getExe' pkgs.coreutils "mkdir"} -p '${cfg.stateDir}'/data '${cfg.stateDir}'/logs";
        User = "nobody";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.stateDir}' - nobody nogroup - -"
    ];
  };
}
