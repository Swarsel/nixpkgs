{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.exporters.frr;
  inherit (lib)
    mkOption
    types
    concatStringsSep
    concatMapStringsSep
    ;
in
{
  extraOpts = {
    disabledCollectors = mkOption {
      default = [ ];

      description = ''
        Collectors to disable which are enabled by default.
      '';

      example = [ "bfd" ];
      type = types.listOf types.str;
    };

    enabledCollectors = mkOption {
      default = [ ];

      description = ''
        Collectors to enable. The collectors listed here are enabled in addition to the default ones.
      '';

      example = [ "vrrp" ];
      type = types.listOf types.str;
    };

    group = mkOption {
      default = "frrvty";

      description = ''
        Group under which the frr exporter shall be run.
        The exporter talks to frr using a unix socket, which is owned by frrvty group.
      '';

      type = types.str;
    };

    user = mkOption {
      default = "frr";

      description = ''
        User name under which the frr exporter shall be run.
        The exporter talks to frr using a unix socket, which is owned by frr.
      '';

      type = types.str;
    };
  };

  port = 9342;

  serviceOpts = {
    serviceConfig = {
      DynamicUser = false;

      ExecStart = ''
        ${lib.getExe pkgs.prometheus-frr-exporter} \
          ${concatMapStringsSep " " (x: "--collector." + x) cfg.enabledCollectors} \
          ${concatMapStringsSep " " (x: "--no-collector." + x) cfg.disabledCollectors} \
          --web.listen-address ${cfg.listenAddress}:${toString cfg.port} ${concatStringsSep " " cfg.extraFlags}
      '';

      RestrictAddressFamilies = [ "AF_UNIX" ];
      RuntimeDirectory = "prometheus-frr-exporter";
    };
  };
}
