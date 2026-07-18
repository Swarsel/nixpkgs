# This module defines networking options for virtual machines and containers.
# It is intended to be used with systemd-nspawn containers and QEMU virtual machines.
{ config, lib, ... }:
let
  inherit (lib) types;

  interfaceType = types.submodule (
    { name, ... }:
    {
      options = {
        assignIP = lib.mkOption {
          default = false;

          description = ''
            Automatically assign an IP address to the network interface using the same scheme as
            virtualisation.vlans.
          '';

          type = types.bool;
        };

        name = lib.mkOption {
          default = name;

          description = ''
            Interface name
          '';

          type = types.str;
        };

        vlan = lib.mkOption {
          description = ''
            VLAN to which the network interface is connected.
          '';

          type = types.ints.unsigned;
        };
      };
    }
  );

  cfg = config.virtualisation;

  # Convert legacy VLANs to named interfaces.
  vlansNumbered = lib.listToAttrs (
    lib.forEach (lib.zipLists cfg.vlans (lib.range 1 255)) (
      v:
      let
        name = "eth${toString v.snd}";
      in
      lib.nameValuePair name {
        inherit name;
        assignIP = true;
        vlan = v.fst;
      }
    )
  );
in
{
  options = {
    networking.primaryIPAddress = lib.mkOption {
      default = "";
      description = "Primary IP address used in /etc/hosts.";
      internal = true;
      type = types.str;
    };

    networking.primaryIPv6Address = lib.mkOption {
      default = "";
      description = "Primary IPv6 address used in /etc/hosts.";
      internal = true;
      type = types.str;
    };

    virtualisation.allInterfaces = lib.mkOption {
      default = vlansNumbered // cfg.interfaces;

      description = ''
        All network interfaces for the container or VM. Combines
        {option}`virtualisation.vlans` and {option}`virtualisation.interfaces`.
      '';

      readOnly = true;
      type = types.attrsOf interfaceType;
    };

    virtualisation.interfaces = lib.mkOption {
      default = { };

      description = ''
        Extra network interfaces to add to the container or VM in addition to the ones
        created by {option}`virtualisation.vlans`.
      '';

      example = {
        enp1s0.vlan = 1;
      };

      type = types.attrsOf interfaceType;
    };

    virtualisation.vlans = lib.mkOption {
      default = if cfg.interfaces == { } then [ 1 ] else [ ];
      defaultText = lib.literalExpression "if config.virtualisation.interfaces == {} then [ 1 ] else [ ]";

      description = ''
        Virtual networks to which the container or VM is connected. Each number «N» in
        this list causes the container to have a virtual Ethernet interface
        attached to a separate virtual network on which it will be assigned IP
        address `192.168.«N».«M»`, where «M» is the index of this container in
        the list of containers.
      '';

      example = [
        1
        2
      ];

      type = types.listOf types.ints.unsigned;
    };
  };

  config = {
    assertions = [
      (
        let
          conflictingKeys = lib.intersectAttrs vlansNumbered cfg.interfaces;
        in
        {
          assertion = conflictingKeys == { };

          message = ''
            `virtualisation.vlans` and `virtualisation.interfaces` have conflicting keys: ${lib.concatStringsSep "," (lib.attrNames conflictingKeys)}
          '';
        }
      )
      (
        let
          allInterfaceNames =
            (lib.mapAttrsToList (k: i: i.name) vlansNumbered)
            ++ (lib.mapAttrsToList (k: i: i.name) cfg.interfaces);
        in
        {
          assertion = lib.allUnique allInterfaceNames;

          message = ''
            `virtualisation.vlans` and `virtualisation.interfaces` have conflicting interface names: ${lib.concatStringsSep "," allInterfaceNames}
          '';
        }
      )
    ];
  };
}
