{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.veilid;
  dataDir = "/var/db/veilid-server";

  settingsFormat = pkgs.formats.yaml { };

  configFile = settingsFormat.generate "veilid-server.conf" (
    lib.converge (lib.filterAttrsRecursive (
      _: v: v != null && v != { } && v != "" && v != [ ]
    )) cfg.settings
  );
in
{
  options.services.veilid = {
    enable = mkEnableOption "Veilid Headless Node";

    openFirewall = mkOption {
      default = false;
      description = "Whether to open firewall on ports 5150/tcp, 5150/udp";
      type = types.bool;
    };

    settings = mkOption {
      description = ''
        Build veilid-server.conf with nix expression.
        Check [Configuration Keys](https://veilid.gitlab.io/developer-book/admin/config.html#configuration-keys).
      '';

      type = types.submodule {
        options = {
          client_api = {
            ipc_directory = mkOption {
              default = "${dataDir}/ipc";
              description = "IPC directory where file sockets are stored.";
              type = types.str;
            };

            ipc_enabled = mkOption {
              default = true;
              description = "veilid-server will respond to Python and other JSON client requests.";
              type = types.bool;
            };
          };

          core = {
            block_store = {
              directory = mkOption {
                default = "${dataDir}/block_store";
                description = "The filesystem directory to store blocks for the block store.";
                type = types.nullOr types.str;
              };
            };

            capabilities = {
              disable = mkOption {
                default = [ ];
                description = "A list of capabilities to disable (for example, DHTV to say you cannot store DHT information).";
                example = [ "APPM" ];
                type = types.listOf types.str;
              };
            };

            network = {
              detect_address_changes = mkOption {
                default = true;
                description = "Should veilid-core detect and notify on network address changes?";
                type = types.bool;
              };

              dht = {
                min_peer_count = mkOption {
                  default = null;
                  description = "Minimum number of nodes to keep in the peer table.";
                  type = lib.types.nullOr types.number;
                };
              };

              routing_table = {
                bootstrap = mkOption {
                  default = null;
                  description = "Host name of existing well-known Veilid bootstrap servers for the network to connect to.";
                  type = lib.types.nullOr (types.listOf types.str);
                };

                public_keys = lib.mkOption {
                  default = null;
                  description = "Base64-encoded public key for the node, used as the node's ID.";
                  type = lib.types.nullOr lib.types.str;
                };
              };

              upnp = mkOption {
                default = true;
                description = "Should the app try to improve its incoming network connectivity using UPnP?";
                type = types.bool;
              };
            };

            protected_store = {
              allow_insecure_fallback = mkOption {
                default = null;
                description = "If we can't use system-provided secure storage, should we proceed anyway?";
                type = lib.types.nullOr types.bool;
              };

              always_use_insecure_storage = mkOption {
                default = null;
                description = "Should we bypass any attempt to use system-provided secure storage?";
                type = lib.types.nullOr types.bool;
              };

              directory = mkOption {
                default = "${dataDir}/protected_store";
                description = "The filesystem directory to store your protected store in.";
                type = types.str;
              };
            };

            table_store = {
              directory = mkOption {
                default = "${dataDir}/table_store";
                description = "The filesystem directory to store your table store within.";
                type = types.str;
              };
            };
          };

          logging = {
            api = {
              enabled = mkOption {
                default = false;
                description = "Events of type 'api' will be logged.";
                type = types.bool;
              };

              level = mkOption {
                default = "info";
                description = "The minimum priority of api events to be logged.";
                example = "debug";
                type = types.str;
              };
            };

            system = {
              enabled = mkOption {
                default = true;
                description = "Events of type 'system' will be logged.";
                type = types.bool;
              };

              level = mkOption {
                default = "info";
                description = "The minimum priority of system events to be logged.";
                example = "debug";
                type = types.str;
              };
            };

            terminal = {
              enabled = mkOption {
                default = false;
                description = "Events of type 'terminal' will be logged.";
                type = types.bool;
              };

              level = mkOption {
                default = "info";
                description = "The minimum priority of terminal events to be logged.";
                example = "debug";
                type = types.str;
              };
            };
          };
        };

        freeformType = settingsFormat.type;
      };
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [ pkgs.veilid ];
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 5150 ];
      allowedUDPPorts = [ 5150 ];
    };

    services.veilid.settings = { };

    # Based on https://gitlab.com/veilid/veilid/-/blob/main/package/systemd/veilid-server.service?ref_type=heads
    systemd.services.veilid = {
      enable = true;
      before = [ "network-online.target" ];
      description = "Veilid Headless Node";

      environment = {
        RUST_BACKTRACE = "1";
      };

      restartTriggers = [ configFile ];

      serviceConfig = {
        CapabilityBoundingSet = "";
        ExecReload = "${pkgs.coreutils}/bin/kill -s HUP $MAINPID";
        ExecStart = "${pkgs.veilid}/bin/veilid-server -c ${configFile}";
        Group = "veilid";
        KillSignal = "SIGQUIT";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        ReadWritePaths = dataDir;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" ];
        TimeoutStopSec = 5;
        UMask = "0002";
        User = "veilid";
        WorkingDirectory = "/";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

    users.groups.veilid = { };

    users.users.veilid = {
      createHome = true;
      group = "veilid";
      home = dataDir;
      isSystemUser = true;
    };
  };

  meta.maintainers = with maintainers; [ figboy9 ];
}
