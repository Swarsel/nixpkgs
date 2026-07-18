{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.spoolman;
in
{

  options.services.spoolman = {

    enable = lib.mkEnableOption "Spoolman, a filament spool inventory management system.";

    environment = lib.mkOption {
      default = { };

      description = ''
        Environment variables to be passed to the spoolman service.
        Refer to https://github.com/Donkie/Spoolman/blob/master/.env.example for details on supported variables.
      '';

      example = {
        SPOOLMAN_AUTOMATIC_BACKUP = "TRUE";
        SPOOLMAN_BASE_PATH = "/spoolman";
        SPOOLMAN_CORS_ORIGIN = "source1.domain.com:p1, source2.domain.com:p2";
        SPOOLMAN_DB_TYPE = "sqlite";
        SPOOLMAN_LOGGING_LEVEL = "DEBUG";
        SPOOLMAN_METRICS_ENABLED = "TRUE";
      };

      type = lib.types.attrs;
    };

    listen = lib.mkOption {
      default = "127.0.0.1";
      description = "The IP address to bind the spoolman server to.";
      example = "0.0.0.0";
      type = lib.types.str;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Open the appropriate ports in the firewall for spoolman.
      '';

      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 7912;

      description = ''
        TCP port where spoolman web-gui listens.
      '';

      type = lib.types.port;
    };

  };

  config = lib.mkIf cfg.enable {

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = lib.optional (cfg.listen != "127.0.0.1") cfg.port;
    };

    systemd.services.spoolman = {
      description = "A self-hosted filament spool inventory management system";

      environment = {
        SPOOLMAN_DIR_DATA = "/var/lib/spoolman";
      }
      // cfg.environment;

      serviceConfig = lib.mkMerge [
        {
          DynamicUser = true;
          ExecStart = "${pkgs.spoolman}/bin/spoolman --host ${cfg.listen} --port ${toString cfg.port}";
          StateDirectory = "spoolman";
        }
      ];

      wantedBy = [ "multi-user.target" ];
    };

  };

  meta = {
    maintainers = with lib.maintainers; [ MayNiklas ];
  };
}
