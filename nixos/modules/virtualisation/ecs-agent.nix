{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.ecs-agent;
in
{
  options.services.ecs-agent = {
    enable = mkEnableOption "Amazon ECS agent";
    package = mkPackageOption pkgs "ecs-agent" { };

    extra-environment = mkOption {
      default = { };
      description = "The environment the ECS agent should run with. See the ECS agent documentation for keys that work here.";
      type = types.attrsOf types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ecs-agent = {
      inherit (cfg.package.meta) description;
      after = [ "network.target" ];
      environment = cfg.extra-environment;

      script = ''
        if [ ! -z "$ECS_DATADIR" ]; then
          mkdir -p "$ECS_DATADIR"
        fi
        ${cfg.package}/bin/agent
      '';

      wantedBy = [ "multi-user.target" ];
    };

    # This service doesn't run if docker isn't running, and unlike potentially remote services like e.g., postgresql, docker has
    # to be running locally so `docker.enable` will always be set if the ECS agent is enabled.
    virtualisation.docker.enable = true;
  };
}
