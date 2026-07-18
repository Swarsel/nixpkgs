{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.goss;

  settingsFormat = pkgs.formats.yaml { };
  configFile = settingsFormat.generate "goss.yaml" cfg.settings;

in
{
  options = {
    services.goss = {
      enable = lib.mkEnableOption "Goss daemon";
      package = lib.mkPackageOption pkgs "goss" { };

      environment = lib.mkOption {
        default = { };

        description = ''
          Environment variables to set for the goss service.

          See <https://github.com/goss-org/goss/blob/master/docs/manual.md>
        '';

        example = {
          GOSS_FMT = "json";
          GOSS_LISTEN = ":8080";
          GOSS_LOGLEVEL = "FATAL";
        };

        type = lib.types.attrsOf lib.types.str;
      };

      settings = lib.mkOption {
        default = { };

        description = ''
          The global options in `config` file in yaml format.

          Refer to <https://github.com/goss-org/goss/blob/master/docs/goss-json-schema.yaml> for schema.
        '';

        example = {
          addr."tcp://localhost:8080" = {
            local-address = "127.0.0.1";
            reachable = true;
          };

          service.goss = {
            enabled = true;
            running = true;
          };
        };

        type = lib.types.submodule { freeformType = settingsFormat.type; };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.goss = {
      after = [ "network-online.target" ];
      description = "Goss - Quick and Easy server validation";

      environment = {
        GOSS_FILE = configFile;
      }
      // cfg.environment;

      reloadTriggers = [ configFile ];

      serviceConfig = {
        DynamicUser = true;
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${cfg.package}/bin/goss serve";
        Group = "goss";
        Restart = "on-failure";
        RestartSec = 5;
        User = "goss";
      };

      unitConfig.Documentation = "https://github.com/goss-org/goss/blob/master/docs/manual.md";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta = {
    doc = ./goss.md;
    maintainers = [ lib.maintainers.anthonyroussel ];
  };
}
