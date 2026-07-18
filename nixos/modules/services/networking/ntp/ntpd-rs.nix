{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.ntpd-rs;
  format = pkgs.formats.toml { };
  configFile = format.generate "ntpd-rs.toml" cfg.settings;

  validateConfig =
    file:
    pkgs.runCommand "validate-ntpd-rs.toml"
      {
        nativeBuildInputs = [ cfg.package ];
      }
      ''
        ntp-ctl validate -c ${file}
        ln -s "${file}" "$out"
      '';
in
{
  options.services.ntpd-rs = {
    enable = lib.mkEnableOption "Network Time Service (ntpd-rs)";
    package = lib.mkPackageOption pkgs "ntpd-rs" { };
    metrics.enable = lib.mkEnableOption "ntpd-rs Prometheus Metrics Exporter";

    settings = lib.mkOption {
      default = { };

      description = ''
        Settings to write to {file}`ntp.toml`

        See <https://docs.ntpd-rs.pendulum-project.org/man/ntp.toml.5>
        for more information about available options.
      '';

      type = lib.types.submodule {
        freeformType = format.type;
      };
    };

    useNetworkingTimeServers = lib.mkOption {
      default = true;

      description = ''
        Use source time servers from {var}`networking.timeServers` in config.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.services.timesyncd.enable;

        message = ''
          `ntpd-rs` is not compatible with `services.timesyncd`. Please disable one of them.
        '';
      }
    ];

    environment.systemPackages = [ cfg.package ];

    services.ntpd-rs.settings = {
      observability = {
        log-level = lib.mkDefault "warn";
        observation-path = lib.mkDefault "/var/run/ntpd-rs/observe";
      };

      source = lib.mkIf cfg.useNetworkingTimeServers (
        map (ts: {
          address = ts;
          mode = if lib.strings.hasInfix "pool" ts then "pool" else "server";
        }) config.networking.timeServers
      );
    };

    services.timesyncd.enable = false;
    systemd.packages = [ cfg.package ];

    systemd.services.ntpd-rs = {
      serviceConfig = {
        AmbientCapabilities = [
          "CAP_SYS_TIME"
          "CAP_NET_BIND_SERVICE"
        ];

        CapabilityBoundingSet = [
          "CAP_SYS_TIME"
          "CAP_NET_BIND_SERVICE"
        ];

        DynamicUser = true;

        ExecStart = [
          ""
          "${lib.makeBinPath [ cfg.package ]}/ntp-daemon --config=${validateConfig configFile}"
        ];

        Group = "";
        LimitCORE = 0;
        LimitNOFILE = 65535;
        LockPersonality = true;
        MemorySwapMax = 0;
        MemoryZSwapMax = 0;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestartSec = "10s";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
          "AF_NETLINK"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "@resources"
          "@network-io"
          "@clock"
        ];

        UMask = "0077";
        User = "";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.ntpd-rs-metrics = lib.mkIf cfg.metrics.enable {
      serviceConfig = {
        CapabilityBoundingSet = [ ];
        DynamicUser = true;

        ExecStart = [
          ""
          "${lib.makeBinPath [ cfg.package ]}/ntp-metrics-exporter --config=${validateConfig configFile}"
        ];

        Group = "";
        LimitCORE = 0;
        LimitNOFILE = 65535;
        LockPersonality = true;
        MemorySwapMax = 0;
        MemoryZSwapMax = 0;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "@network-io"
          "~@privileged"
          "~@resources"
          "~@mount"
        ];

        UMask = "0077";
        User = "";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.systemd-timedated.environment = {
      SYSTEMD_TIMEDATED_NTP_SERVICES = "ntpd-rs.service";
    };
  };

  meta.maintainers = with lib.maintainers; [ fpletz ];
}
