{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    attrNames
    escapeShellArgs
    filterAttrs
    getExe'
    last
    literalExpression
    maintainers
    mapAttrs'
    mkOption
    mkPackageOption
    optionals
    splitString
    toInt
    types
    ;

  cfg = config.services.udp-over-tcp;

  commonOptions = {
    # Options and descriptions as indicated by `tcp2udp --help` and `udp2tcp --help`.
    forward = mkOption {
      description = ''
        The IP and port to forward all traffic to.
      '';

      type = types.str;
    };

    fwmark = mkOption {
      default = null;

      description = ''
        If given, sets the SO_MARK option on the TCP socket.
      '';

      type = types.nullOr types.ints.u32;
    };

    nodelay = mkOption {
      default = false;

      description = ''
        Enables TCP_NODELAY on the TCP socket.
      '';

      type = types.bool;
    };

    openFirewall = mkOption {
      default = false;

      description = ''
        Open the appropriate ports in the firewall.
      '';

      type = types.bool;
    };

    recvBufferSize = mkOption {
      default = null;

      description = ''
        If given, sets the SO_RCVBUF option on the TCP socket to the given number of bytes.
        Changes the size of the operating system's receive buffer associated with the socket.
      '';

      type = types.nullOr types.ints.positive;
    };

    recvTimeout = mkOption {
      default = null;

      description = ''
        An application timeout on receiving data from the TCP socket.
      '';

      type = types.nullOr types.ints.positive;
    };

    sendBufferSize = mkOption {
      default = null;

      description = ''
        If given, sets the SO_SNDBUF option on the TCP socket to the given number of bytes.
        Changes the size of the operating system's send buffer associated with the socket.
      '';

      type = types.nullOr types.ints.positive;
    };
  };
  tcp2udpSubmodule = {
    options = commonOptions // {
      bind = mkOption {
        default = null;

        description = ''
          Which local IP to bind the UDP socket to.
        '';

        type = types.nullOr types.str;
      };

      threads = mkOption {
        default = null;

        description = ''
          Sets the number of worker threads to use.
          The default value is the number of cores available to the system.
        '';

        type = types.nullOr types.ints.positive;
      };
    };
  };
  udp2tcpSubmodule = {
    options = commonOptions;
  };

  configToService = type: buildCmdline: listen: conf: {
    name = "${type}-${listen}";

    value = {
      after = [ "network-online.target" ];
      description = "${type} tunnel from ${listen} to ${conf.forward}";
      reloadIfChanged = true;

      serviceConfig = {
        # CAP_NET_BIND_SERVICE in case we are binding to ports < 1024, CAP_NET_ADMIN only covers addresses.
        # CAP_NET_ADMIN for setting SO_MARK on the socket.
        AmbientCapabilities = [
          "CAP_NET_ADMIN"
          "CAP_NET_BIND_SERVICE"
        ];

        CapabilityBoundingSet = [
          "CAP_NET_ADMIN"
          "CAP_NET_BIND_SERVICE"
        ];

        DynamicUser = true;
        ExecStart = "${getExe' cfg.package type} " + escapeShellArgs (buildCmdline listen conf);
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = false;
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
        RestartSec = 10;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        Type = "exec";
        UMask = "077";
        User = "udp-over-tcp";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  buildCommonCmdline =
    listen: conf:
    optionals (conf.recvBufferSize != null) [
      "--recv-buffer"
      conf.recvBufferSize
    ]
    ++ optionals (conf.sendBufferSize != null) [
      "--send-buffer"
      conf.sendBufferSize
    ]
    ++ optionals (conf.recvTimeout != null) [
      "--tcp-recv-timeout"
      conf.recvTimeout
    ]
    ++ optionals (conf.fwmark != null) [
      "--fwmark"
      conf.fwmark
    ]
    ++ optionals conf.nodelay [
      "--nodelay"
    ];
  buildTcp2udpCmdline =
    listen: conf:
    [
      "--tcp-listen"
      listen
      "--udp-forward"
      conf.forward
    ]
    ++ optionals (conf.threads != null) [
      "--threads"
      conf.threads
    ]
    ++ optionals (conf.bind != null) [
      "--udp-bind"
      conf.bind
    ]
    ++ buildCommonCmdline listen conf;
  buildUdp2tcpCmdline =
    listen: conf:
    [
      "--udp-listen"
      listen
      "--tcp-forward"
      conf.forward
    ]
    ++ buildCommonCmdline listen conf;

  getFirewallPorts =
    instances:
    map (e: toInt (last (splitString ":" e))) (
      attrNames (filterAttrs (_: e: e.openFirewall) instances)
    );
in
{
  options.services.udp-over-tcp = {
    package = mkPackageOption pkgs "udp-over-tcp" { };

    tcp2udp = mkOption {
      default = { };

      description = ''
        Mapping of TCP listening ports to UDP forwarding ports or configurations.
      '';

      example = literalExpression ''
        {
          "0.0.0.0:443" = {
            forward = "127.0.0.1:51820";
            openFirewall = true;
          };
          "0.0.0.0:444" = {
            threads = 2;
            forward = "127.0.0.1:51821";
            bind = "127.0.0.1";
            recvBufferSize = 16384;
            sendBufferSize = 16384;
            recvTimeout = 10;
            fwmark = 1337;
            nodelay = true;
          };
        }
      '';

      type = types.attrsOf (types.submodule tcp2udpSubmodule);
    };

    udp2tcp = mkOption {
      default = { };

      description = ''
        Mapping of UDP listening ports to TCP forwarding ports or configurations.
      '';

      example = literalExpression ''
        {
          "0.0.0.0:51820" = {
            forward = "10.0.0.1:443";
            openFirewall = true;
          };
          "0.0.0.0:51821" = {
            forward = "10.0.0.1:444";
            recvBufferSize = 16384;
            sendBufferSize = 16384;
            recvTimeout = 10;
            fwmark = 1337;
            nodelay = true;
          };
        }
      '';

      type = types.attrsOf (types.submodule udp2tcpSubmodule);
    };
  };

  config = {
    networking.firewall.allowedTCPPorts = getFirewallPorts cfg.tcp2udp;
    networking.firewall.allowedUDPPorts = getFirewallPorts cfg.udp2tcp;

    systemd.services =
      (mapAttrs' (configToService "tcp2udp" buildTcp2udpCmdline) cfg.tcp2udp)
      // (mapAttrs' (configToService "udp2tcp" buildUdp2tcpCmdline) cfg.udp2tcp);
  };

  meta.maintainers = with maintainers; [ timschumi ];
}
