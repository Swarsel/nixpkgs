{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.tayga;

  # Converts an address set to a string
  strAddr = addr: "${addr.address}/${toString addr.prefixLength}";

  configFile = pkgs.writeText "tayga.conf" ''
    tun-device ${cfg.tunDevice}

    ipv4-addr ${cfg.ipv4.address}
    ${optionalString (cfg.ipv6.address != null) "ipv6-addr ${cfg.ipv6.address}"}

    prefix ${strAddr cfg.ipv6.pool}
    dynamic-pool ${strAddr cfg.ipv4.pool}
    data-dir ${cfg.dataDir}

    ${concatStringsSep "\n" (mapAttrsToList (ipv4: ipv6: "map " + ipv4 + " " + ipv6) cfg.mappings)}

    ${optionalString ((builtins.length cfg.log) > 0) ''
      log ${concatStringsSep " " cfg.log}
    ''}

    wkpf-strict ${boolToYesNo cfg.wkpfStrict}
  '';

  addrOpts =
    v:
    assert v == 4 || v == 6;
    {
      options = {
        address = mkOption {
          description = "IPv${toString v} address.";
          type = types.str;
        };

        prefixLength = mkOption {
          description = ''
            Subnet mask of the interface, specified as the number of
            bits in the prefix ("${if v == 4 then "24" else "64"}").
          '';

          type = types.ints.between 0 (if v == 4 then 32 else 128);
        };
      };
    };

  versionOpts = v: {
    options = {
      address = mkOption {
        default = null;
        description = "The source IPv${toString v} address of the TAYGA server.";
        type = types.nullOr types.str;
      };

      pool = mkOption {
        description = "The pool of IPv${toString v} addresses which are used for translation.";
        type = with types; nullOr (submodule (addrOpts v));
      };

      router = {
        address = mkOption {
          description = "The IPv${toString v} address of the router.";
          type = types.str;
        };
      };
    };
  };
in
{
  options = {
    services.tayga = {
      enable = mkEnableOption "Tayga";
      package = mkPackageOption pkgs "tayga" { };

      dataDir = mkOption {
        default = "/var/lib/tayga";
        description = "Directory for persistent data.";
        type = types.path;
      };

      ipv4 = mkOption {
        description = "IPv4-specific configuration.";

        example = literalExpression ''
          {
            address = "192.0.2.0";
            router = {
              address = "192.0.2.1";
            };
            pool = {
              address = "192.0.2.1";
              prefixLength = 24;
            };
          }
        '';

        type = types.submodule (versionOpts 4);
      };

      ipv6 = mkOption {
        description = "IPv6-specific configuration.";

        example = literalExpression ''
          {
            address = "2001:db8::1";
            router = {
              address = "64:ff9b::1";
            };
            pool = {
              address = "64:ff9b::";
              prefixLength = 96;
            };
          }
        '';

        type = types.submodule (versionOpts 6);
      };

      log = mkOption {
        default = [ ];
        description = "Packet errors to log (drop, reject, icmp, self)";

        example = literalExpression ''
          [ "drop" "reject" "icmp" "self" ]
        '';

        type = types.listOf types.str;
      };

      mappings = mkOption {
        default = { };
        description = "Static IPv4 -> IPv6 host mappings.";

        example = literalExpression ''
          {
            "192.168.5.42" = "2001:db8:1:4444::1";
            "192.168.5.43" = "2001:db8:1:4444::2";
            "192.168.255.2" = "2001:db8:1:569::143";
          }
        '';

        type = types.attrsOf types.str;
      };

      tunDevice = mkOption {
        default = "nat64";
        description = "Name of the nat64 tun device.";
        type = types.str;
      };

      wkpfStrict = mkOption {
        default = true;
        description = "Enable restrictions on the use of the well-known prefix (64:ff9b::/96) - prevents translation of non-global IPv4 ranges when using the well-known prefix. Must be enabled for RFC 6052 compatibility.";
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = allUnique (attrValues cfg.mappings);
        message = "Neither the IPv4 nor the IPv6 addresses must be entered twice in the mappings.";
      }
    ];

    environment.etc."tayga.conf".source = configFile;

    networking.interfaces."${cfg.tunDevice}" = {
      ipv4 = {
        addresses = [
          {
            address = cfg.ipv4.router.address;
            prefixLength = 32;
          }
        ];

        routes = [
          cfg.ipv4.pool
        ];
      };

      ipv6 = {
        addresses = [
          {
            address = cfg.ipv6.router.address;
            prefixLength = 128;
          }
        ];

        routes = [
          cfg.ipv6.pool
        ];
      };

      virtual = true;
      virtualOwner = null;
      virtualType = "tun";
    };

    systemd.services.tayga = {
      after = [ "network.target" ];
      description = "Stateless NAT64 implementation";
      reloadTriggers = [ configFile ];

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;
        ExecReload = "${pkgs.coreutils}/bin/kill -SIGHUP $MAINPID";
        ExecStart = "${cfg.package}/bin/tayga -d --nodetach --config /etc/tayga.conf";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectControlGroups = true;
        # Hardening Score: 1.5
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = true;
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "tayga";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@network-io"
          "@system-service"
          "~@privileged"
          "~@resources"
        ];
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
