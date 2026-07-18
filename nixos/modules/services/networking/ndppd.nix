{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.ndppd;

  render = s: f: concatStringsSep "\n" (mapAttrsToList f s);
  prefer = a: b: if a != null then a else b;

  ndppdConf = prefer cfg.configFile (
    pkgs.writeText "ndppd.conf" ''
      route-ttl ${toString cfg.routeTTL}
      ${render cfg.proxies (
        proxyInterfaceName: proxy: ''
          proxy ${prefer proxy.interface proxyInterfaceName} {
            router ${boolToString proxy.router}
            timeout ${toString proxy.timeout}
            ttl ${toString proxy.ttl}
            ${render proxy.rules (
              ruleNetworkName: rule: ''
                rule ${prefer rule.network ruleNetworkName} {
                  ${rule.method}${optionalString (rule.method == "iface") " ${rule.interface}"}
                }''
            )}
          }''
      )}
    ''
  );

  proxy = types.submodule {
    options = {
      interface = mkOption {
        default = null;

        description = ''
          Listen for any Neighbor Solicitation messages on this interface,
          and respond to them according to a set of rules.
          Defaults to the name of the attrset.
        '';

        type = types.nullOr types.str;
      };

      router = mkOption {
        default = true;

        description = ''
          Turns on or off the router flag for Neighbor Advertisement Messages.
        '';

        type = types.bool;
      };

      rules = mkOption {
        default = { };

        description = ''
          This is a rule that the target address is to match against. If no netmask
          is provided, /128 is assumed. You may have several rule sections, and the
          addresses may or may not overlap.
        '';

        type = types.attrsOf rule;
      };

      timeout = mkOption {
        default = 500;

        description = ''
          Controls how long to wait for a Neighbor Advertisement Message before
          invalidating the entry, in milliseconds.
        '';

        type = types.int;
      };

      ttl = mkOption {
        default = 30000;

        description = ''
          Controls how long a valid or invalid entry remains in the cache, in
          milliseconds.
        '';

        type = types.int;
      };
    };
  };

  rule = types.submodule {
    options = {
      interface = mkOption {
        default = null;
        description = "Interface to use when method is iface.";
        type = types.nullOr types.str;
      };

      method = mkOption {
        default = "auto";

        description = ''
          static: Immediately answer any Neighbor Solicitation Messages
            (if they match the IP rule).
          iface: Forward the Neighbor Solicitation Message through the specified
            interface and only respond if a matching Neighbor Advertisement
            Message is received.
          auto: Same as iface, but instead of manually specifying the outgoing
            interface, check for a matching route in /proc/net/ipv6_route.
        '';

        type = types.enum [
          "static"
          "iface"
          "auto"
        ];
      };

      network = mkOption {
        default = null;

        description = ''
          This is the target address is to match against. If no netmask
          is provided, /128 is assumed. The addresses of several rules
          may or may not overlap.
          Defaults to the name of the attrset.
        '';

        type = types.nullOr types.str;
      };
    };
  };

in
{
  options.services.ndppd = {
    enable = mkEnableOption "daemon that proxies NDP (Neighbor Discovery Protocol) messages between interfaces";

    configFile = mkOption {
      default = null;
      description = "Path to configuration file.";
      type = types.nullOr types.path;
    };

    interface = mkOption {
      default = null;

      description = ''
        Interface which is on link-level with router.
        (Legacy option, use services.ndppd.proxies.\<interface\>.rules.\<network\> instead)
      '';

      example = "eth0";
      type = types.nullOr types.str;
    };

    network = mkOption {
      default = null;

      description = ''
        Network that we proxy.
        (Legacy option, use services.ndppd.proxies.\<interface\>.rules.\<network\> instead)
      '';

      example = "1111::/64";
      type = types.nullOr types.str;
    };

    proxies = mkOption {
      default = { };

      description = ''
        This sets up a listener, that will listen for any Neighbor Solicitation
        messages, and respond to them according to a set of rules.
      '';

      example = literalExpression ''
        {
          eth0.rules."1111::/64" = {};
        }
      '';

      type = types.attrsOf proxy;
    };

    routeTTL = mkOption {
      default = 30000;

      description = ''
        This tells 'ndppd' how often to reload the route file /proc/net/ipv6_route,
        in milliseconds.
      '';

      type = types.int;
    };
  };

  config = mkIf cfg.enable {
    services.ndppd.proxies = mkIf (cfg.interface != null && cfg.network != null) {
      ${cfg.interface}.rules.${cfg.network} = { };
    };

    systemd.services.ndppd = {
      after = [ "network-pre.target" ];
      description = "NDP Proxy Daemon";

      documentation = [
        "man:ndppd(1)"
        "man:ndppd.conf(5)"
      ];

      serviceConfig = {
        # Sandboxing
        CapabilityBoundingSet = "CAP_NET_RAW CAP_NET_ADMIN";
        ExecStart = "${pkgs.ndppd}/bin/ndppd -c ${ndppdConf}";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = "AF_INET6 AF_PACKET AF_NETLINK";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };

      wantedBy = [ "multi-user.target" ];
    };

    warnings = mkIf (cfg.interface != null && cfg.network != null) [
      ''
        The options services.ndppd.interface and services.ndppd.network will probably be removed soon,
        please use services.ndppd.proxies.<interface>.rules.<network> instead.
      ''
    ];
  };
}
