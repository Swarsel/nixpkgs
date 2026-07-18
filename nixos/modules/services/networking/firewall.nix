{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.networking.firewall;

  canonicalizePortList = ports: lib.unique (builtins.sort builtins.lessThan ports);

  commonOptions = {
    allowedTCPPortRanges = lib.mkOption {
      default = [ ];

      description = ''
        A range of TCP ports on which incoming connections are
        accepted.
      '';

      example = [
        {
          from = 8999;
          to = 9003;
        }
      ];

      type = lib.types.listOf (lib.types.attrsOf lib.types.port);
    };

    allowedTCPPorts = lib.mkOption {
      apply = canonicalizePortList;
      default = [ ];

      description = ''
        List of TCP ports on which incoming connections are
        accepted.
      '';

      example = [
        22
        80
      ];

      type = lib.types.listOf lib.types.port;
    };

    allowedUDPPortRanges = lib.mkOption {
      default = [ ];

      description = ''
        Range of open UDP ports.
      '';

      example = [
        {
          from = 60000;
          to = 61000;
        }
      ];

      type = lib.types.listOf (lib.types.attrsOf lib.types.port);
    };

    allowedUDPPorts = lib.mkOption {
      apply = canonicalizePortList;
      default = [ ];

      description = ''
        List of open UDP ports.
      '';

      example = [ 53 ];
      type = lib.types.listOf lib.types.port;
    };
  };

in

{
  options = {
    networking.firewall = {
      enable = lib.mkOption {
        default = true;

        description = ''
          Whether to enable the firewall.  This is a simple stateful
          firewall that blocks connection attempts to unauthorised TCP
          or UDP ports on this machine.
        '';

        type = lib.types.bool;
      };

      package = lib.mkOption {
        default = if config.networking.nftables.enable then pkgs.nftables else pkgs.iptables;
        defaultText = lib.literalExpression ''if config.networking.nftables.enable then "pkgs.nftables" else "pkgs.iptables"'';

        description = ''
          The package to use for running the firewall service.
        '';

        example = lib.literalExpression "pkgs.iptables-legacy";
        type = lib.types.package;
      };

      allInterfaces = lib.mkOption {
        default = {
          default = lib.mapAttrs (name: value: cfg.${name}) commonOptions;
        }
        // cfg.interfaces;

        description = ''
          All open ports.
        '';

        internal = true;
        type = with lib.types; attrsOf (submodule [ { options = commonOptions; } ]);
        visible = false;
      };

      allowPing = lib.mkOption {
        default = true;

        description = ''
          Whether to respond to incoming ICMPv4 echo requests
          ("pings").  ICMPv6 pings are always allowed because the
          larger address space of IPv6 makes network scanning much
          less effective.
        '';

        type = lib.types.bool;
      };

      autoLoadConntrackHelpers = lib.mkOption {
        default = false;

        description = ''
          Whether to auto-load connection-tracking helpers.
          See the description at networking.firewall.connectionTrackingModules

          (needs kernel 3.5+)
        '';

        type = lib.types.bool;
      };

      backend = lib.mkOption {
        default =
          if config.services.firewalld.enable then
            "firewalld"
          else if config.networking.nftables.enable then
            "nftables"
          else
            "iptables";

        defaultText = lib.literalExpression ''
          if config.services.firewalld.enable then
            "firewalld"
          else if config.networking.nftables.enable then
            "nftables"
          else
            "iptables"
        '';

        description = ''
          Underlying implementation for the firewall service.
        '';

        type = lib.types.enum [
          "iptables"
          "nftables"
          "firewalld"
        ];
      };

      checkReversePath = lib.mkOption {
        default = true;
        defaultText = lib.literalMD "`true` except if the iptables based firewall is in use and the kernel lacks rpfilter support";

        description = ''
          Performs a reverse path filter test on a packet.  If a reply
          to the packet would not be sent via the same interface that
          the packet arrived on, it is refused.

          If using asymmetric routing or other complicated routing, set
          this option to loose mode or disable it and setup your own
          counter-measures.

          This option can be either true (or "strict"), "loose" (only
          drop the packet if the source address is not reachable via any
          interface) or false.
        '';

        example = "loose";

        type = lib.types.either lib.types.bool (
          lib.types.enum [
            "strict"
            "loose"
          ]
        );
      };

      connectionTrackingModules = lib.mkOption {
        default = [ ];

        description = ''
          List of connection-tracking helpers that are auto-loaded.
          The complete list of possible values is given in the example.

          As helpers can pose as a security risk, it is advised to
          set this to an empty list and disable the setting
          networking.firewall.autoLoadConntrackHelpers unless you
          know what you are doing. Connection tracking is disabled
          by default.

          Loading of helpers is recommended to be done through the
          CT target.  More info:
          <https://home.regit.org/netfilter-en/secure-use-of-helpers/>
        '';

        example = [
          "ftp"
          "irc"
          "sane"
          "sip"
          "tftp"
          "amanda"
          "h323"
          "netbios_sn"
          "pptp"
          "snmp"
        ];

        type = lib.types.listOf lib.types.str;
      };

      extraPackages = lib.mkOption {
        default = [ ];

        description = ''
          Additional packages to be included in the environment of the system
          as well as the path of networking.firewall.extraCommands.
        '';

        example = lib.literalExpression "[ pkgs.ipset ]";
        type = lib.types.listOf lib.types.package;
      };

      filterForward = lib.mkOption {
        default = false;

        description = ''
          Enable filtering in IP forwarding.

          This option only works with the nftables based firewall.
        '';

        type = lib.types.bool;
      };

      interfaces = lib.mkOption {
        default = { };

        description = ''
          Interface-specific open ports.
        '';

        type = with lib.types; attrsOf (submodule [ { options = commonOptions; } ]);
      };

      logRefusedConnections = lib.mkOption {
        default = false;

        description = ''
          Whether to log rejected or dropped incoming connections.
          Note: The logs are found in the kernel logs, i.e. dmesg
          or journalctl -k.
        '';

        type = lib.types.bool;
      };

      logRefusedPackets = lib.mkOption {
        default = false;

        description = ''
          Whether to log all rejected or dropped incoming packets.
          This tends to give a lot of log messages, so it's mostly
          useful for debugging.
          Note: The logs are found in the kernel logs, i.e. dmesg
          or journalctl -k.
        '';

        type = lib.types.bool;
      };

      logRefusedUnicastsOnly = lib.mkOption {
        default = true;

        description = ''
          If {option}`networking.firewall.logRefusedPackets`
          and this option are enabled, then only log packets
          specifically directed at this machine, i.e., not broadcasts
          or multicasts.
        '';

        type = lib.types.bool;
      };

      logReversePathDrops = lib.mkOption {
        default = false;

        description = ''
          Logs dropped packets failing the reverse path filter test if
          the option networking.firewall.checkReversePath is enabled.
        '';

        type = lib.types.bool;
      };

      pingLimit = lib.mkOption {
        default = null;

        description = ''
          If pings are allowed, this allows setting rate limits on them.

          For the iptables based firewall, it should be set like
          "--limit 1/minute --limit-burst 5".

          For the nftables based firewall, it should be set like
          "2/second" or "1/minute burst 5 packets".
        '';

        example = "--limit 1/minute --limit-burst 5";
        type = lib.types.nullOr (lib.types.separatedString " ");
      };

      rejectPackets = lib.mkOption {
        default = false;

        description = ''
          If set, refused packets are rejected rather than dropped
          (ignored).  This means that an ICMP "port unreachable" error
          message is sent back to the client (or a TCP RST packet in
          case of an existing connection).  Rejecting packets makes
          port scanning somewhat easier.
        '';

        type = lib.types.bool;
      };

      trustedInterfaces = lib.mkOption {
        default = [ ];

        description = ''
          Traffic coming in from these interfaces will be accepted
          unconditionally.  Traffic from the loopback (lo) interface
          will always be accepted.
        '';

        example = [ "enp0s2" ];
        type = lib.types.listOf lib.types.str;
      };
    }
    // commonOptions;
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.filterForward -> config.networking.nftables.enable;
        message = "filterForward only works with the nftables based firewall";
      }
      {
        assertion =
          cfg.autoLoadConntrackHelpers -> lib.versionOlder config.boot.kernelPackages.kernel.version "6";

        message = "conntrack helper autoloading has been removed from kernel 6.0 and newer";
      }
    ];

    boot.extraModprobeConfig = lib.optionalString cfg.autoLoadConntrackHelpers ''
      options nf_conntrack nf_conntrack_helper=1
    '';

    boot.kernelModules =
      (lib.optional cfg.autoLoadConntrackHelpers "nf_conntrack")
      ++ map (x: "nf_conntrack_${x}") cfg.connectionTrackingModules;

    environment.systemPackages = [ cfg.package ] ++ cfg.extraPackages;
    networking.firewall.trustedInterfaces = [ "lo" ];
  };
}
