{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.openthread-border-router;
  logLevelMappings = {
    "alert" = 1;
    "crit" = 2;
    "debug" = 7;
    "emerg" = 0;
    "err" = 3;
    "info" = 6;
    "notice" = 5;
    "warning" = 4;
  };
  logLevel = lib.getAttr cfg.logLevel logLevelMappings;
  # Use correct iptables for otbr-firewall (legacy vs nf-compat)
  iptables =
    let
      inherit (config.networking) firewall;
    in
    if firewall.backend == "iptables" then firewall.package else pkgs.iptables;
in
{
  options.services.openthread-border-router = {
    enable = lib.mkEnableOption "the OpenThread Border Router";
    package = lib.mkPackageOption pkgs "openthread-border-router" { };

    backboneInterfaces = lib.mkOption {
      default = [ "eth0" ];
      description = "The network interfaces on which to advertise the thread ipv6 mesh prefix. Can be specified multiple times.";
      type = lib.types.listOf lib.types.str;
    };

    extraArgs = lib.mkOption {
      default = [ ];
      description = "Extra arguments to pass to the otbr-agent daemon.";
      example = [ "--radio-version" ];
      type = lib.types.listOf lib.types.str;
    };

    interfaceName = lib.mkOption {
      default = "wpan0";
      description = "The network interface to create for thread packets.";
      type = lib.types.str;
    };

    logLevel = lib.mkOption {
      default = "err";
      description = "The level to use when logging messages.";
      type = lib.types.enum (lib.attrNames logLevelMappings);
    };

    openFirewall = lib.mkOption {
      default = false;
      description = "Whether to open the firewall for the REST API and web interface ports.";
      type = lib.types.bool;
    };

    radio = {
      baudRate = lib.mkOption {
        default = 115200;

        description = ''
          The baud rate of the radio device.
          Ignored if {option}`services.openthread-border-router.radio.url` is set.
        '';

        type = lib.types.ints.positive;
      };

      device = lib.mkOption {
        default = null;

        description = ''
          The device name of the serial port of the radio device.
          Ignored if {option}`services.openthread-border-router.radio.url` is set.
        '';

        type = lib.types.nullOr lib.types.path;
      };

      extraDevices = lib.mkOption {
        default = [ ];
        description = "Extra devices to add to the radio device.";
        example = [ "trel://eth0" ];
        type = lib.types.listOf lib.types.str;
      };

      flowControl = lib.mkOption {
        default = false;

        description = ''
          Enable hardware flow control.
          Ignored if {option}`services.openthread-border-router.radio.url` is set.
        '';

        type = lib.types.bool;
      };

      url = lib.mkOption {
        default = null;
        description = "The URL of the radio device to use.";
        example = "spinel+hdlc+uart:///dev/ttyUSB0?uart-baudrate=460800&uart-flow-control";
        type = lib.types.nullOr lib.types.str;
      };

      urlQueryString = lib.mkOption {
        default = "";

        description = ''
          Extra URL query string parameters.
          Ignored if {option}`services.openthread-border-router.radio.url` is set.
        '';

        example = "bus-latency=100&region=ca";
        type = lib.types.str;
      };
    };

    rest = {
      listenAddress = lib.mkOption {
        default = "127.0.0.1";
        description = "The address on which to listen for REST API requests.";
        example = "::";
        type = lib.types.str;
      };

      listenPort = lib.mkOption {
        default = 8081;
        description = "The port on which to listen for REST API requests. Warning: the web interface relies on this value being set to 8081.";
        type = lib.types.port;
      };
    };

    web = {
      enable = lib.mkEnableOption "the web interface";

      listenAddress = lib.mkOption {
        default = "127.0.0.1";
        description = "The address on which the web interface should listen.";
        example = "::";
        type = lib.types.str;
      };

      listenPort = lib.mkOption {
        default = 8082;
        description = "The port on which the web interface should listen.";
        type = lib.types.port;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.radio.device != null || cfg.radio.url != null;
        message = "services.openthread-border-router requires either radio.device or radio.url to be set.";
      }
    ];

    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    }
    // lib.listToAttrs (
      lib.concatMap (iface: [
        {
          name = "net.ipv6.conf.${iface}.accept_ra";
          value = 2;
        }
        {
          name = "net.ipv6.conf.${iface}.accept_ra_rt_info_max_plen";
          value = 64;
        }
      ]) cfg.backboneInterfaces
    );

    # ot-ctl can be used to query the router instance
    environment.systemPackages = [ cfg.package ];
    # Make sure we have ipv6 support, and that forwarding is enabled
    networking.enableIPv6 = true;

    networking.firewall.allowedTCPPorts =
      lib.optional cfg.openFirewall cfg.rest.listenPort
      ++ lib.optional (cfg.openFirewall && cfg.web.enable) cfg.web.listenPort;

    services.openthread-border-router.radio.url = lib.mkIf (cfg.radio.device != null) (
      lib.mkDefault (
        "spinel+hdlc+uart://${cfg.radio.device}?"
        + lib.concatStringsSep "&" (
          [ "uart-baudrate=${toString cfg.radio.baudRate}" ]
          ++ lib.optional cfg.radio.flowControl "uart-flow-control"
          ++ lib.optional (cfg.radio.urlQueryString != "") cfg.radio.urlQueryString
        )
      )
    );

    # The upstream service files (src/agent/otbr-agent.service.in, src/web/otbr-web.service.in) use
    # EnvironmentFile and CMake-substituted platform scripts that don't translate to NixOS, so the
    # services are rebuilt here from typed module options instead.
    systemd.services = {
      # The agent keeps its local state in /var/lib/thread
      otbr-agent = {
        after = [ "network-online.target" ];
        description = "OpenThread Border Router Agent";

        environment = {
          THREAD_IF = cfg.interfaceName;
        };

        path = [
          pkgs.ipset
          iptables
        ];

        requires = [ "network-online.target" ];

        serviceConfig = {
          CapabilityBoundingSet = [
            "CAP_NET_ADMIN"
            "CAP_NET_RAW"
          ];

          ExecStart = lib.concatStringsSep " " (
            lib.concatLists [
              [
                (lib.getExe' cfg.package "otbr-agent")
                "--verbose"
              ]
              (map (iface: "--backbone-ifname ${utils.escapeSystemdExecArg iface}") cfg.backboneInterfaces)
              [
                "--thread-ifname ${utils.escapeSystemdExecArg cfg.interfaceName}"
                "--debug-level ${toString logLevel}"
              ]
              (lib.optional (cfg.rest.listenPort != 0) "--rest-listen-port ${toString cfg.rest.listenPort}")
              (lib.optional (
                cfg.rest.listenAddress != ""
              ) "--rest-listen-address ${utils.escapeSystemdExecArg cfg.rest.listenAddress}")
              (lib.optional (cfg.radio.url != null) (utils.escapeSystemdExecArg cfg.radio.url))
              (map utils.escapeSystemdExecArg cfg.radio.extraDevices)
              (map utils.escapeSystemdExecArg cfg.extraArgs)
            ]
          );

          ExecStartPre = "${utils.escapeSystemdExecArg (lib.getExe' cfg.package "otbr-firewall")} start";
          ExecStopPost = "${utils.escapeSystemdExecArg (lib.getExe' cfg.package "otbr-firewall")} stop";
          KillMode = "mixed";
          LockPersonality = true;
          NoNewPrivileges = true;
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
          Restart = "on-failure";
          RestartPreventExitStatus = "SIGKILL";
          RestartSec = 5;

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
            "AF_UNIX"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          # Hardening options (not present in upstream service definitions)
          StateDirectory = "thread";
          SystemCallArchitectures = "native";
          UMask = "0077";
        };

        wantedBy = [ "multi-user.target" ];
      };

      # Sync with: src/web/otbr-web.service.in
      otbr-web = lib.mkIf cfg.web.enable {
        after = [ "otbr-agent.service" ];
        description = "OpenThread Border Router Web Interface";

        serviceConfig = {
          CapabilityBoundingSet = "";
          # Hardening options (not present in upstream service definitions)
          DynamicUser = true;

          ExecStart = lib.concatStringsSep " " (
            lib.concatLists [
              [
                (lib.getExe' cfg.package "otbr-web")
                "-I"
                (utils.escapeSystemdExecArg cfg.interfaceName)
                "-d"
                (toString logLevel)
              ]
              (lib.optional (
                cfg.web.listenAddress != ""
              ) "-a ${utils.escapeSystemdExecArg cfg.web.listenAddress}")
              (lib.optional (cfg.web.listenPort != 0) "-p ${toString cfg.web.listenPort}")
            ]
          );

          LockPersonality = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          PrivateUsers = true;
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

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          UMask = "0077";
        };

        wantedBy = [ "multi-user.target" ];
      };
    };

    warnings = lib.optional (cfg.web.enable && cfg.rest.listenPort != 8081) ''
      The openthread-border-router web interface is hardcoded to talk to the REST API on port 8081, but its
      port has been changed to ${toString cfg.rest.listenPort}. Some features will be broken.
    '';
  };

  meta.maintainers = with lib.maintainers; [
    jamiemagee
    leonm1
    mrene
  ];
}
