{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.prometheus.exporters.mysqld;
  inherit (lib)
    types
    mkOption
    mkIf
    mkForce
    concatStringsSep
    optionalString
    escapeShellArgs
    ;
in
{
  extraOpts = {
    configFile = mkOption {
      description = ''
        Path to the services config file.

        See <https://github.com/prometheus/mysqld_exporter#running> for more information about
        the available options.

        ::: {.warn}
        Please do not store this file in the nix store if you choose to include any credentials here,
        as it would be world-readable.
        :::
      '';

      example = "/var/lib/prometheus-mysqld-exporter.cnf";
      type = types.path;
    };

    runAsLocalSuperUser = mkOption {
      default = false;

      description = ''
        Whether to run the exporter as {option}`services.mysql.user`.
      '';

      type = types.bool;
    };

    telemetryPath = mkOption {
      default = "/metrics";

      description = ''
        Path under which to expose metrics.
      '';

      type = types.str;
    };
  };

  port = 9104;

  serviceOpts = {
    serviceConfig = {
      DynamicUser = !cfg.runAsLocalSuperUser;

      ExecStart = concatStringsSep " " [
        "${pkgs.prometheus-mysqld-exporter}/bin/mysqld_exporter"
        "--web.listen-address=${cfg.listenAddress}:${toString cfg.port}"
        "--web.telemetry-path=${cfg.telemetryPath}"
        (optionalString (cfg.configFile != null) "--config.my-cnf=\${CREDENTIALS_DIRECTORY}/config")
        (escapeShellArgs cfg.extraFlags)
      ];

      LoadCredential = mkIf (cfg.configFile != null) (mkForce ("config:" + cfg.configFile));

      RestrictAddressFamilies = [
        # The exporter can be configured to talk to a local mysql server via a unix socket.
        "AF_UNIX"
      ];

      User = mkIf cfg.runAsLocalSuperUser (mkForce config.services.mysql.user);
    };
  };
}
