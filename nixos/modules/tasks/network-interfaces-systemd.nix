{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

with utils;
with lib;

let

  cfg = config.networking;
  interfaces = attrValues cfg.interfaces;

  interfaceIps = i: i.ipv4.addresses ++ optionals cfg.enableIPv6 i.ipv6.addresses;

  interfaceRoutes = i: i.ipv4.routes ++ optionals cfg.enableIPv6 i.ipv6.routes;

  dhcpStr = useDHCP: boolToYesNo (useDHCP == true || useDHCP == null);

  slaves =
    concatLists (map (bond: bond.interfaces) (attrValues cfg.bonds))
    ++ concatLists (map (bridge: bridge.interfaces) (attrValues cfg.bridges))
    ++ map (sit: sit.dev) (attrValues cfg.sits)
    ++ map (ipip: ipip.dev) (attrValues cfg.ipips)
    ++ map (gre: gre.dev) (attrValues cfg.greTunnels)
    ++ map (vlan: vlan.interface) (attrValues cfg.vlans)
    # add dependency to physical or independently created vswitch member interface
    # TODO: warn the user that any address configured on those interfaces will be useless
    ++ concatMap (i: attrNames (filterAttrs (_: config: config.type != "internal") i.interfaces)) (
      attrValues cfg.vswitches
    );

  defaultGateways = mkMerge (
    forEach [ cfg.defaultGateway cfg.defaultGateway6 ] (
      gateway:
      optionalAttrs (gateway != null && gateway.interface != null) {
        networks."40-${gateway.interface}" = {
          matchConfig.Name = gateway.interface;

          routes = [
            (
              {
                Gateway = gateway.address;
              }
              // optionalAttrs (gateway.metric != null) {
                Metric = gateway.metric;
              }
              // optionalAttrs (gateway.source != null) {
                PreferredSource = gateway.source;
              }
            )
          ];
        };
      }
    )
  );

  genericDhcpNetworks = mkIf cfg.useDHCP {
    networks."99-ethernet-default-dhcp" = {
      DHCP = "yes";

      matchConfig = {
        Kind = "!*"; # physical interfaces have no kind
        Type = "ether";
      };

      networkConfig.IPv6PrivacyExtensions = "kernel";
    };

    networks."99-wireless-client-dhcp" = {
      DHCP = "yes";
      # We also set the route metric to one more than the default
      # of 1024, so that Ethernet is preferred if both are
      # available.
      dhcpV4Config.RouteMetric = 1025;
      ipv6AcceptRAConfig.RouteMetric = 1025;
      matchConfig.WLANInterfaceType = "station";
      networkConfig.IPv6PrivacyExtensions = "kernel";
    };
  };

  interfaceNetworks = mkMerge (
    forEach interfaces (i: {
      links = mkIf i.wakeOnLan.enable {
        "40-${i.name}" = {
          linkConfig.WakeOnLan = concatStringsSep " " i.wakeOnLan.policy;
          matchConfig.name = i.name;
        };
      };

      netdevs = mkIf i.virtual {
        "40-${i.name}" = {
          "${i.virtualType}Config" = optionalAttrs (i.virtualOwner != null) {
            User = i.virtualOwner;
          };

          netdevConfig = {
            Kind = i.virtualType;
            Name = i.name;
          };
        };
      };

      networks."40-${i.name}" = {
        DHCP = mkForce (
          dhcpStr (
            if i.useDHCP != null then i.useDHCP else (config.networking.useDHCP && i.ipv4.addresses == [ ])
          )
        );

        address = forEach (interfaceIps i) (ip: "${ip.address}/${toString ip.prefixLength}");

        bridgeConfig = optionalAttrs i.proxyARP {
          ProxyARP = i.proxyARP;
        };

        linkConfig =
          optionalAttrs (i.macAddress != null) {
            MACAddress = i.macAddress;
          }
          // optionalAttrs (i.mtu != null) {
            MTUBytes = toString i.mtu;
          };

        name = mkDefault i.name;
        networkConfig.IPv6PrivacyExtensions = "kernel";

        routes = forEach (interfaceRoutes i) (
          route:
          mkMerge [
            # Most of these route options have not been tested.
            # Please fix or report any mistakes you may find.
            (mkIf (route.address != null && route.prefixLength != null) {
              Destination = "${route.address}/${toString route.prefixLength}";
            })
            (mkIf (route.options ? fastopen_no_cookie) {
              FastOpenNoCookie = route.options.fastopen_no_cookie;
            })
            (mkIf (route.via != null) {
              Gateway = route.via;
            })
            (mkIf (route.type != null) {
              Type = route.type;
            })
            (mkIf (route.options ? onlink) {
              GatewayOnLink = true;
            })
            (mkIf (route.options ? initrwnd) {
              InitialAdvertisedReceiveWindow = route.options.initrwnd;
            })
            (mkIf (route.options ? initcwnd) {
              InitialCongestionWindow = route.options.initcwnd;
            })
            (mkIf (route.options ? pref) {
              IPv6Preference = route.options.pref;
            })
            (mkIf (route.options ? mtu) {
              MTUBytes = route.options.mtu;
            })
            (mkIf (route.options ? metric) {
              Metric = route.options.metric;
            })
            (mkIf (route.options ? src) {
              PreferredSource = route.options.src;
            })
            (mkIf (route.options ? protocol) {
              Protocol = route.options.protocol;
            })
            (mkIf (route.options ? quickack) {
              QuickAck = route.options.quickack;
            })
            (mkIf (route.options ? scope) {
              Scope = route.options.scope;
            })
            (mkIf (route.options ? from) {
              Source = route.options.from;
            })
            (mkIf (route.options ? table) {
              Table = route.options.table;
            })
            (mkIf (route.options ? advmss) {
              TCPAdvertisedMaximumSegmentSize = route.options.advmss;
            })
            (mkIf (route.options ? ttl-propagate) {
              TTLPropagate = route.options.ttl-propagate == "enabled";
            })
          ]
        );
      };
    })
  );

  bridgeNetworks = mkMerge (
    flip mapAttrsToList cfg.bridges (
      name: bridge: {
        netdevs."40-${name}" = {
          netdevConfig = {
            Kind = "bridge";
            Name = name;
          };
        };

        networks = listToAttrs (
          forEach bridge.interfaces (
            bi:
            nameValuePair "40-${bi}" {
              DHCP = mkOverride 0 (dhcpStr false);
              networkConfig.Bridge = name;
            }
          )
        );
      }
    )
  );

  vlanNetworks = mkMerge (
    flip mapAttrsToList cfg.vlans (
      name: vlan: {
        netdevs."40-${name}" = {
          netdevConfig = {
            Kind = "vlan";
            Name = name;
          };

          vlanConfig.Id = vlan.id;
        };

        networks."40-${vlan.interface}" = {
          vlan = [ name ];
        };
      }
    )
  );

