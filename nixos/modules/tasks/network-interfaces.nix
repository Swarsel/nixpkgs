{
  config,
  lib,
  pkgs,
  options,
  utils,
  ...
}:

with lib;
with utils;

let

  cfg = config.networking;
  opt = options.networking;
  interfaces = attrValues cfg.interfaces;
  hasVirtuals = any (i: i.virtual) interfaces;
  hasSits = cfg.sits != { };
  hasGres = cfg.greTunnels != { };
  hasBonds = cfg.bonds != { };
  hasFous =
    cfg.fooOverUDP != { } || filterAttrs (_: s: s.encapsulation.type != "6in4") cfg.sits != { };

  slaves =
    concatMap (i: i.interfaces) (attrValues cfg.bonds)
    ++ concatMap (i: i.interfaces) (attrValues cfg.bridges)
    ++ concatMap (
      i:
      attrNames (
        filterAttrs (name: config: !(config.type == "internal" || hasAttr name cfg.interfaces)) i.interfaces
      )
    ) (attrValues cfg.vswitches);

  slaveIfs = map (i: cfg.interfaces.${i}) (filter (i: cfg.interfaces ? ${i}) slaves);

  rstpBridges = flip filterAttrs cfg.bridges (_: { rstp, ... }: rstp);

  needsMstpd = rstpBridges != { };

  bridgeStp = optional needsMstpd (
    pkgs.writeTextFile {
      destination = "/bin/bridge-stp";
      executable = true;
      name = "bridge-stp";

      text = ''
        #!${pkgs.runtimeShell} -e
        export PATH="${pkgs.mstpd}/bin"

        BRIDGES=(${concatStringsSep " " (attrNames rstpBridges)})
        for BRIDGE in $BRIDGES; do
          if [ "$BRIDGE" = "$1" ]; then
            if [ "$2" = "start" ]; then
              mstpctl addbridge "$BRIDGE"
              exit 0
            elif [ "$2" = "stop" ]; then
              mstpctl delbridge "$BRIDGE"
              exit 0
            fi
            exit 1
          fi
        done
        exit 1
      '';
    }
  );

  addrOpts =
    v:
    assert v == 4 || v == 6;
    {
      options = {
        address = mkOption {
          description = ''
            IPv${toString v} address of the interface. Leave empty to configure the
            interface using DHCP.
          '';

          type = types.str;
        };

        prefixLength = mkOption {
          description = ''
            Subnet mask of the interface, specified as the number of
            bits in the prefix (`${if v == 4 then "24" else "64"}`).
          '';

          type = types.ints.between 0 (if v == 4 then 32 else 128);
        };
      };
    };

  routeOpts = v: {
    options = {
      options = mkOption {
        default = { };

        description = ''
          Other route options. See the symbol `OPTIONS`
          in the {manpage}`ip-route(8)` manual page for the details.
          You may also specify `metric`,
          `src`, `protocol`,
          `scope`, `from`
          and `table`, which are technically
          not route options, in the sense used in the manual.
        '';

        example = {
          mtu = "1492";
          window = "524288";
        };

        type = types.attrsOf types.str;
      };

      address = mkOption {
        description = "IPv${toString v} address of the network.";
        type = types.str;
      };

      prefixLength = mkOption {
        description = ''
          Subnet mask of the network, specified as the number of
          bits in the prefix (`${if v == 4 then "24" else "64"}`).
        '';

        type = types.ints.between 0 (if v == 4 then 32 else 128);
      };

      type = mkOption {
        default = null;

        description = ''
          Type of the route.  See the `Route types` section
          in the {manpage}`ip-route(8)` manual page for the details.

          Note that `prohibit`, `blackhole`,
          `unreachable`, and `throw` cannot
          be configured per device, so they are not available here. Similarly,
          `nat` hasn't been supported since kernel 2.6.
        '';

        type = types.nullOr (
          types.enum [
            "unicast"
            "local"
            "broadcast"
            "multicast"
          ]
        );
      };

      via = mkOption {
        default = null;
        description = "IPv${toString v} address of the next hop.";
        type = types.nullOr types.str;
      };

    };
  };

  gatewayCoerce = address: { inherit address; };

  gatewayOpts =
    { ... }:
    {

      options = {

        address = mkOption {
          description = "The default gateway address.";
          type = types.str;
        };

        interface = mkOption {
          default = null;
          description = "The default gateway interface.";
          example = "enp0s3";
          type = types.nullOr types.str;
        };

        metric = mkOption {
          default = null;
          description = "The default gateway metric/preference.";
          example = 42;
          type = types.nullOr types.int;
        };

        source = mkOption {
          default = null;
          description = "The default source address.";
          type = types.nullOr types.str;
        };

      };

    };

  interfaceOpts =
    { name, ... }:
    {

      # Renamed or removed options
      imports =
        let
          defined = x: x != "_mkMergedOptionModule";
        in
        [
          (mkChangedOptionModule [ "preferTempAddress" ] [ "tempAddress" ] (
            config:
            let
              bool = getAttrFromPath [ "preferTempAddress" ] config;
            in
            if bool then "default" else "enabled"
          ))
          (mkRenamedOptionModule [ "ip4" ] [ "ipv4" "addresses" ])
          (mkRenamedOptionModule [ "ip6" ] [ "ipv6" "addresses" ])
          (mkRemovedOptionModule [ "subnetMask" ] ''
            Supply a prefix length instead; use option
            networking.interfaces.<name>.ipv{4,6}.addresses'')
          (mkMergedOptionModule
            [
              [ "ipAddress" ]
              [ "prefixLength" ]
            ]
            [ "ipv4" "addresses" ]
            (
              cfg:
              with cfg;
              optional (defined ipAddress && defined prefixLength) {
                address = ipAddress;
                prefixLength = prefixLength;
              }
            )
          )
          (mkMergedOptionModule
            [
              [ "ipv6Address" ]
              [ "ipv6PrefixLength" ]
            ]
            [ "ipv6" "addresses" ]
            (
              cfg:
              with cfg;
              optional (defined ipv6Address && defined ipv6PrefixLength) {
                address = ipv6Address;
                prefixLength = ipv6PrefixLength;
              }
            )
          )

          {
            options.assertions = options.assertions;
            options.warnings = options.warnings;
          }
        ];

      options = {
        ipv4.addresses = mkOption {
          default = [ ];

          description = ''
            List of IPv4 addresses that will be statically assigned to the interface.
          '';

          example = [
            {
              address = "10.0.0.1";
              prefixLength = 16;
            }
            {
              address = "192.168.1.1";
              prefixLength = 24;
            }
          ];

          type = with types; listOf (submodule (addrOpts 4));
        };

        ipv4.routes = mkOption {
          default = [ ];

          description = ''
            List of extra IPv4 static routes that will be assigned to the interface.

            ::: {.warning}
            If the route type is the default `unicast`, then the scope
            is set differently depending on the value of {option}`networking.useNetworkd`:
            the script-based backend sets it to `link`, while networkd sets
            it to `global`.
            :::

            If you want consistency between the two implementations,
            set the scope of the route manually with
            `networking.interfaces.eth0.ipv4.routes = [{ options.scope = "global"; }]`
            for example.
          '';

          example = [
            {
              address = "10.0.0.0";
              prefixLength = 16;
            }
            {
              address = "192.168.2.0";
              prefixLength = 24;
              via = "192.168.1.1";
            }
          ];

          type = with types; listOf (submodule (routeOpts 4));
        };

        ipv6.addresses = mkOption {
          default = [ ];

          description = ''
            List of IPv6 addresses that will be statically assigned to the interface.
          '';

          example = [
            {
              address = "fdfd:b3f0:482::1";
              prefixLength = 48;
            }
            {
              address = "2001:1470:fffd:2098::e006";
              prefixLength = 64;
            }
          ];

          type = with types; listOf (submodule (addrOpts 6));
        };

        ipv6.routes = mkOption {
          default = [ ];

          description = ''
            List of extra IPv6 static routes that will be assigned to the interface.
          '';

          example = [
            {
              address = "fdfd:b3f0::";
              prefixLength = 48;
            }
            {
              address = "2001:1470:fffd:2098::";
              prefixLength = 64;
              via = "fdfd:b3f0::1";
            }
          ];

          type = with types; listOf (submodule (routeOpts 6));
        };

        macAddress = mkOption {
          default = null;

          description = ''
            MAC address of the interface. Leave empty to use the default.
          '';

          example = "00:11:22:33:44:55";
          type = types.nullOr (types.str);
        };

        mtu = mkOption {
          default = null;

          description = ''
            MTU size for packets leaving the interface. Leave empty to use the default.
          '';

          example = 9000;
          type = types.nullOr types.int;
        };

        name = mkOption {
          description = "Name of the interface.";
          example = "eth0";
          type = types.str;
        };

        proxyARP = mkOption {
          default = false;

          description = ''
            Turn on proxy_arp for this device.
            This is mainly useful for creating pseudo-bridges between a real
            interface and a virtual network such as VPN or a virtual machine for
            interfaces that don't support real bridging (most wlan interfaces).
            As ARP proxying acts slightly above the link-layer, below-ip traffic
            isn't bridged, so things like DHCP won't work. The advantage above
            using NAT lies in the fact that no IP addresses are shared, so all
            hosts are reachable/routeable.

            WARNING: turns on ip-routing, so if you have multiple interfaces, you
            should think of the consequence and setup firewall rules to limit this.
          '';

          type = types.bool;
        };

        tempAddress = mkOption {
          default = cfg.tempAddresses;
          defaultText = literalExpression "config.networking.tempAddresses";

          description = ''
            When IPv6 is enabled with SLAAC, this option controls the use of
            temporary address (aka privacy extensions) on this
            interface. This is used to reduce tracking.

            See also the global option
            [](#opt-networking.tempAddresses), which
            applies to all interfaces where this is not set.

            Possible values are:
            ${tempaddrDoc}
          '';

          type = types.enum (lib.attrNames tempaddrValues);
        };

        useDHCP = mkOption {
          default = null;

          description = ''
            Whether this interface should be configured with DHCP. Overrides the
            default set by {option}`networking.useDHCP`. If `null` (the default),
            DHCP is enabled if the interface has no IPv4 addresses configured
            with {option}`networking.interfaces.<name>.ipv4.addresses`, and
            disabled otherwise.
          '';

          type = types.nullOr types.bool;
        };

        virtual = mkOption {
          default = false;

          description = ''
            Whether this interface is virtual and should be created by tunctl.
            This is mainly useful for creating bridges between a host and a virtual
            network such as VPN or a virtual machine.
          '';

          type = types.bool;
        };

        virtualOwner = mkOption {
          default = "root";

          description = ''
            In case of a virtual device, the user who owns it.
            `null` will not set owner, allowing access to any user.
          '';

          type = types.nullOr types.str;
        };

        virtualType = mkOption {
          default = if hasPrefix "tun" name then "tun" else "tap";
          defaultText = literalExpression ''if hasPrefix "tun" name then "tun" else "tap"'';

          description = ''
            The type of interface to create.
            The default is TUN for an interface name starting
            with "tun", otherwise TAP.
          '';

          type =
            with types;
            enum [
              "tun"
              "tap"
            ];
        };

        wakeOnLan = {
          enable = mkOption {
            default = false;
            description = "Whether to enable wol on this interface.";
            type = types.bool;
          };

          policy = mkOption {
            default = [ "magic" ];

            description = ''
              The [Wake-on-LAN policy](https://www.freedesktop.org/software/systemd/man/systemd.link.html#WakeOnLan=)
              to set for the device.

              The options are
              - `phy`: Wake on PHY activity
              - `unicast`: Wake on unicast messages
              - `multicast`: Wake on multicast messages
              - `broadcast`: Wake on broadcast messages
              - `arp`: Wake on ARP
              - `magic`: Wake on receipt of a magic packet
            '';

            type =
              with types;
              listOf (enum [
                "phy"
                "unicast"
                "multicast"
                "broadcast"
                "arp"
                "magic"
                "secureon"
              ]);
          };
        };
      };

      config = {
        name = mkDefault name;
      };

    };

  vswitchInterfaceOpts =
    { name, ... }:
    {

      options = {

        name = mkOption {
          description = "Name of the interface";
          example = "eth0";
          type = types.str;
        };

        type = mkOption {
          default = null;
          description = "Openvswitch type to assign to interface";
          example = "internal";
          type = types.nullOr types.str;
        };

        vlan = mkOption {
          default = null;
          description = "Vlan tag to apply to interface";
          example = 10;
          type = types.nullOr types.int;
        };
      };
    };

  hexChars = stringToCharacters "0123456789abcdef";

  isHexString = s: all (c: elem c hexChars) (stringToCharacters (toLower s));

  tempaddrValues = {
    default = {
      description = "generate IPv6 temporary addresses and use these as source addresses in routing";
      sysctl = "2";
    };

    disabled = {
      description = "completely disable IPv6 temporary addresses";
      sysctl = "0";
    };

    enabled = {
      description = "generate IPv6 temporary addresses but still use EUI-64 addresses as source addresses";
      sysctl = "1";
    };
  };
  tempaddrDoc = concatStringsSep "\n" (
    mapAttrsToList (name: { description, ... }: ''- `"${name}"` to ${description};'') tempaddrValues
  );

  hostidFile = pkgs.runCommand "gen-hostid" { preferLocalBuild = true; } ''
    hi="${cfg.hostId}"
    ${
      if pkgs.stdenv.hostPlatform.isBigEndian then
        ''
          echo -ne "\x''${hi:0:2}\x''${hi:2:2}\x''${hi:4:2}\x''${hi:6:2}" > $out
        ''
      else
        ''
          echo -ne "\x''${hi:6:2}\x''${hi:4:2}\x''${hi:2:2}\x''${hi:0:2}" > $out
        ''
    }
  '';

in

{

  ###### interface
  options = {

    networking.bonds =
      let
        driverOptionsExample = ''
          {
            miimon = "100";
            mode = "active-backup";
          }
        '';
      in
      mkOption {
        default = { };

        description = ''
          This option allows you to define bond devices that aggregate multiple,
          underlying networking interfaces together. The value of this option is
          an attribute set. Each attribute specifies a bond, with the attribute
          name specifying the name of the bond's network interface
        '';

        example = literalExpression ''
          {
            bond0 = {
              interfaces = [ "eth0" "wlan0" ];
              driverOptions = ${driverOptionsExample};
            };
            anotherBond.interfaces = [ "enp4s0f0" "enp4s0f1" "enp5s0f0" "enp5s0f1" ];
          }
        '';

        type =
          with types;
          attrsOf (submodule {

            options = {

              driverOptions = mkOption {
                default = { };

                description = ''
                  Options for the bonding driver.
                  Documentation can be found in
                  <https://www.kernel.org/doc/Documentation/networking/bonding.txt>
                '';

                example = literalExpression driverOptionsExample;
                type = types.attrsOf types.str;

              };

              interfaces = mkOption {
                description = "The interfaces to bond together";

                example = [
                  "enp4s0f0"
                  "enp4s0f1"
                  "wlan0"
                ];

                type = types.listOf types.str;
              };

              lacp_rate = mkOption {
                default = null;

                description = ''
                  DEPRECATED, use `driverOptions`.
                  Option specifying the rate in which we'll ask our link partner
                  to transmit LACPDU packets in 802.3ad mode.
                '';

                example = "fast";
                type = types.nullOr types.str;
              };

              miimon = mkOption {
                default = null;

                description = ''
                  DEPRECATED, use `driverOptions`.
                  Miimon is the number of millisecond in between each round of polling
                  by the device driver for failed links. By default polling is not
                  enabled and the driver is trusted to properly detect and handle
                  failure scenarios.
                '';

                example = 100;
                type = types.nullOr types.int;
              };

              mode = mkOption {
                default = null;

                description = ''
                  DEPRECATED, use `driverOptions`.
                  The mode which the bond will be running. The default mode for
                  the bonding driver is balance-rr, optimizing for throughput.
                  More information about valid modes can be found at
                  https://www.kernel.org/doc/Documentation/networking/bonding.txt
                '';

                example = "active-backup";
                type = types.nullOr types.str;
              };

              xmit_hash_policy = mkOption {
                default = null;

                description = ''
                  DEPRECATED, use `driverOptions`.
                  Selects the transmit hash policy to use for slave selection in
                  balance-xor, 802.3ad, and tlb modes.
                '';

                example = "layer2+3";
                type = types.nullOr types.str;
              };

            };

          });
      };

    networking.bridges = mkOption {
      default = { };

      description = ''
        This option allows you to define Ethernet bridge devices
        that connect physical networks together.  The value of this
        option is an attribute set.  Each attribute specifies a
        bridge, with the attribute name specifying the name of the
        bridge's network interface.
      '';

      example = {
        br0.interfaces = [
          "eth0"
          "eth1"
        ];

        br1.interfaces = [
          "eth2"
          "wlan0"
        ];
      };

      type =
        with types;
        attrsOf (submodule {

          options = {

            interfaces = mkOption {
              description = "The physical network interfaces connected by the bridge.";

              example = [
                "eth0"
                "eth1"
              ];

              type = types.listOf types.str;
            };

            rstp = mkOption {
              default = false;
              description = "Whether the bridge interface should enable rstp.";
              type = types.bool;
            };

          };

        });

    };

    networking.defaultGateway = mkOption {
      default = null;

      description = ''
        The default gateway. It can be left empty if it is auto-detected through DHCP.
        It can be specified as a string or an option set along with a network interface.
      '';

      example = {
        address = "131.211.84.1";
        interface = "enp3s0";
        source = "131.211.84.2";
      };

      type = types.nullOr (types.coercedTo types.str gatewayCoerce (types.submodule gatewayOpts));
    };

    networking.defaultGateway6 = mkOption {
      default = null;

      description = ''
        The default ipv6 gateway. It can be left empty if it is auto-detected through DHCP.
        It can be specified as a string or an option set along with a network interface.
      '';

      example = {
        address = "2001:4d0:1e04:895::1";
        interface = "enp3s0";
        source = "2001:4d0:1e04:895::2";
      };

      type = types.nullOr (types.coercedTo types.str gatewayCoerce (types.submodule gatewayOpts));
    };

    networking.defaultGatewayWindowSize = mkOption {
      default = null;

      description = ''
        The window size of the default gateway. It limits maximal data bursts that TCP peers
        are allowed to send to us.
      '';

      example = 524288;
      type = types.nullOr types.int;
    };

    networking.domain = mkOption {
      default = null;

      description = ''
        The system domain name. Used to populate the {option}`fqdn` value.

        ::: {.warning}
        The domain name is not configured for DNS resolution purposes, see {option}`search` instead.
        :::
      '';

      example = "home.arpa";
      type = types.nullOr types.str;
    };

    networking.enableIPv6 = mkOption {
      default = true;

      description = ''
        Whether to enable support for IPv6.
      '';

      type = types.bool;
    };

    networking.fooOverUDP = mkOption {
      default = { };

      description = ''
        This option allows you to configure Foo Over UDP and Generic UDP Encapsulation
        endpoints. See {manpage}`ip-fou(8)` for details.
      '';

      example = {
        backup = {
          port = 9002;
        };

        primary = {
          local = {
            address = "192.0.2.1";
            dev = "eth0";
          };

          port = 9001;
        };
      };

      type =
        with types;
        attrsOf (submodule {
          options = {
            local = mkOption {
              default = null;

              description = ''
                Local address (and optionally device) to bind to using the given port.
              '';

              example = {
                address = "203.0.113.22";
              };

              type = nullOr (submodule {
                options = {
                  address = mkOption {
                    description = ''
                      Local address to bind to. The address must be available when the FOU
                      endpoint is created, using the scripted network setup this can be achieved
                      either by setting `dev` or adding dependency information to
                      `systemd.services.<name>-fou-encap`; it isn't supported
                      when using networkd.
                    '';

                    type = types.str;
                  };

                  dev = mkOption {
                    default = null;

                    description = ''
                      Network device to bind to.
                    '';

                    example = "eth0";
                    type = nullOr str;
                  };
                };
              });
            };

            port = mkOption {
              description = ''
                Local port of the encapsulation UDP socket.
              '';

              type = port;
            };

            protocol = mkOption {
              default = null;

              description = ''
                Protocol number of the encapsulated packets. Specifying `null`
                (the default) creates a GUE endpoint, specifying a protocol number will create
                a FOU endpoint.
              '';

              type = nullOr (ints.between 1 255);
            };
          };
        });
    };

    networking.fqdn = mkOption {
      default =
        if (cfg.hostName != "" && cfg.domain != null) then
          "${cfg.hostName}.${cfg.domain}"
        else
          throw ''
            The FQDN is required but cannot be determined from `networking.hostName`
            and `networking.domain`. Please ensure these options are set properly or
            set `networking.fqdn` directly.
          '';

      defaultText = literalExpression ''"''${networking.hostName}.''${networking.domain}"'';

      description = ''
        The fully qualified domain name (FQDN) of this host. By default, it is
        the result of combining `networking.hostName` and `networking.domain.`

        Using this option will result in an evaluation error if the hostname is empty or
        no domain is specified.

        Modules that accept a mere `networking.hostName` but prefer a fully qualified
        domain name may use `networking.fqdnOrHostName` instead.
      '';

      type = types.str;
    };

    networking.fqdnOrHostName = mkOption {
      default =
        if (cfg.domain != null || opt.fqdn.highestPrio < (mkOptionDefault { }).priority) then
          cfg.fqdn
        else
          cfg.hostName;

      defaultText = literalExpression ''
        if config.networking.domain != null || config.networking.fqdn is set then config.networking.fqdn else config.networking.hostName
      '';

      description = ''
        Either the fully qualified domain name (FQDN), or just the host name if
        it does not exist.

        This is a convenience option for modules to read instead of `fqdn` when
        a mere `hostName` is also an acceptable value; this option does not
        throw an error when `domain` or `fqdn` is unset.
      '';

      readOnly = true;
      type = types.str;
    };

    networking.greTunnels = mkOption {
      default = { };

      description = ''
        This option allows you to define Generic Routing Encapsulation (GRE) tunnels.
      '';

      example = literalExpression ''
        {
          greBridge = {
            remote = "10.0.0.1";
            local = "10.0.0.22";
            dev = "enp4s0f0";
            type = "tap";
            ttl = 255;
          };
          gre6Tunnel = {
            remote = "fd7a:5634::1";
            local = "fd7a:5634::2";
            dev = "enp4s0f0";
            type = "tun6";
            ttl = 255;
          };
        }
      '';

      type =
        with types;
        attrsOf (submodule {
          options = {

            dev = mkOption {
              default = null;

              description = ''
                The underlying network device on which the tunnel resides.
              '';

              example = "enp4s0f0";
              type = types.nullOr types.str;
            };

            local = mkOption {
              default = null;

              description = ''
                The address of the local endpoint which the remote
                side should send packets to.
              '';

              example = "10.0.0.22";
              type = types.nullOr types.str;
            };

            remote = mkOption {
              default = null;

              description = ''
                The address of the remote endpoint to forward traffic over.
              '';

              example = "10.0.0.1";
              type = types.nullOr types.str;
            };

            ttl = mkOption {
              default = null;

              description = ''
                The time-to-live/hoplimit of the connection to the remote tunnel endpoint.
              '';

              example = 255;
              type = types.nullOr types.int;
            };

            type = mkOption {
              apply =
                v:
                {
                  tap = "gretap";
                  tap6 = "ip6gretap";
                  tun = "gre";
                  tun6 = "ip6gre";
                }
                .${v};

              default = "tap";

              description = ''
                Whether the tunnel routes layer 2 (tap) or layer 3 (tun) traffic.
              '';

              example = "tap";

              type =
                with types;
                enum [
                  "tun"
                  "tap"
                  "tun6"
                  "tap6"
                ];
            };
          };
        });
    };

    networking.hostId = mkOption {
      default = null;

      description = ''
        The 32-bit host ID of the machine, formatted as 8 hexadecimal characters.

        You should try to make this ID unique among your machines. You can
        generate a random 32-bit ID using the following commands:

        `head -c 8 /etc/machine-id`

        (this derives it from the machine-id that systemd generates) or

        `head -c4 /dev/urandom | od -A none -t x4`

        The primary use case is to ensure when using ZFS that a pool isn't imported
        accidentally on a wrong machine.
      '';

      example = "4e98920d";
      type = types.nullOr types.str;
    };

    networking.hostName = mkOption {
      default = config.system.nixos.distroId;
      defaultText = literalExpression "config.system.nixos.distroId";

      description = ''
        The name of the machine. Leave it empty if you want to obtain it from a
        DHCP server (if using DHCP). The hostname must be a valid DNS label (see
        RFC 1035 section 2.3.1: "Preferred name syntax", RFC 1123 section 2.1:
        "Host Names and Numbers") and as such must not contain the domain part.
        This means that the hostname must start with a letter or digit,
        end with a letter or digit, and have as interior characters only
        letters, digits, and hyphen. The maximum length is 63 characters.
        Additionally it is recommended to only use lower-case characters.
        If (e.g. for legacy reasons) a FQDN is required as the Linux kernel
        network node hostname (uname --nodename) the option
        boot.kernel.sysctl."kernel.hostname" can be used as a workaround (but
        the 64 character limit still applies).

        WARNING: Do not use underscores (_) or you may run into unexpected issues.
      '';

      # Only allow hostnames without the domain name part (i.e. no FQDNs, see
      # e.g. "man 5 hostname") and require valid DNS labels (recommended
      # syntax). Note: We also allow underscores for compatibility/legacy
      # reasons (as undocumented feature):
      type = types.strMatching "^$|^[[:alnum:]]([[:alnum:]_-]{0,61}[[:alnum:]])?$";
      # warning until the issues in https://github.com/NixOS/nixpkgs/pull/138978
      # are resolved
    };

    networking.interfaces = mkOption {
      default = { };

      description = ''
        The configuration for each network interface.

        Please note that {option}`systemd.network.netdevs` has more features
        and is better maintained. When building new things, it is advised to
        use that instead.
      '';

      example = {
        eth0.ipv4.addresses = [
          {
            address = "131.211.84.78";
            prefixLength = 25;
          }
        ];
      };

      type = with types; attrsOf (submodule interfaceOpts);
    };

    networking.ipips = mkOption {
      default = { };

      description = ''
        This option allows you to define interfaces encapsulating IP
        packets within IP packets; which should be automatically created.

        For example, this allows you to create 4in6 (RFC 2473)
        or IP within IP (RFC 2003) tunnels.
      '';

      example = literalExpression ''
        {
          wan4in6 = {
            remote = "2001:db8::1";
            local = "2001:db8::3";
            dev = "wan6";
            encapsulation.type = "4in6";
            encapsulation.limit = 0;
          };
        }
      '';

      type =
        with types;
        attrsOf (submodule {
          options = {

            dev = mkOption {
              default = null;

              description = ''
                The underlying network device on which the tunnel resides.
              '';

              example = "wan6";
              type = types.nullOr types.str;
            };

            encapsulation.limit = mkOption {
              default = 4;

              description = ''
                For an IPv6-based tunnel, the maximum number of nested
                encapsulation to allow. 0 means no nesting, "none" unlimited.
              '';

              example = "none";
              type = types.either (types.enum [ "none" ]) types.ints.unsigned;
            };

            encapsulation.type = mkOption {
              default = "ipip";

              description = ''
                Select the encapsulation type:

                - `ipip` to create an IPv4 within IPv4 tunnel (RFC 2003).

                - `4in6` to create a 4in6 tunnel (RFC 2473);

                - `ip6ip6` to create an IPv6 within IPv6 tunnel (RFC 2473);

                ::: {.note}
                For encapsulating IPv6 within IPv4 packets, see
                the ad-hoc {option}`networking.sits` option.
                :::
              '';

              type = types.enum [
                "ipip"
                "4in6"
                "ip6ip6"
              ];
            };

            local = mkOption {
              description = ''
                The address of the local endpoint which the remote
                side should send packets to.
              '';

              example = "2001:db8::3";
              type = types.str;
            };

            remote = mkOption {
              description = ''
                The address of the remote endpoint to forward traffic over.
              '';

              example = "2001:db8::1";
              type = types.str;
            };

            ttl = mkOption {
              default = null;

              description = ''
                The time-to-live of the connection to the remote tunnel endpoint.
              '';

              example = 255;
              type = types.nullOr types.int;
            };

          };

        });
    };

    networking.ipvlans = mkOption {
      default = { };

      description = ''
        This option allows you to define ipvlan interfaces which should
        be automatically created.
      '';

      example = literalExpression ''
        {
          wan = {
            interface = "enp2s0";
            mode = "l2";
            flags = "vepa";
          };
        }
      '';

      type =
        with types;
        attrsOf (submodule {
          options = {

            flags = mkOption {
              default = null;
              description = "The flags of the ipvlan device.";
              example = "vepa";
              type = types.nullOr types.str;
            };

            interface = mkOption {
              description = "The interface the ipvlan will transmit packets through.";
              example = "enp4s0";
              type = types.str;
            };

            mode = mkOption {
              default = "l2";
              description = "The mode of the interface.";

              type = types.enum [
                "l2"
                "l3"
                "l3s"
              ];
            };

          };

        });
    };

    networking.localCommands = mkOption {
      default = "";

      description = ''
        Shell commands to be executed after all the network
        interfaces have been created, but not necessarily
        fully configured.
      '';

      example = "text=anything; echo You can put $text here.";
      type = types.lines;
    };

    networking.macvlans = mkOption {
      default = { };

      description = ''
        This option allows you to define macvlan interfaces which should
        be automatically created.
      '';

      example = literalExpression ''
        {
          wan = {
            interface = "enp2s0";
            mode = "vepa";
          };
        }
      '';

      type =
        with types;
        attrsOf (submodule {
          options = {

            interface = mkOption {
              description = "The interface the macvlan will transmit packets through.";
              example = "enp4s0";
              type = types.str;
            };

            mode = mkOption {
              default = null;
              description = "The mode of the macvlan device.";
              example = "vepa";
              type = types.nullOr types.str;
            };

          };

        });
    };

    networking.nameservers = mkOption {
      default = [ ];

      description = ''
        The list of nameservers.  It can be left empty if it is auto-detected through DHCP.
      '';

      example = [
        "130.161.158.4"
        "130.161.33.17"
      ];

      type = types.listOf types.str;
    };

    networking.search = mkOption {
      default = [ ];

      description = ''
        The list of domain search paths that are considered for resolving
        hostnames with fewer dots than configured in the `ndots` option,
        which defaults to 1 if unset.
      '';

      example = [
        "example.com"
        "home.arpa"
      ];

      type = types.listOf types.str;
    };

    networking.sits = mkOption {
      default = { };

      description = ''
        This option allows you to define interfaces encapsulating IPv6
        packets within IPv4 packets; which should be automatically created.
      '';

      example = literalExpression ''
        {
          hurricane = {
            remote = "10.0.0.1";
            local = "10.0.0.22";
            ttl = 255;
          };
          msipv6 = {
            remote = "192.168.0.1";
            dev = "enp3s0";
            ttl = 127;
          };
        }
      '';

      type =
        with types;
        attrsOf (submodule {
          options = {

            dev = mkOption {
              default = null;

              description = ''
                The underlying network device on which the tunnel resides.
              '';

              example = "enp4s0f0";
              type = types.nullOr types.str;
            };

            encapsulation = mkOption {
              apply =
                x:
                if x == null then
                  lib.warn
                    ''
                      The option networking.sits.*.encapsulation no longer accepts `null`
                      as a valid value. To fix this warning simply remove this definition.
                    ''
                    {
                      port = null;
                      sourcePort = null;
                      type = "6in4";
                    }
                else
                  x;

              default = { };

              description = ''
                Configures the type of encapsulation.
              '';

              example = {
                port = 9001;
                type = "fou";
              };

              type = types.nullOr (
                types.submodule {
                  options = {
                    port = mkOption {
                      default = null;

                      description = ''
                        Destination port when using UDP encapsulation.
                      '';

                      example = 9001;
                      type = types.nullOr types.port;
                    };

                    sourcePort = mkOption {
                      default = null;

                      description = ''
                        Source port when using UDP encapsulation.
                        Will be chosen automatically by the kernel if unset.
                      '';

                      example = 9002;
                      type = types.nullOr types.port;
                    };

                    type = mkOption {
                      default = "6in4";

                      description = ''
                        Select the encapsulation type:

                        - `6in4`: the IPv6 packets are encapsulated using the
                          6in4 protocol (formerly known as SIT, RFC 4213);

                        - `gue`: the IPv6 packets are encapsulated in UDP packets
                           using the Generic UDP Encapsulation (GUE) scheme;

                        - `foo`: the IPv6 packets are encapsulated in UDP packets
                           using the Foo over UDP (FOU) scheme.
                      '';

                      type = types.enum [
                        "6in4"
                        "fou"
                        "gue"
                      ];
                    };
                  };
                }
              );
            };

            local = mkOption {
              default = null;

              description = ''
                The address of the local endpoint which the remote
                side should send packets to.
              '';

              example = "10.0.0.22";
              type = types.nullOr types.str;
            };

            remote = mkOption {
              default = null;

              description = ''
                The address of the remote endpoint to forward traffic over.
              '';

              example = "10.0.0.1";
              type = types.nullOr types.str;
            };

            ttl = mkOption {
              default = null;

              description = ''
                The time-to-live of the connection to the remote tunnel endpoint.
              '';

              example = 255;
              type = types.nullOr types.int;
            };

          };

        });
    };

    networking.tempAddresses = mkOption {
      default = if cfg.enableIPv6 then "default" else "disabled";

      defaultText = literalExpression ''
        if ''${config.${opt.enableIPv6}} then "default" else "disabled"
      '';

      description = ''
        Whether to enable IPv6 Privacy Extensions for interfaces not
        configured explicitly in
        [](#opt-networking.interfaces._name_.tempAddress).

        This sets the ipv6.conf.*.use_tempaddr sysctl for all
        interfaces. Possible values are:

        ${tempaddrDoc}
      '';

      type = types.enum (lib.attrNames tempaddrValues);
    };

    networking.useDHCP = mkOption {
      default = true;

      description = ''
        Whether to use DHCP to obtain an IP address and other
        configuration for all network interfaces that do not have any manually
        configured IPv4 addresses.
      '';

      type = types.bool;
    };

    networking.useHostResolvConf = mkOption {
      default = false;

      description = ''
        In containers, whether to use the
        {file}`resolv.conf` supplied by the host.
      '';

      type = types.bool;
    };

    networking.useNetworkd = mkOption {
      default = false;

      description = ''
        Whether we should use networkd as the network configuration backend or
        the legacy script based system.
      '';

      type = types.bool;
    };

    networking.vlans = mkOption {
      default = { };

      description = ''
        This option allows you to define vlan devices that tag packets
        on top of a physical interface. The value of this option is an
        attribute set. Each attribute specifies a vlan, with the name
        specifying the name of the vlan interface.
      '';

      example = literalExpression ''
        {
          vlan0 = {
            id = 3;
            interface = "enp3s0";
          };
          vlan1 = {
            id = 1;
            interface = "wlan0";
          };
        }
      '';

      type =
        with types;
        attrsOf (submodule {

          options = {

            id = mkOption {
              description = "The vlan identifier";
              example = 1;
              type = types.int;
            };

            interface = mkOption {
              description = "The interface the vlan will transmit packets through.";
              example = "enp4s0";
              type = types.str;
            };

          };

        });

    };

    networking.vswitches = mkOption {
      default = { };

      description = ''
        This option allows you to define Open vSwitches that connect
        physical networks together. The value of this option is an
        attribute set. Each attribute specifies a vswitch, with the
        attribute name specifying the name of the vswitch's network
        interface.
      '';

      example = {
        vs0.interfaces = {
          eth0 = { };

          lo1 = {
            type = "internal";
          };
        };

        vs1.interfaces = [
          { name = "eth2"; }
          {
            name = "lo2";
            type = "internal";
          }
        ];
      };

      type =
        with types;
        attrsOf (submodule {

          options = {

            controllers = mkOption {
              default = [ ];

              description = ''
                Specify the controller targets. For the allowed options see `man 8 ovs-vsctl`.
              '';

              example = [ "ptcp:6653:[::1]" ];
              type = types.listOf types.str;
            };

            extraOvsctlCmds = mkOption {
              default = "";

              description = ''
                Commands to manipulate the Open vSwitch database. Every line executed with `ovs-vsctl`.
                All commands are bundled together with the operations for adding the interfaces
                into one atomic operation.
              '';

              example = ''
                set-fail-mode <switch_name> secure
                set Bridge <switch_name> stp_enable=true
              '';

              type = types.lines;
            };

            interfaces = mkOption {
              description = "The physical network interfaces connected by the vSwitch.";
              type = with types; attrsOf (submodule vswitchInterfaceOpts);
            };

            openFlowRules = mkOption {
              default = "";

              description = ''
                OpenFlow rules to insert into the Open vSwitch. All `openFlowRules` are
                loaded with `ovs-ofctl` within one atomic operation.
              '';

              example = ''
                actions=normal
              '';

              type = types.lines;
            };

            # TODO: use same type as elements from supportedOpenFlowVersions
            openFlowVersion = mkOption {
              default = "OpenFlow13";

              description = ''
                Version of OpenFlow protocol to use when communicating with the switch internally (e.g. with `openFlowRules`).
              '';

              type = types.str;
            };

            # TODO: custom "openflow version" type, with list from existing openflow protocols
            supportedOpenFlowVersions = mkOption {
              default = [ "OpenFlow13" ];

              description = ''
                Supported versions to enable on this switch.
              '';

              example = [
                "OpenFlow10"
                "OpenFlow13"
                "OpenFlow14"
              ];

              type = types.listOf types.str;
            };

          };

        });

    };

    networking.wlanInterfaces = mkOption {
      default = { };

      description = ''
        Creating multiple WLAN interfaces on top of one physical WLAN device (NIC).

        The name of the WLAN interface corresponds to the name of the attribute.
        A NIC is referenced by the persistent device name of the WLAN interface that
        `udev` assigns to a NIC by default.
        If a NIC supports multiple WLAN interfaces, then the one NIC can be used as
        `device` for multiple WLAN interfaces.
        If a NIC is used for creating WLAN interfaces, then the default WLAN interface
        with a persistent device name form `udev` is not created.
        A WLAN interface with the persistent name assigned from `udev`
        would have to be created explicitly.
      '';

      example = literalExpression ''
        {
          wlan-station0 = {
              device = "wlp6s0";
          };
          wlan-adhoc0 = {
              type = "ibss";
              device = "wlp6s0";
              mac = "02:00:00:00:00:01";
          };
          wlan-p2p0 = {
              device = "wlp6s0";
              mac = "02:00:00:00:00:02";
          };
          wlan-ap0 = {
              device = "wlp6s0";
              mac = "02:00:00:00:00:03";
          };
        }
      '';

      type =
        with types;
        attrsOf (submodule {

          options = {

            device = mkOption {
              description = "The name of the underlying hardware WLAN device as assigned by `udev`.";
              example = "wlp6s0";
              type = types.str;
            };

            flags = mkOption {
              default = null;

              description = ''
                Flags for interface of type `monitor`.
              '';

              example = "control";

              type =
                with types;
                nullOr (enum [
                  "none"
                  "fcsfail"
                  "control"
                  "otherbss"
                  "cook"
                  "active"
                ]);
            };

            fourAddr = mkOption {
              default = null;
              description = "Whether to enable `4-address mode` with type `managed`.";
              type = types.nullOr types.bool;
            };

            mac = mkOption {
              default = null;

              description = ''
                MAC address to use for the device. If `null`, then the MAC of the
                underlying hardware WLAN device is used.

                INFO: Locally administered MAC addresses are of the form:
                - x2:xx:xx:xx:xx:xx
                - x6:xx:xx:xx:xx:xx
                - xA:xx:xx:xx:xx:xx
                - xE:xx:xx:xx:xx:xx
              '';

              example = "02:00:00:00:00:01";
              type = types.nullOr types.str;
            };

            meshID = mkOption {
              default = null;
              description = "MeshID of interface with type `mesh`.";
              type = types.nullOr types.str;
            };

            type = mkOption {
              default = "managed";

              description = ''
                The type of the WLAN interface.
                The type has to be supported by the underlying hardware of the device.
              '';

              example = "ibss";

              type = types.enum [
                "managed"
                "ibss"
                "monitor"
                "mesh"
                "wds"
              ];
            };

          };

        });

    };

  };

  config = {

    assertions =
      (forEach interfaces (i: {
        # With the linux kernel, interface name length is limited by IFNAMSIZ
        # to 16 bytes, including the trailing null byte.
        # See include/linux/if.h in the kernel sources
        assertion = stringLength i.name < 16;

        message = ''
          The name of networking.interfaces."${i.name}" is too long, it needs to be less than 16 characters.
        '';
      }))
      ++ (forEach slaveIfs (i: {
        assertion = i.ipv4.addresses == [ ] && i.ipv6.addresses == [ ];

        message = ''
          The networking.interfaces."${i.name}" must not have any defined ips when it is a slave.
        '';
      }))
      ++ (forEach interfaces (i: {
        assertion = i.tempAddress != "disabled" -> cfg.enableIPv6;

        message = ''
          Temporary addresses are only needed when IPv6 is enabled.
        '';
      }))
      ++ (forEach interfaces (i: {
        assertion = (i.virtual && i.virtualType == "tun") -> i.macAddress == null;

        message = ''
          Setting a MAC Address for tun device ${i.name} isn't supported.
        '';
      }))
      ++ [
        {
          assertion = cfg.hostId == null || (stringLength cfg.hostId == 8 && isHexString cfg.hostId);
          message = "Invalid value given to the networking.hostId option.";
        }
      ];

    boot.extraModprobeConfig =
      # This setting is intentional as it prevents default bond devices
      # from being created.
      optionalString hasBonds "options bonding max_bonds=0";

    boot.initrd.systemd.contents."/etc/hostid" = mkIf (cfg.hostId != null) { source = hostidFile; };

    boot.kernel.sysctl = {
      # Only set when proxyARP needs it; never write =0 (the kernel default),
      # which would race with systemd-networkd's IPv4Forwarding= on switch.
      "net.ipv4.conf.all.forwarding" = mkIf (any (i: i.proxyARP) interfaces) (mkDefault true);
      # allow all users to do ICMP echo requests (ping)
      "net.ipv4.ping_group_range" = mkDefault "0 2147483647";
      "net.ipv6.conf.all.disable_ipv6" = mkDefault (!cfg.enableIPv6);
      "net.ipv6.conf.default.disable_ipv6" = mkDefault (!cfg.enableIPv6);
      # networkmanager falls back to "/proc/sys/net/ipv6/conf/default/use_tempaddr"
      "net.ipv6.conf.default.use_tempaddr" = tempaddrValues.${cfg.tempAddresses}.sysctl;
    }
    // listToAttrs (
      forEach interfaces (
        i: nameValuePair "net.ipv4.conf.${replaceStrings [ "." ] [ "/" ] i.name}.proxy_arp" i.proxyARP
      )
    )
    // listToAttrs (
      forEach interfaces (
        i:
        let
          opt = i.tempAddress;
          val = tempaddrValues.${opt}.sysctl;
        in
        nameValuePair "net.ipv6.conf.${replaceStrings [ "." ] [ "/" ] i.name}.use_tempaddr" val
      )
    );

    boot.kernelModules =
      [ ]
      ++ optional hasVirtuals "tun"
      ++ optional hasSits "sit"
      ++ optional hasGres "gre"
      ++ optional hasBonds "bonding"
      ++ optional hasFous "fou";

    environment.corePackages = [
      pkgs.host
      pkgs.hostname
      pkgs.iproute2
      pkgs.iputils # ping
    ]
    ++ bridgeStp;

    environment.etc.hostid = mkIf (cfg.hostId != null) { source = hostidFile; };

    # static hostname configuration needed for hostnamectl and the
    # org.freedesktop.hostname1 dbus service (both provided by systemd)
    environment.etc.hostname = mkIf (cfg.hostName != "") {
      text = cfg.hostName + "\n";
    };

    networking.localCommands = lib.mkIf config.networking.resolvconf.enable ''
      # Set the static DNS configuration, if given.
      ${pkgs.openresolv}/sbin/resolvconf -m 1 -a static <<EOF
      ${optionalString (cfg.nameservers != [ ] && cfg.domain != null) ''
        domain ${cfg.domain}
      ''}
      ${optionalString (cfg.search != [ ]) ("search " + concatStringsSep " " cfg.search)}
      ${flip concatMapStrings cfg.nameservers (ns: ''
        nameserver ${ns}
      '')}
      EOF
    '';

    services.mstpd = mkIf needsMstpd { enable = true; };

    services.udev.packages =
      lib.optionals (!config.systemd.network.enable) [
        (pkgs.writeTextFile rec {
          destination = "/etc/udev/rules.d/98-${name}";
          name = "ipv6-privacy-extensions.rules";

          text =
            let
              sysctl-value = tempaddrValues.${cfg.tempAddresses}.sysctl;
            in
            ''
              # enable and prefer IPv6 privacy addresses by default
              ACTION=="add", SUBSYSTEM=="net", RUN+="${pkgs.bash}/bin/sh -c 'echo ${sysctl-value} > /proc/sys/net/ipv6/conf/$name/use_tempaddr'"
            '';
        })
        (pkgs.writeTextFile rec {
          destination = "/etc/udev/rules.d/99-${name}";
          name = "ipv6-privacy-extensions.rules";

          text = concatMapStrings (
            i:
            let
              opt = i.tempAddress;
              val = tempaddrValues.${opt}.sysctl;
              msg = tempaddrValues.${opt}.description;
            in
            ''
              # override to ${msg} for ${i.name}
              ACTION=="add", SUBSYSTEM=="net", NAME=="${i.name}", RUN+="${pkgs.procps}/bin/sysctl net.ipv6.conf.${
                replaceStrings [ "." ] [ "/" ] i.name
              }.use_tempaddr=${val}"
            ''
          ) (filter (i: i.tempAddress != cfg.tempAddresses) interfaces);
        })
      ]
      ++ lib.optional (cfg.wlanInterfaces != { }) (
        pkgs.writeTextFile {
          destination = "/etc/udev/rules.d/99-zzz-40-wlanInterfaces.rules";
          name = "99-zzz-40-wlanInterfaces.rules";

          text =
            let
              # Collect all interfaces that are defined for a device
              # as device:interface key:value pairs.
              wlanDeviceInterfaces =
                let
                  allDevices = unique (mapAttrsToList (_: v: v.device) cfg.wlanInterfaces);
                  interfacesOfDevice = d: filterAttrs (_: v: v.device == d) cfg.wlanInterfaces;
                in
                genAttrs allDevices (d: interfacesOfDevice d);

              # Convert device:interface key:value pairs into a list, and if it exists,
              # place the interface which is named after the device at the beginning.
              wlanListDeviceFirst =
                device: interfaces:
                if hasAttr device interfaces then
                  mapAttrsToList (n: v: v // { _iName = n; }) (filterAttrs (n: _: n == device) interfaces)
                  ++ mapAttrsToList (n: v: v // { _iName = n; }) (filterAttrs (n: _: n != device) interfaces)
                else
                  mapAttrsToList (n: v: v // { _iName = n; }) interfaces;

              # Udev script to execute for the default WLAN interface with the persistend udev name.
              # The script creates the required, new WLAN interfaces interfaces and configures the
              # existing, default interface.
              curInterfaceScript =
                device: current: new:
                pkgs.writeScript "udev-run-script-wlan-interfaces-${device}.sh" ''
                  #!${pkgs.runtimeShell}
                  # Change the wireless phy device to a predictable name.
                  ${pkgs.iw}/bin/iw phy `${pkgs.coreutils}/bin/cat /sys/class/net/$INTERFACE/phy80211/name` set name ${device}

                  # Add new WLAN interfaces
                  ${flip concatMapStrings new (i: ''
                    ${pkgs.iw}/bin/iw phy ${device} interface add ${i._iName} type managed
                  '')}

                  # Configure the current interface
                  ${pkgs.iw}/bin/iw dev ${device} set type ${current.type}
                  ${optionalString (
                    current.type == "mesh" && current.meshID != null
                  ) "${pkgs.iw}/bin/iw dev ${device} set meshid ${current.meshID}"}
                  ${optionalString (
                    current.type == "monitor" && current.flags != null
                  ) "${pkgs.iw}/bin/iw dev ${device} set monitor ${current.flags}"}
                  ${optionalString (
                    current.type == "managed" && current.fourAddr != null
                  ) "${pkgs.iw}/bin/iw dev ${device} set 4addr ${if current.fourAddr then "on" else "off"}"}
                  ${optionalString (
                    current.mac != null
                  ) "${pkgs.iproute2}/bin/ip link set dev ${device} address ${current.mac}"}
                '';

              # Udev script to execute for a new WLAN interface. The script configures the new WLAN interface.
              newInterfaceScript =
                new:
                pkgs.writeScript "udev-run-script-wlan-interfaces-${new._iName}.sh" ''
                  #!${pkgs.runtimeShell}
                  # Configure the new interface
                  ${pkgs.iw}/bin/iw dev ${new._iName} set type ${new.type}
                  ${optionalString (
                    new.type == "mesh" && new.meshID != null
                  ) "${pkgs.iw}/bin/iw dev ${new._iName} set meshid ${new.meshID}"}
                  ${optionalString (
                    new.type == "monitor" && new.flags != null
                  ) "${pkgs.iw}/bin/iw dev ${new._iName} set monitor ${new.flags}"}
                  ${optionalString (
                    new.type == "managed" && new.fourAddr != null
                  ) "${pkgs.iw}/bin/iw dev ${new._iName} set 4addr ${if new.fourAddr then "on" else "off"}"}
                  ${optionalString (
                    new.mac != null
                  ) "${pkgs.iproute2}/bin/ip link set dev ${new._iName} address ${new.mac}"}
                '';

              # Udev attributes for systemd to name the device and to create a .device target.
              systemdAttrs =
                n:
                ''NAME:="${n}", ENV{ID_NET_NAME}="${n}", ENV{SYSTEMD_ALIAS}="/sys/subsystem/net/devices/${n}", TAG+="systemd"'';
            in
            flip (concatMapStringsSep "\n") (attrNames wlanDeviceInterfaces) (
              device:
              let
                interfaces = wlanListDeviceFirst device wlanDeviceInterfaces.${device};
                curInterface = elemAt interfaces 0;
                newInterfaces = drop 1 interfaces;
              in
              ''
                # It is important to have that rule first as overwriting the NAME attribute also prevents the
                # next rules from matching.
                ${flip (concatMapStringsSep "\n") (wlanListDeviceFirst device wlanDeviceInterfaces.${device}) (
                  interface:
                  ''ACTION=="add", SUBSYSTEM=="net", ENV{DEVTYPE}=="wlan", ENV{INTERFACE}=="${interface._iName}", ${systemdAttrs interface._iName}, RUN+="${newInterfaceScript interface}"''
                )}

                # Add the required, new WLAN interfaces to the default WLAN interface with the
                # persistent, default name as assigned by udev.
                ACTION=="add", SUBSYSTEM=="net", ENV{DEVTYPE}=="wlan", NAME=="${device}", ${systemdAttrs curInterface._iName}, RUN+="${
                  curInterfaceScript device curInterface newInterfaces
                }"
                # Generate the same systemd events for both 'add' and 'move' udev events.
                ACTION=="move", SUBSYSTEM=="net", ENV{DEVTYPE}=="wlan", NAME=="${device}", ${systemdAttrs curInterface._iName}
              ''
            );
        }
      );

    # Wake-on-LAN configuration is shared by the scripted and networkd backends.
    systemd.network.links = pipe interfaces [
      (filter (i: i.wakeOnLan.enable))
      (map (
        i:
        nameValuePair "40-${i.name}" {
          linkConfig.WakeOnLan = concatStringsSep " " i.wakeOnLan.policy;
          matchConfig.OriginalName = i.name;
        }
      ))
      listToAttrs
    ];

    systemd.services = {
      network-local-commands = {
        enable = (cfg.localCommands != "");
        after = [ "network-pre.target" ];
        before = [ "network.target" ];
        description = "Extra networking commands.";
        path = [ pkgs.iproute2 ];

        script = ''
          # Run any user-specified commands.
          ${cfg.localCommands}
        '';

        serviceConfig.RemainAfterExit = true;
        serviceConfig.Type = "oneshot";
        unitConfig.ConditionCapability = "CAP_NET_ADMIN";
        wantedBy = [ "network.target" ];
      };
    };

    virtualisation.vswitch = mkIf (cfg.vswitches != { }) { enable = true; };

    warnings =
      (concatMap (i: i.warnings) interfaces)
      ++ (lib.optional (config.systemd.network.enable && cfg.useDHCP && !cfg.useNetworkd) ''
        The combination of `systemd.network.enable = true`, `networking.useDHCP = true` and `networking.useNetworkd = false` can cause both networkd and dhcpcd to manage the same interfaces. This can lead to loss of networking. It is recommended you choose only one of networkd (by also enabling `networking.useNetworkd`) or scripting (by disabling `systemd.network.enable`)
      '');
  };

  ###### implementation
  meta.maintainers = with lib.maintainers; [ rnhmjoj ];

}
