{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.netfoil;
in
{
  options = {
    services.netfoil = {
      config = lib.mkOption {
        default = { };
        description = "Additional configuration options for Netfoil";
        type = lib.types.attrsOf lib.types.str;
      };

      enable = lib.mkOption {
        default = false;
        description = "Enable Netfoil, a minimal, filtering, DNS proxy";
        type = lib.types.bool;
      };

      doHIPs = lib.mkOption {
        default = "1.1.1.2,1.0.0.2";
        description = "The DoH IPs to use for upstream DNS queries";
        type = lib.types.str;
      };

      doHUrl = lib.mkOption {
        default = "https://security.cloudflare-dns.com/dns-query";
        description = "The DoH URL to use for upstream DNS queries";
        type = lib.types.str;
      };

      listen = {
        ipAddress = lib.mkOption {
          default = "127.0.0.1";
          description = "IP address on which Netfoil listens for incoming connections";
          type = lib.types.str;
        };

        port = lib.mkOption {
          default = 53;
          description = "Port on which Netfoil listens for incoming connections";
          type = lib.types.int;
        };
      };

      logAllowed = lib.mkOption {
        default = false;
        description = "Log allowed DNS queries";
        type = lib.types.bool;
      };

      logDenied = lib.mkOption {
        default = true;
        description = "Log denied DNS queries";
        type = lib.types.bool;
      };

      rules = {
        allow = {
          exact = lib.mkOption {
            default = [ ];
            description = "List of exact domain names to allow";
            type = lib.types.listOf lib.types.str;
          };

          ipv4 = lib.mkOption {
            default = [ ];
            description = "List of ipv4 CIDR ranges to allow";
            type = lib.types.listOf lib.types.str;
          };

          ipv6 = lib.mkOption {
            default = [ ];
            description = "List of ipv6 CIDR ranges to allow";
            type = lib.types.listOf lib.types.str;
          };

          tld = lib.mkOption {
            default = [ ];
            description = "List of TLDs to allow";
            type = lib.types.listOf lib.types.str;
          };
        };

        deny = {
          exact = lib.mkOption {
            default = [ ];
            description = "List of exact domain names to deny";
            type = lib.types.listOf lib.types.str;
          };

          ipv4 = lib.mkOption {
            default = [ ];
            description = "List of ipv4 CIDR ranges to deny";
            type = lib.types.listOf lib.types.str;
          };

          ipv6 = lib.mkOption {
            default = [ ];
            description = "List of ipv6 CIDR ranges to deny";
            type = lib.types.listOf lib.types.str;
          };

          tld = lib.mkOption {
            default = [ ];
            description = "List of TLDs to deny";
            type = lib.types.listOf lib.types.str;
          };
        };

        known = {
          knownTlds = lib.mkOption {
            default = [
              ".com"
              ".net"
              ".org"
              ".edu"
              ".gov"
              ".mil"
              ".int"
            ];

            description = "List of known TLDs";
            type = lib.types.listOf lib.types.str;
          };
        };

        pin = {
          a = lib.mkOption {
            default = [ ];
            description = "List of A records to pin <domain:ipv4>";
            type = lib.types.listOf lib.types.str;
          };

          responseDomain = lib.mkOption {
            default = [ ];
            description = "List of domains to pin <domain:domain>";
            type = lib.types.listOf lib.types.str;
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (
    let
      configFile = lib.concatStringsSep "\n" (
        [
          "LogAllowed=${lib.boolToString cfg.logAllowed}"
          "LogDenied=${lib.boolToString cfg.logDenied}"
          "DoHURL=${cfg.doHUrl}"
          "DoHIPs=${cfg.doHIPs}"
        ]
        ++ (map (key: "${key} = \"${cfg.config.${key}}\"") (lib.attrNames cfg.config))
        ++ lib.optional ((lib.length cfg.rules.pin.responseDomain) != 0) "PinResponseDomain=true"
      );
      configDir = pkgs.buildEnv {
        name = "netfoil-config";

        paths = [
          (pkgs.writeTextDir "config" configFile)
          (pkgs.writeTextDir "allow.exact" (lib.concatStringsSep "\n" cfg.rules.allow.exact))
          (pkgs.writeTextDir "allow.ipv4" (lib.concatStringsSep "\n" cfg.rules.allow.ipv4))
          (pkgs.writeTextDir "allow.ipv6" (lib.concatStringsSep "\n" cfg.rules.allow.ipv6))
          (pkgs.writeTextDir "allow.suffix" (lib.concatStringsSep "\n" cfg.rules.allow.tld))
          (pkgs.writeTextDir "allow.tld" (lib.concatStringsSep "\n" cfg.rules.allow.tld))
          (pkgs.writeTextDir "deny.exact" (lib.concatStringsSep "\n" cfg.rules.deny.exact))
          (pkgs.writeTextDir "deny.ipv4" (lib.concatStringsSep "\n" cfg.rules.deny.ipv4))
          (pkgs.writeTextDir "deny.ipv6" (lib.concatStringsSep "\n" cfg.rules.deny.ipv6))
          (pkgs.writeTextDir "deny.suffix" (lib.concatStringsSep "\n" cfg.rules.deny.tld))
          (pkgs.writeTextDir "deny.tld" (lib.concatStringsSep "\n" cfg.rules.deny.tld))
          (pkgs.writeTextDir "known.tld" (lib.concatStringsSep "\n" cfg.rules.known.knownTlds))
          (pkgs.writeTextDir "pin.a" (lib.concatStringsSep "\n" cfg.rules.pin.a))
          (pkgs.writeTextDir "pin.response-domain" (lib.concatStringsSep "\n" cfg.rules.pin.responseDomain))
        ];
      };
    in
    {
      systemd = {
        services.netfoil = {
          enable = true;
          after = [ "network.target" ];
          description = "Netfoil DNS proxy";
          requires = [ "netfoil.socket" ];

          serviceConfig = {
            AmbientCapabilities = "";

            BindReadOnlyPaths = [
              "${pkgs.netfoil}"
              "${configDir}"
              "/etc/ssl"
              builtins.storeDir
            ];

            CPUQuota = "50%";
            CapabilityBoundingSet = [ ];
            DevicePolicy = "closed";
            DynamicUser = true;
            ExecStart = "${pkgs.netfoil}/bin/netfoil --config-directory ${configDir}";
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            MemoryMax = "100M";
            #
            # seccomp @raw-io (custom filter does not allow it anyway)
            PrivateDevices = true;
            # IPC namespace
            PrivateIPC = true;
            PrivateTmp = true;
            ProcSubset = "pid";
            # This might set AllowDevices=char-rtc r
            ProtectClock = true;
            # Changes mounts (custom is more strict)
            # https://github.com/systemd/systemd/blob/main/src/core/namespace.c
            #
            ProtectControlGroups = true;
            ProtectHome = true;
            # UTS namespace
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            #
            # seccomp _sysctl (custom filter does not allow it anyway)
            # /proc and /sys mounts (custom is more strict)
            ProtectKernelTunables = true;
            ProtectProc = "invisible";
            ProtectSystem = "strict";
            RemoveIPC = true;
            Restart = "always";
            RestartSec = "5";
            RestrictAddressFamilies = "AF_INET AF_INET6";
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            RootDirectory = "/run/netfoil";
            RuntimeDirectory = "netfoil";
            RuntimeDirectoryMode = "0755";
            Slice = "netfoil.slice";
            SocketBindDeny = "any";

            SystemCallFilter = [
              "@basic-io"
              "@file-system"
              "@network-io"
              "@signal"
              "@process"
              "@io-event"
              "@system-service"
              "@resources"
            ];

            SystenCallArchitectures = "native";
            TasksMax = "100";
            Type = "simple";
            UMask = "0077";
          };

          wantedBy = [ "multi-user.target" ];
        };

        slices.netfoil = {
          description = "Slice for Netfoil DNS proxy";
        };

        sockets.netfoil = {
          description = "Netfoil DNS proxy socket";

          socketConfig = {
            ListenDatagram = "${cfg.listen.ipAddress}:${toString cfg.listen.port}";
            Service = "netfoil.service";
          };

          wantedBy = [ "sockets.target" ];
        };
      };
    }
  );
}
