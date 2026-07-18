{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.prometheus.exporters.chrony;
  inherit (lib)
    mkOption
    types
    concatStringsSep
    concatMapStringsSep
    ;
in
{
  extraOpts = {
    chronyServerAddress = mkOption {
      default = "unix:///run/chrony/chronyd.sock";

      description = ''
        ChronyServerAddress of the chrony server side command port. (Not enabled by default.)
        Defaults to the local unix socket.
      '';

      example = [ "192.82.0.1:323" ];
      type = types.str;
    };

    disabledCollectors = mkOption {
      default = [ ];

      description = ''
        Collectors to disable which are enabled by default.
        Disable sources.with-ntpdata for network scraper. Option requires unix socket.
      '';

      example = [ "sources.with-ntpdata" ];
      type = types.listOf types.str;
    };

    enabledCollectors = mkOption {
      default = [
        "tracking"
        "sources"
        "sources.with-ntpdata"
        "serverstats"
        "dns-lookups"
      ];

      description = ''
        Collectors to enable.
        Currently all collectors are enabled by default.
      '';

      example = [ "dns-lookups" ];
      type = types.listOf types.str;
    };

    group = mkOption {
      default = "chrony";

      description = ''
        Group under which the chrony exporter shall be run.
        This allows the exporter to talk to chrony using a unix socket, which is owned by chrony group.
        The service startup with the default group chrony will fail without local chrony instance.
      '';

      type = types.str;
    };

    user = mkOption {
      default = "chrony";

      description = ''
        User name under which the chrony exporter shall be run.
        This allows the exporter to talk to chrony using a unix socket, which is owned by chrony.
        The exporter startup with the default user chrony will fail without local chrony instance.
      '';

      type = types.str;
    };
  };

  port = 9123;

  serviceOpts = {
    serviceConfig = {
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];

      ExecStart = ''
        ${lib.getExe pkgs.prometheus-chrony-exporter} \
          ${concatMapStringsSep " " (x: "--collector." + x) cfg.enabledCollectors} \
          ${concatMapStringsSep " " (x: "--no-collector." + x) cfg.disabledCollectors} \
          --chrony.address ${cfg.chronyServerAddress} \
          --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
          ${concatStringsSep " " cfg.extraFlags}
      '';

      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      ProtectClock = true;
      ProtectSystem = "strict";
      Restart = "on-failure";

      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];

      RestrictNamespaces = true;
      RestrictRealtime = true;
    };
  };
}
