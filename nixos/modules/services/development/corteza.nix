{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.corteza;
in
{
  options.services.corteza = {
    enable = lib.mkEnableOption "Corteza, a low-code platform";
    package = lib.mkPackageOption pkgs "corteza" { };

    address = lib.mkOption {
      default = "0.0.0.0";

      description = ''
        IP for the HTTP server.
      '';

      type = lib.types.str;
    };

    group = lib.mkOption {
      default = "corteza";
      description = "The group to run Corteza under.";
      type = lib.types.str;
    };

    openFirewall = lib.mkOption {
      default = false;
      description = "Whether to open ports in the firewall.";
      example = true;
      type = lib.types.bool;
    };

    port = lib.mkOption {
      default = 80;

      description = ''
        Port for the HTTP server.
      '';

      type = lib.types.port;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration for Corteza, will be passed as environment variables.
        See <https://docs.cortezaproject.org/corteza-docs/2024.9/devops-guide/references/configuration/server.html>.
      '';

      type = lib.types.submodule {
        options = {
          HTTP_WEBAPP_ENABLED = lib.mkEnableOption "webapps" // {
            apply = toString;
            default = true;
          };
        };

        freeformType = lib.types.attrsOf lib.types.str;
      };
    };

    user = lib.mkOption {
      default = "corteza";
      description = "The user to run Corteza under.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.settings ? HTTP_ADDR;
        message = "Use `services.corteza.address` and `services.corteza.port` instead.";
      }
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.corteza = {
      after = [ "network-online.target" ];
      description = "Corteza";
      documentation = [ "https://docs.cortezaproject.org/" ];

      environment = {
        HTTP_ADDR = "${cfg.address}:${toString cfg.port}";
        HTTP_WEBAPP_BASE_DIR = "./webapp";
      }
      // cfg.settings;

      path = [ pkgs.dart-sass ];

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} serve-api";
        Group = cfg.group;
        User = cfg.user;
        WorkingDirectory = cfg.package;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    users = {
      groups.${cfg.group} = { };

      users.${cfg.user} = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    };

    warnings = lib.optional (!cfg.settings ? DB_DSN) ''
      A database connection string is not set.
      Corteza will create a temporary SQLite database in memory, but it will not persist data.
      For production use, set `services.corteza.settings.DB_DSN`.
    '';
  };

  meta.maintainers = with lib.maintainers; [
    prince213
  ];
}
