{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.exporters.mailman3;
in
{
  extraOpts = {
    logLevel = lib.mkOption {
      default = "info";

      description = ''
        Detail level to log.
      '';

      type = lib.types.enum [
        "debug"
        "info"
        "warning"
        "error"
        "critical"
      ];
    };

    mailman = {
      addr = lib.mkOption {
        default = "http://127.0.0.1:8001";

        description = ''
          Mailman3 Core REST API address.
        '';

        type = lib.types.str;
      };

      passFile = lib.mkOption {
        default = config.services.mailman.restApiPassFile;
        defaultText = lib.literalExpression "config.services.mailman.restApiPassFile";

        description = ''
          Mailman3 Core REST API password.
        '';

        type = lib.types.str;
      };

      user = lib.mkOption {
        default = "restadmin";

        description = ''
          Mailman3 Core REST API username.
        '';

        type = lib.types.str;
      };
    };
  };

  port = 9934;

  serviceOpts = {
    serviceConfig = {
      ExecStart =
        let
          addr = "${
            if (lib.hasInfix ":" cfg.listenAddress) then "[${cfg.listenAddress}]" else cfg.listenAddress
          }:${toString cfg.port}";
        in
        ''
          ${lib.getExe pkgs.prometheus-mailman3-exporter} \
            --log-level ${cfg.logLevel} \
            --web.listen ${addr} \
            --mailman.address ${cfg.mailman.addr} \
            --mailman.user ${cfg.mailman.user} \
            --mailman.password-file %d/password \
            ${lib.concatStringsSep " \\\n  " cfg.extraFlags}
        '';

      LoadCredential = [
        "password:${cfg.mailman.passFile}"
      ];
    };
  };
}
