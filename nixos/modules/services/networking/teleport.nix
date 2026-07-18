{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.teleport;
  settingsYaml = pkgs.formats.yaml { };
in
{
  options = {
    services.teleport = with lib.types; {
      enable = mkEnableOption "the Teleport service";

      package = mkPackageOption pkgs "teleport" {
        example = "teleport_11";
      };

      diag = {
        enable = mkEnableOption ''
          endpoints for monitoring purposes.

          See <https://goteleport.com/docs/setup/admin/troubleshooting/#troubleshooting/>
        '';

        addr = mkOption {
          default = "127.0.0.1";
          description = "Metrics and diagnostics address.";
          type = str;
        };

        port = mkOption {
          default = 3000;
          description = "Metrics and diagnostics port.";
          type = port;
        };
      };

      insecure.enable = mkEnableOption ''
        starting teleport in insecure mode.

        This is dangerous!
        Sensitive information will be logged to console and certificates will not be verified.
        Proceed with caution!

        Teleport starts with disabled certificate validation on Proxy Service, validation still occurs on Auth Service
      '';

      settings = mkOption {
        default = { };

        description = ''
          Contents of the {file}`teleport.yaml` config file.
          The `--config` arguments will only be passed if this set is not empty.

          See <https://goteleport.com/docs/setup/reference/config/>.
        '';

        example = literalExpression ''
          {
            teleport = {
              nodename = "client";
              advertise_ip = "192.168.1.2";
              auth_token = "60bdc117-8ff4-478d-95e4-9914597847eb";
              auth_servers = [ "192.168.1.1:3025" ];
              log.severity = "DEBUG";
            };
            ssh_service = {
              enabled = true;
              labels = {
                role = "client";
              };
            };
            proxy_service.enabled = false;
            auth_service.enabled = false;
          }
        '';

        type = settingsYaml.type;
      };
    };
  };

  config = mkIf config.services.teleport.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.teleport = {
      after = [ "network.target" ];

      path = with pkgs; [
        getent
        shadow
        sudo
      ];

      serviceConfig = {
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";

        ExecStart = ''
          ${cfg.package}/bin/teleport start \
            ${optionalString cfg.insecure.enable "--insecure"} \
            ${optionalString cfg.diag.enable "--diag-addr=${cfg.diag.addr}:${toString cfg.diag.port}"} \
            ${optionalString (
              cfg.settings != { }
            ) "--config=${settingsYaml.generate "teleport.yaml" cfg.settings}"}
        '';

        LimitNOFILE = 65536;
        Restart = "always";
        RestartSec = "5s";
        RuntimeDirectory = "teleport";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