in

{
  config = mkMerge [

    (mkIf config.boot.initrd.network.enable {
      boot.initrd.availableKernelModules =
        optional (cfg.bridges != { }) "bridge" ++ optional (cfg.vlans != { }) "8021q";

      # Note this is if initrd.network.enable, not if
      # initrd.systemd.network.enable. By setting the latter and not the
      # former, the user retains full control over the configuration.
      boot.initrd.systemd.network = mkMerge [
        defaultGateways
        genericDhcpNetworks
        interfaceNetworks
        bridgeNetworks
        vlanNetworks
      ];
    })

    (mkIf cfg.useNetworkd {

      assertions = [
        {
          assertion = cfg.defaultGatewayWindowSize == null;
          message = "networking.defaultGatewayWindowSize is not supported by networkd.";
        }
        {
          assertion = cfg.defaultGateway != null -> cfg.defaultGateway.interface != null;
          message = "networking.defaultGateway.interface is not optional when using networkd.";
        }
        {
          assertion = cfg.defaultGateway6 != null -> cfg.defaultGateway6.interface != null;
          message = "networking.defaultGateway6.interface is not optional when using networkd.";
        }
      ]
      ++ flip mapAttrsToList cfg.bridges (
        n:
        { rstp, ... }:
        {
          assertion = !rstp;
          message = "networking.bridges.${n}.rstp is not supported by networkd.";
        }
      )
      ++ flip mapAttrsToList cfg.fooOverUDP (
        n:
        { local, ... }:
        {
          assertion = local == null;
          message = "networking.fooOverUDP.${n}.local is not supported by networkd.";
        }
      );

      networking.dhcpcd.enable = mkDefault false;
      # We need to prefill the slaved devices with networking options
      # This forces the network interface creator to initialize slaves.
      networking.interfaces = listToAttrs (map (i: nameValuePair i { }) slaves);

      systemd.network = mkMerge [
        {
          enable = true;
        }
        defaultGateways
        genericDhcpNetworks
        interfaceNetworks
        bridgeNetworks
        (mkMerge (
          flip mapAttrsToList cfg.bonds (
            name: bond: {
              netdevs."40-${name}" = {
                bondConfig =
                  let
                    # manual mapping as of 2017-02-03
                    # man 5 systemd.netdev [BOND]
                    # to https://www.kernel.org/doc/Documentation/networking/bonding.txt
                    # driver options.
                    driverOptionMapping =
                      let
                        trans = f: optName: {
                          optNames = [ optName ];
                          valTransform = f;
                        };
                        simp = trans id;
                        ms = trans (v: v + "ms");
                      in
                      {
                        ARPAllTargets = simp "arp_all_targets";
                        ARPIPTargets = simp "arp_ip_target";
                        # apparently in ms for this value?! Upstream bug?
                        ARPIntervalSec = simp "arp_interval";
                        ARPValidate = simp "arp_validate";
                        AdSelect = simp "ad_select";
                        AllSlavesActive = simp "all_slaves_active";
                        DownDelaySec = ms "downdelay";
                        FailOverMACPolicy = simp "fail_over_mac";

                        GratuitousARP = {
                          optNames = [
                            "num_grat_arp"
                            "num_unsol_na"
                          ];

                          valTransform = id;
                        };

                        LACPTransmitRate = simp "lacp_rate";
                        LearnPacketIntervalSec = simp "lp_interval";
                        MIIMonitorSec = ms "miimon";
                        MinLinks = simp "min_links";
                        Mode = simp "mode";
                        PacketsPerSlave = simp "packets_per_slave";
                        PrimaryReselectPolicy = simp "primary_reselect";
                        ResendIGMP = simp "resend_igmp";
                        TransmitHashPolicy = simp "xmit_hash_policy";
                        UpDelaySec = ms "updelay";
                      };

                    do = bond.driverOptions;
                    assertNoUnknownOption =
                      let
                        knownOptions = flatten (mapAttrsToList (_: kOpts: kOpts.optNames) driverOptionMapping);
                        # options that apparently don’t exist in the networkd config
                        unknownOptions = [ "primary" ];
                        assertTrace = bool: msg: if bool then true else builtins.trace msg false;
                      in
                      assert all (
                        driverOpt:
                        assertTrace (elem driverOpt (knownOptions ++ unknownOptions))
                          "The bond.driverOption `${driverOpt}` cannot be mapped to the list of known networkd bond options. Please add it to the mapping above the assert or to `unknownOptions` should it not exist in networkd."
                      ) (attrNames do);
                      "";
                    # get those driverOptions that have been set
                    filterSystemdOptions = filterAttrs (sysDOpt: kOpts: any (kOpt: do ? ${kOpt}) kOpts.optNames);
                    # build final set of systemd options to bond values
                    buildOptionSet = mapAttrs (
                      _: kOpts:
                      with kOpts;
                      # we simply take the first set kernel bond option
                      # (one option has multiple names, which is silly)
                      head (
                        map (optN: valTransform (do.${optN}))
                          # only map those that exist
                          (filter (o: do ? ${o}) optNames)
                      )
                    );
                  in
                  seq assertNoUnknownOption (buildOptionSet (filterSystemdOptions driverOptionMapping));

                netdevConfig = {
                  Kind = "bond";
                  Name = name;
                };

              };

              networks = listToAttrs (
                forEach bond.interfaces (
                  bi:
                  nameValuePair "40-${bi}" {
                    DHCP = mkOverride 0 (dhcpStr false);
                    networkConfig.Bond = name;
                  }
                )
              );
            }
          )
        ))
        (mkMerge (
          flip mapAttrsToList cfg.macvlans (
            name: macvlan: {
              netdevs."40-${name}" = {
                macvlanConfig = optionalAttrs (macvlan.mode != null) { Mode = macvlan.mode; };

                netdevConfig = {
                  Kind = "macvlan";
                  Name = name;
                };
              };

              networks."40-${macvlan.interface}" = {
                macvlan = [ name ];
              };
            }
          )
        ))
        (mkMerge (
          flip mapAttrsToList cfg.ipvlans (
            name: ipvlan: {
              netdevs."40-${name}" = {
                ipvlanConfig =
                  optionalAttrs (ipvlan.mode != null) { Mode = lib.toUpper ipvlan.mode; }
                  // optionalAttrs (ipvlan.flags != null) { Flags = ipvlan.flags; };

                netdevConfig = {
                  Kind = "ipvlan";
                  Name = name;
                };
              };

              networks."40-${ipvlan.interface}" = {
                ipvlan = [ name ];
              };
            }
          )
        ))
        (mkMerge (
          flip mapAttrsToList cfg.fooOverUDP (
            name: fou: {
              netdevs."40-${name}" = {
                # unfortunately networkd cannot encode dependencies of netdevs on addresses/routes,
                # so we cannot specify Local=, Peer=, PeerPort=. this looks like a missing feature
                # in networkd.
                fooOverUDPConfig = {
                  Encapsulation = if fou.protocol != null then "FooOverUDP" else "GenericUDPEncapsulation";
                  Port = fou.port;
                }
                // (optionalAttrs (fou.protocol != null) {
                  Protocol = fou.protocol;
                });

                netdevConfig = {
                  Kind = "fou";
                  Name = name;
                };
              };
            }
          )
        ))
        (mkMerge (
          flip mapAttrsToList cfg.sits (
            name: sit: {
              netdevs."40-${name}" = {
                netdevConfig = {
                  Kind = "sit";
                  Name = name;
                };

                tunnelConfig =
                  (optionalAttrs (sit.remote != null) {
                    Remote = sit.remote;
                  })
                  // (optionalAttrs (sit.local != null) {
                    Local = sit.local;
                  })
                  // (optionalAttrs (sit.ttl != null) {
                    TTL = sit.ttl;
                  })
                  // (optionalAttrs (sit.encapsulation.type != "6in4") (
                    {
                      Encapsulation = if sit.encapsulation.type == "fou" then "FooOverUDP" else "GenericUDPEncapsulation";
                      FOUDestinationPort = sit.encapsulation.port;
                      FooOverUDP = true;
                    }
                    // (optionalAttrs (sit.encapsulation.sourcePort != null) {
                      FOUSourcePort = sit.encapsulation.sourcePort;
                    })
                  ));
              };

              networks = mkIf (sit.dev != null) {
                "40-${sit.dev}" = {
                  tunnel = [ name ];
                };
              };
            }
          )
        ))
        (mkMerge (
          flip mapAttrsToList cfg.ipips (
            name: ipip: {
              netdevs."40-${name}" = {
                netdevConfig = {
                  Kind = if ipip.encapsulation.type == "ipip" then "ipip" else "ip6tnl";
                  Name = name;
                };

                tunnelConfig =
                  (optionalAttrs (ipip.remote != null) {
                    Remote = ipip.remote;
                  })
                  // (optionalAttrs (ipip.local != null) {
                    Local = ipip.local;
                  })
                  // (optionalAttrs (ipip.ttl != null) {
                    TTL = ipip.ttl;
                  })
                  // (optionalAttrs (ipip.encapsulation.type != "ipip") {
                    EncapsulationLimit = ipip.encapsulation.type;
                    # IPv6 tunnel options
                    Mode = if ipip.encapsulation.type == "4in6" then "ipip6" else "ip6ip6";
                  });
              };

              networks = mkIf (ipip.dev != null) {
                "40-${ipip.dev}" = {
                  tunnel = [ name ];
                };
              };
            }
          )
        ))
        (mkMerge (
          flip mapAttrsToList cfg.greTunnels (
            name: gre: {
              netdevs."40-${name}" = {
                netdevConfig = {
                  Kind = gre.type;
                  Name = name;
                };

                tunnelConfig =
                  (optionalAttrs (gre.remote != null) {
                    Remote = gre.remote;
                  })
                  // (optionalAttrs (gre.local != null) {
                    Local = gre.local;
                  })
                  // (optionalAttrs (gre.ttl != null) {
                    TTL = gre.ttl;
                  });
              };

              networks = mkIf (gre.dev != null) {
                "40-${gre.dev}" = {
                  tunnel = [ name ];
                };
              };
            }
          )
        ))
        vlanNetworks
      ];

      systemd.services =
        let
          # We must escape interfaces due to the systemd interpretation
          subsystemDevice = interface: "sys-subsystem-net-devices-${escapeSystemdPath interface}.device";
          # support for creating openvswitch switches
          createVswitchDevice =
            n: v:
            nameValuePair "${n}-netdev" (
              let
                deps = map subsystemDevice (
                  attrNames (filterAttrs (_: config: config.type != "internal") v.interfaces)
                );
                ofRules = pkgs.writeText "vswitch-${n}-openFlowRules" v.openFlowRules;
              in
              {
                # start switch after physical interfaces and vswitch daemon
                after = [
                  "network-pre.target"
                  "ovs-vswitchd.service"
                ]
                ++ deps;

                # and create bridge before systemd-networkd starts because it might create internal interfaces
                before = [ "systemd-networkd.service" ];
                # requires ovs-vswitchd to be alive at all times
                bindsTo = [ "ovs-vswitchd.service" ];
                description = "Open vSwitch Interface ${n}";
                # shutdown the bridge when network is shutdown
                partOf = [ "network.target" ];

                path = [
                  pkgs.iproute2
                  config.virtualisation.vswitch.package
                ];

                postStop = ''
                  echo "Cleaning Open vSwitch ${n}"
                  echo "Shutting down internal ${n} interface"
                  ip link set dev ${n} down || true
                  echo "Deleting flows for ${n}"
                  ovs-ofctl --protocols=${v.openFlowVersion} del-flows ${n} || true
                  echo "Deleting Open vSwitch ${n}"
                  ovs-vsctl --if-exists del-br ${n} || true
                '';

                preStart = ''
                  echo "Resetting Open vSwitch ${n}..."
                  ovs-vsctl --if-exists del-br ${n} -- add-br ${n} \
                            -- set bridge ${n} protocols=${concatStringsSep "," v.supportedOpenFlowVersions}
                '';

                script = ''
                  echo "Configuring Open vSwitch ${n}..."
                  ovs-vsctl ${
                    concatStrings (
                      mapAttrsToList (
                        name: config:
                        " -- add-port ${n} ${name}" + optionalString (config.vlan != null) " tag=${toString config.vlan}"
                      ) v.interfaces
                    )
                  } \
                    ${
                      concatStrings (
                        mapAttrsToList (
                          name: config: optionalString (config.type != null) " -- set interface ${name} type=${config.type}"
                        ) v.interfaces
                      )
                    } \
                    ${concatMapStrings (x: " -- set-controller ${n} " + x) v.controllers} \
                    ${concatMapStrings (x: " -- " + x) (splitString "\n" v.extraOvsctlCmds)}


                  echo "Adding OpenFlow rules for Open vSwitch ${n}..."
                  ovs-ofctl --protocols=${v.openFlowVersion} add-flows ${n} ${ofRules}
                '';

                serviceConfig.RemainAfterExit = true;
                serviceConfig.Type = "oneshot";

                wantedBy = [
                  "network.target"
                  (subsystemDevice n)
                ];

                wants = deps; # if one or more interface fails, the switch should continue to run
              }
            );
        in
        mapAttrs' createVswitchDevice cfg.vswitches
        // {
          "network-local-commands" = {
            after = [ "systemd-networkd.service" ];
            bindsTo = [ "systemd-networkd.service" ];
          };
        };
    })

  ];
}
