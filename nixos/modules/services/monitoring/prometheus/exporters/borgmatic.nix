{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.exporters.borgmatic;
in
{
  extraOpts.configFile = lib.mkOption {
    default = "/etc/borgmatic/config.yaml";

    description = ''
      The path to the borgmatic config file
    '';

    type = lib.types.path;
  };

  port = 9996;

  serviceOpts = {
    serviceConfig = {
      DynamicUser = false;

      ExecStart = ''
        ${pkgs.prometheus-borgmatic-exporter}/bin/borgmatic-exporter run \
          --host ${cfg.listenAddress} \
          --port ${toString cfg.port} \
          --config ${toString cfg.configFile} \
          ${lib.concatMapStringsSep " " (f: lib.escapeShellArg f) cfg.extraFlags}
      '';

      ProtectHome = lib.mkForce false;
      ProtectSystem = false;
    };
  };
}
