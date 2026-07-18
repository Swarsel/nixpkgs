# This module enables Network Address Translation (NAT).
# XXX: todo: support multiple upstream links
# see http://yesican.chsoft.biz/lartc/MultihomedLinuxNetworking.html

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.networking.nat;

in

{

  options = {

    networking.nat.dmzHost = mkOption {
      default = null;

      description = ''
        The local IP address to which all traffic that does not match any
        forwarding rule is forwarded.
      '';

      example = "10.0.0.1";
      type = types.nullOr types.str;
    };

    networking.nat.enable = mkOption {
      default = false;

      description = ''
        Whether to enable Network Address Translation (NAT). A
        properly configured firewall or a trusted L2 on all network
        interfaces is required to prevent unauthorized access to
        the internal network.
      '';

      type = types.bool;
    };

    networking.nat.enableIPv6 = mkOption {
      default = false;

      description = ''
        Whether to enable IPv6 NAT.
      '';

      type = types.bool;
    };

    networking.nat.externalIP = mkOption {
      default = null;

      description = ''
        The public IP address to which packets from the local
        network are to be rewritten.  If this is left empty, the
        IP address associated with the external interface will be
        used.  Only connections made to this IP address will be
        forwarded to the internal network when using forwardPorts.
      '';

      example = "203.0.113.123";
      type = types.nullOr types.str;
    };

    networking.nat.externalIPv6 = mkOption {
      default = null;

      description = ''
        The public IPv6 address to which packets from the local
        network are to be rewritten.  If this is left empty, the
        IP address associated with the external interface will be
        used.  Only connections made to this IP address will be
        forwarded to the internal network when using forwardPorts.
      '';

      example = "2001:dc0:2001:11::175";
      type = types.nullOr types.str;
    };

    networking.nat.externalInterface = mkOption {
      default = null;

      description = ''
        The name of the external network interface.
      '';

      example = "eth1";
      type = types.nullOr types.str;
    };

    networking.nat.forwardPorts = mkOption {
      default = [ ];

      description = ''
        List of forwarded ports from the external interface to
        internal destinations by using DNAT. Destination can be
        IPv6 if IPv6 NAT is enabled.
      '';

      example = [
        {
          destination = "10.0.0.1:80";
          proto = "tcp";
          sourcePort = 8080;
        }
        {
          destination = "[fc00::2]:80";
          proto = "tcp";
          sourcePort = 8080;
        }
      ];

      type =
        with types;
        listOf (submodule {
          options = {
            destination = mkOption {
              description = "Forward connection to destination ip:port (or [ipv6]:port); to specify a port range, use ip:start-end";
              example = "10.0.0.1:80";
              type = types.str;
            };

            loopbackIPs = mkOption {
              default = [ ];
              description = "Public IPs for NAT reflection; for connections to `loopbackip:sourcePort` from the host itself and from other hosts behind NAT";
              example = literalExpression ''[ "55.1.2.3" ]'';
              type = types.listOf types.str;
            };

            proto = mkOption {
              default = "tcp";
              description = "Protocol of forwarded connection";
              example = "udp";
              type = types.str;
            };

            sourcePort = mkOption {
              description = "Source port of the external interface; to specify a port range, use a string with a colon (e.g. \"60000:61000\")";
              example = 8080;
              type = types.either types.int (types.strMatching "[[:digit:]]+:[[:digit:]]+");
            };
          };
        });
    };

    networking.nat.internalIPs = mkOption {
      default = [ ];

      description = ''
        The IP address ranges for which to perform NAT.  Packets
        coming from these addresses (on any interface) and destined
        for the external interface will be rewritten.
      '';

      example = [ "192.168.1.0/24" ];
      type = types.listOf types.str;
    };

    networking.nat.internalIPv6s = mkOption {
      default = [ ];

      description = ''
        The IPv6 address ranges for which to perform NAT.  Packets
        coming from these addresses (on any interface) and destined
        for the external interface will be rewritten.
      '';

      example = [ "fc00::/64" ];
      type = types.listOf types.str;
    };

    networking.nat.internalInterfaces = mkOption {
      default = [ ];

      description = ''
        The interfaces for which to perform NAT. Packets coming from
        these interface and destined for the external interface will
        be rewritten.
      '';

      example = [ "eth0" ];
      type = types.listOf types.str;
    };

  };

  config = mkIf config.networking.nat.enable {

    assertions = [
      {
        assertion = cfg.enableIPv6 -> config.networking.enableIPv6;
        message = "networking.nat.enableIPv6 requires networking.enableIPv6";
      }
      {
        assertion = (cfg.dmzHost != null) -> (cfg.externalInterface != null);
        message = "networking.nat.dmzHost requires networking.nat.externalInterface";
      }
      {
        assertion = (cfg.forwardPorts != [ ]) -> (cfg.externalInterface != null);
        message = "networking.nat.forwardPorts requires networking.nat.externalInterface";
      }
    ];

    boot = {
      kernel.sysctl = {
        "net.ipv4.conf.all.forwarding" = mkOverride 99 true;
        "net.ipv4.conf.default.forwarding" = mkOverride 99 true;
      }
      // optionalAttrs cfg.enableIPv6 {
        # Do not prevent IPv6 autoconfiguration.
        # See <http://strugglers.net/~andy/blog/2011/09/04/linux-ipv6-router-advertisements-and-forwarding/>.
        "net.ipv6.conf.all.accept_ra" = mkOverride 99 2;
        # Forward IPv6 packets.
        "net.ipv6.conf.all.forwarding" = mkOverride 99 true;
        "net.ipv6.conf.default.accept_ra" = mkOverride 99 2;
        "net.ipv6.conf.default.forwarding" = mkOverride 99 true;
      };

      kernelModules = [ "nf_nat_ftp" ];
    };

    # Use the same iptables package as in config.networking.firewall.
    # When the firewall is enabled, this should be deduplicated without any
    # error.
    environment.systemPackages = [ config.networking.firewall.package ];

  };
}
