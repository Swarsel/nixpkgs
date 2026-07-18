{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.services.prometheus.exporters.node;
  inherit (lib)
    mkOption
    types
    concatStringsSep
    concatMapStringsSep
    elem
    optionals
    ;
  collectorIsEnabled = final: elem final cfg.enabledCollectors;
  collectorIsDisabled = final: elem final cfg.disabledCollectors;
in
{
  extraOpts = {
    disabledCollectors = mkOption {
      default = [ ];

      description = ''
        Collectors to disable which are enabled by default.
      '';

      example = [ "timex" ];
      type = types.listOf types.str;
    };

    enabledCollectors = mkOption {
      default = [ ];

      description = ''
        Collectors to enable. The collectors listed here are enabled in addition to the default ones.
      '';

      example = [ "systemd" ];
      type = types.listOf types.str;
    };
  };

  port = 9100;

  serviceOpts = {
    serviceConfig = {
      DynamicUser = false;

      ExecStart = ''
        ${pkgs.prometheus-node-exporter}/bin/node_exporter \
          ${concatMapStringsSep " " (x: "--collector." + x) cfg.enabledCollectors} \
          ${concatMapStringsSep " " (x: "--no-collector." + x) cfg.disabledCollectors} \
          --web.listen-address ${cfg.listenAddress}:${toString cfg.port} ${concatStringsSep " " cfg.extraFlags}
      '';

      # The timex collector needs to access clock APIs
      ProtectClock = collectorIsDisabled "timex";
      # Allow space monitoring under /home
      ProtectHome = true;

      RestrictAddressFamilies =
        optionals (collectorIsEnabled "logind" || collectorIsEnabled "systemd") [
          # needs access to dbus via unix sockets (logind/systemd)
          "AF_UNIX"
        ]
        ++
          optionals
            (collectorIsEnabled "network_route" || collectorIsEnabled "wifi" || !collectorIsDisabled "netdev")
            [
              # needs netlink sockets for wireless collector
              "AF_NETLINK"
            ];

      RuntimeDirectory = "prometheus-node-exporter";
    };
  };
}
