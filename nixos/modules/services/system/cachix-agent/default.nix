{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cachix-agent;
in
{
  options.services.cachix-agent = {
    enable = lib.mkEnableOption "Cachix Deploy Agent: <https://docs.cachix.org/deploy/>";
    package = lib.mkPackageOption pkgs "cachix" { };

    credentialsFile = lib.mkOption {
      default = "/etc/cachix-agent.token";

      description = ''
        Required file that needs to contain CACHIX_AGENT_TOKEN=...
      '';

      type = lib.types.path;
    };

    host = lib.mkOption {
      default = null;
      description = "Cachix uri to use.";
      type = lib.types.nullOr lib.types.str;
    };

    name = lib.mkOption {
      default = config.networking.hostName;
      defaultText = "config.networking.hostName";
      description = "Agent name, usually same as the hostname";
      type = lib.types.str;
    };

    profile = lib.mkOption {
      default = null;
      description = "Profile name, defaults to 'system' (NixOS).";
      type = lib.types.nullOr lib.types.str;
    };

    verbose = lib.mkOption {
      default = false;
      description = "Enable verbose output";
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.cachix-agent = {
      after = [ "network-online.target" ];
      description = "Cachix Deploy Agent";
      # Cachix requires $USER to be set
      environment.USER = "root";
      path = [ config.nix.package ];

      serviceConfig = {
        EnvironmentFile = cfg.credentialsFile;

        ExecStart = ''
          ${cfg.package}/bin/cachix ${lib.optionalString cfg.verbose "--verbose"} ${
            lib.optionalString (cfg.host != null) "--host ${cfg.host}"
          } \
            deploy agent ${cfg.name} ${lib.optionalString (cfg.profile != null) cfg.profile}
        '';

        # we don't want to kill children processes as those are deployments
        KillMode = "process";
        Restart = "always";
        RestartSec = 5;
      };

      # don't stop the service if the unit disappears
      unitConfig.X-StopOnRemoval = false;
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    domenkozar
    sandydoo
  ];
}
