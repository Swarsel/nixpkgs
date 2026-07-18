{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.samba-wsdd;

in
{
  options = {
    services.samba-wsdd = {
      enable = lib.mkEnableOption ''
        Web Services Dynamic Discovery host daemon. This enables (Samba) hosts, like your local NAS device,
        to be found by Web Service Discovery Clients like Windows
      '';

      discovery = lib.mkOption {
        default = false;
        description = "Enable discovery operation mode.";
        type = lib.types.bool;
      };

      domain = lib.mkOption {
        default = null;
        description = "Set domain name (disables workgroup).";
        type = lib.types.nullOr lib.types.str;
      };

      extraOptions = lib.mkOption {
        default = [ "--shortlog" ];
        description = "Additional wsdd options.";

        example = [
          "--verbose"
          "--no-http"
          "--ipv4only"
          "--no-host"
        ];

        type = lib.types.listOf lib.types.str;
      };

      hoplimit = lib.mkOption {
        default = null;
        description = "Hop limit for multicast packets (default = 1).";
        example = 2;
        type = lib.types.nullOr lib.types.int;
      };

      hostname = lib.mkOption {
        default = null;
        description = "Override (NetBIOS) hostname to be used (default hostname).";
        example = "FILESERVER";
        type = lib.types.nullOr lib.types.str;
      };

      interface = lib.mkOption {
        default = null;
        description = "Interface or address to use.";
        example = "eth0";
        type = lib.types.nullOr lib.types.str;
      };

      listen = lib.mkOption {
        default = "/run/wsdd/wsdd.sock";
        description = "Listen on path or localhost port in discovery mode.";
        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Whether to open the required firewall ports in the firewall.
        '';

        type = lib.types.bool;
      };

      workgroup = lib.mkOption {
        default = null;
        description = "Set workgroup name (default WORKGROUP).";
        example = "HOME";
        type = lib.types.nullOr lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.wsdd ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ 5357 ];
      allowedUDPPorts = [ 3702 ];
    };

    systemd.services.samba-wsdd = {
      after = [ "network.target" ];
      description = "Web Services Dynamic Discovery host daemon";

      serviceConfig = {
        # Capabilities
        CapabilityBoundingSet = "";
        DynamicUser = true;

        ExecStart = ''
          ${pkgs.wsdd}/bin/wsdd ${
            lib.optionalString (cfg.interface != null) "--interface '${cfg.interface}'"
          } \
                                ${
                                  lib.optionalString (cfg.hoplimit != null) "--hoplimit '${toString cfg.hoplimit}'"
                                } \
                                ${
                                  lib.optionalString (cfg.workgroup != null) "--workgroup '${cfg.workgroup}'"
                                } \
                                ${lib.optionalString (cfg.hostname != null) "--hostname '${cfg.hostname}'"} \
                                ${lib.optionalString (cfg.domain != null) "--domain '${cfg.domain}'"} \
                                ${lib.optionalString cfg.discovery "--discovery --listen '${cfg.listen}'"} \
                                ${lib.escapeShellArgs cfg.extraOptions}
        '';

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        # Security
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = false;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        # Sandboxing
        ProtectSystem = "strict";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        # Runtime directory and mode
        RuntimeDirectory = "wsdd";
        RuntimeDirectoryMode = "0750";
        # System Call Filtering
        SystemCallArchitectures = "native";
        SystemCallFilter = "~@cpu-emulation @debug @mount @obsolete @privileged @resources";
        Type = "simple";
        # Access write directories
        UMask = "0027";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
