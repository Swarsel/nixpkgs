{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.firewalld;
  format = pkgs.formats.xml { };
  lib' = import ./lib.nix { inherit lib; };
  inherit (lib')
    filterNullAttrs
    mkPortOption
    mkXmlAttr
    portProtocolOptions
    protocolOption
    toXmlAttrs
    ;
  inherit (lib) mkOption;
  inherit (lib.types)
    attrTag
    attrsOf
    bool
    enum
    ints
    listOf
    nonEmptyStr
    nullOr
    strMatching
    submodule
    ;
in
{
  options.services.firewalld.zones = mkOption {
    default = { };

    description = ''
      firewalld zone configuration files.
      See {manpage}`firewalld.zone(5)`.
    '';

    example = {
      dmz = {
        forward = true;

        services = [
          "ssh"
        ];
      };

      external = {
        forward = true;
        masquerade = true;

        services = [
          "ssh"
        ];
      };

      home = {
        forward = true;

        services = [
          "ssh"
          "mdns"
          "samba-client"
          "dhcpv6-client"
        ];
      };

      internal = {
        forward = true;

        services = [
          "ssh"
          "mdns"
          "samba-client"
          "dhcpv6-client"
        ];
      };

      public = {
        forward = true;

        services = [
          "ssh"
          "dhcpv6-client"
        ];
      };

      work = {
        forward = true;

        services = [
          "ssh"
          "dhcpv6-client"
        ];
      };
    };

    type = attrsOf (submodule {
      options = {
        description = mkOption {
          default = null;
          description = "Description for the zone.";
          type = nullOr nonEmptyStr;
        };

        egressPriority = mkOption {
          default = null;

          description = ''
            Priority for outbound traffic.
            Lower values have higher priority.
          '';

          type = nullOr ints.s16;
        };

        forward = mkOption {
          default = false;

          description = ''
            Whether to enable intra-zone forwarding.
            When enabled, packets will be forwarded between interfaces or sources within a zone, even if the zone's target is not set to ACCEPT.
          '';

          type = bool;
        };

        forwardPorts = mkOption {
          default = [ ];
          description = "Ports to forward in the zone.";

          type = listOf (submodule {
            options = {
              port = mkPortOption { };
              protocol = protocolOption;

              to-addr = mkOption {
                default = null;
                description = "Destination IP address.";
                type = nullOr nonEmptyStr;
              };

              to-port = (mkPortOption { optional = true; }) // {
                default = null;
              };
            };
          });
        };

        icmpBlockInversion = mkOption {
          default = false;

          description = ''
            Whether to invert the icmp block handling.
            Only enabled ICMP types are accepted and all others are rejected in the zone.
          '';

          type = bool;
        };

        icmpBlocks = mkOption {
          default = [ ];
          description = "ICMP types to block in the zone.";
          type = listOf nonEmptyStr;
        };

        ingressPriority = mkOption {
          default = null;

          description = ''
            Priority for inbound traffic.
            Lower values have higher priority.
          '';

          type = nullOr ints.s16;
        };

        interfaces = mkOption {
          default = [ ];
          description = "Interfaces to bind.";
          type = listOf nonEmptyStr;
        };

        masquerade = mkOption {
          default = false;
          description = "Whether to enable masquerading in the zone.";
          type = bool;
        };

        ports = mkOption {
          default = [ ];
          description = "Ports to allow in the zone.";
          type = listOf (submodule portProtocolOptions);
        };

        protocols = mkOption {
          default = [ ];
          description = "Protocols to allow in the zone.";
          type = listOf nonEmptyStr;
        };

        rules = mkOption {
          default = [ ];
          description = "Rich rules for the zone.";
          type = listOf (format.type);
        };

        services = mkOption {
          default = [ ];
          description = "Services to allow in the zone.";
          type = listOf nonEmptyStr;
        };

        short = mkOption {
          default = null;
          description = "Short description for the zone.";
          type = nullOr nonEmptyStr;
        };

        sourcePorts = mkOption {
          default = [ ];
          description = "Source ports to allow in the zone.";
          type = listOf (submodule portProtocolOptions);
        };

        sources = mkOption {
          default = [ ];
          description = "Source addresses, address ranges, MAC addresses or ipsets to bind.";

          type = listOf (attrTag {
            address = mkOption {
              description = ''
                An IP address or a network IP address with a mask for IPv4 or IPv6.
                For IPv4, the mask can be a network mask or a plain number.
                For IPv6 the mask is a plain number.
                The use of host names is not supported.
              '';

              type = nonEmptyStr;
            };

            ipset = mkOption {
              description = "An ipset.";
              type = nonEmptyStr;
            };

            mac = mkOption {
              description = "A MAC address.";
              type = strMatching "([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}";
            };
          });
        };

        target = mkOption {
          default = "%%REJECT%%";
          description = "Action for packets that doesn't match any rules.";

          type = enum [
            "ACCEPT"
            "%%REJECT%%"
            "DROP"
          ];
        };

        version = mkOption {
          default = null;
          description = "Version of the zone.";
          type = nullOr nonEmptyStr;
        };
      };
    });
  };

  config = lib.mkIf cfg.enable {
    environment.etc = lib.mapAttrs' (
      name: value:
      lib.nameValuePair "firewalld/zones/${name}.xml" {
        source = format.generate "firewalld-zone-${name}.xml" {
          zone =
            let
              mkXmlAttrList = name: map (mkXmlAttr name);
              mkXmlTag = value: if value then "" else null;
            in
            filterNullAttrs (
              lib.mergeAttrsList [
                (toXmlAttrs { inherit (value) version target; })
                (mkXmlAttr "ingress-priority" value.ingressPriority)
                (mkXmlAttr "egress-priority" value.egressPriority)
                {
                  inherit (value) short description;
                  forward = mkXmlTag value.forward;
                  forward-port = map toXmlAttrs (map filterNullAttrs value.forwardPorts);
                  icmp-block = mkXmlAttrList "name" value.icmpBlocks;
                  icmp-block-inversion = mkXmlTag value.icmpBlockInversion;
                  interface = mkXmlAttrList "name" value.interfaces;
                  masquerade = mkXmlTag value.masquerade;
                  port = map toXmlAttrs value.ports;
                  protocol = mkXmlAttrList "value" value.protocols;
                  rule = value.rules;
                  service = mkXmlAttrList "name" value.services;
                  source = map toXmlAttrs value.sources;
                  source-port = map toXmlAttrs value.sourcePorts;
                }
              ]
            );
        };
      }
    ) cfg.zones;

    services.firewalld.zones = {
      block = {
        forward = true;
      };

      drop = {
        forward = true;
        target = "DROP";
      };

      trusted = {
        forward = true;
        target = "ACCEPT";
      };
    };
  };
}
