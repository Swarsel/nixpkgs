{ lib }:

with lib;
{
  options = {

    extraConfig = mkOption {
      default = "";

      description = ''
        Extra lines to be added verbatim to the vrrp_instance section.
      '';

      type = types.lines;
    };

    interface = mkOption {
      description = ''
        Interface for inside_network, bound by vrrp.
      '';

      type = types.str;
    };

    noPreempt = mkOption {
      default = false;

      description = ''
        VRRP will normally preempt a lower priority machine when a higher
        priority machine comes online. "nopreempt" allows the lower priority
        machine to maintain the master role, even when a higher priority machine
        comes back online. NOTE: For this to work, the initial state of this
        entry must be BACKUP.
      '';

      type = types.bool;
    };

    priority = mkOption {
      default = 100;

      description = ''
        For electing MASTER, highest priority wins. To be MASTER, make 50 more
        than other machines.
      '';

      type = types.int;
    };

    state = mkOption {
      default = "BACKUP";

      description = ''
        Initial state. As soon as the other machine(s) come up, an election will
        be held and the machine with the highest "priority" will become MASTER.
        So the entry here doesn't matter a whole lot.
      '';

      type = types.enum [
        "MASTER"
        "BACKUP"
      ];
    };

    trackInterfaces = mkOption {
      default = [ ];
      description = "List of network interfaces to monitor for health tracking.";

      example = [
        "eth0"
        "eth1"
      ];

      type = types.listOf types.str;
    };

    trackScripts = mkOption {
      default = [ ];
      description = "List of script names to invoke for health tracking.";

      example = [
        "chk_cmd1"
        "chk_cmd2"
      ];

      type = types.listOf types.str;
    };

    unicastPeers = mkOption {
      default = [ ];

      description = ''
        Do not send VRRP adverts over VRRP multicast group. Instead it sends
        adverts to the following list of ip addresses using unicast design
        fashion. It can be cool to use VRRP FSM and features in a networking
        environment where multicast is not supported! IP Addresses specified can
        IPv4 as well as IPv6.
      '';

      type = types.listOf types.str;
    };

    unicastSrcIp = mkOption {
      default = null;

      description = ''
        Default IP for binding vrrpd is the primary IP on interface. If you
        want to hide location of vrrpd, use this IP as src_addr for unicast
        vrrp packets.
      '';

      type = types.nullOr types.str;
    };

    useVmac = mkOption {
      default = false;

      description = ''
        Use VRRP Virtual MAC.
      '';

      type = types.bool;
    };

    virtualIps = mkOption {
      default = [ ];
      # TODO: example
      description = "Declarative vhost config";

      type = types.listOf (
        types.submodule (
          import ./virtual-ip-options.nix {
            inherit lib;
          }
        )
      );
    };

    virtualRouterId = mkOption {
      description = ''
        Arbitrary unique number 1..255. Used to differentiate multiple instances
        of vrrpd running on the same NIC (and hence same socket).
      '';

      type = types.ints.between 1 255;
    };

    vmacInterface = mkOption {
      default = null;

      description = ''
        Name of the vmac interface to use. keepalived will come up with a name
        if you don't specify one.
      '';

      type = types.nullOr types.str;
    };

    vmacXmitBase = mkOption {
      default = false;

      description = ''
        Send/Recv VRRP messages from base interface instead of VMAC interface.
      '';

      type = types.bool;
    };

  };

}
