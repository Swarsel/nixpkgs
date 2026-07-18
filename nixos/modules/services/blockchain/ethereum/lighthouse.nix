{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.lighthouse;
in
{
  options = {
    services.lighthouse = {
      package = lib.mkPackageOption pkgs "lighthouse" { };

      beacon = lib.mkOption {
        default = { };
        description = "Beacon node";

        type = lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "Lightouse Beacon node";

            address = lib.mkOption {
              default = "0.0.0.0";

              description = ''
                Listen address of Beacon node.
              '';

              type = lib.types.str;
            };

            dataDir = lib.mkOption {
              default = "/var/lib/lighthouse-beacon";

              description = ''
                Directory where data will be stored. Each chain will be stored under it's own specific subdirectory.
              '';

              type = lib.types.str;
            };

            disableDepositContractSync = lib.mkOption {
              default = false;

              description = ''
                Explicitly disables syncing of deposit logs from the execution node.
                This overrides any previous option that depends on it.
                Useful if you intend to run a non-validating beacon node.
              '';

              type = lib.types.bool;
            };

            execution = {
              address = lib.mkOption {
                default = "127.0.0.1";

                description = ''
                  Listen address for the execution layer.
                '';

                type = lib.types.str;
              };

              jwtPath = lib.mkOption {
                default = "";

                description = ''
                  Path for the jwt secret required to connect to the execution layer.
                '';

                type = lib.types.str;
              };

              port = lib.mkOption {
                default = 8551;

                description = ''
                  Port number the Beacon node will be listening on for the execution layer.
                '';

                type = lib.types.port;
              };
            };

            extraArgs = lib.mkOption {
              default = "";

              description = ''
                Additional arguments passed to the lighthouse beacon command.
              '';

              example = "";
              type = lib.types.str;
            };

            http = {
              enable = lib.mkEnableOption "Beacon node http api";

              address = lib.mkOption {
                default = "127.0.0.1";

                description = ''
                  Listen address of Beacon node RPC service.
                '';

                type = lib.types.str;
              };

              port = lib.mkOption {
                default = 5052;

                description = ''
                  Port number of Beacon node RPC service.
                '';

                type = lib.types.port;
              };
            };

            metrics = {
              enable = lib.mkEnableOption "Beacon node prometheus metrics";

              address = lib.mkOption {
                default = "127.0.0.1";

                description = ''
                  Listen address of Beacon node metrics service.
                '';

                type = lib.types.str;
              };

              port = lib.mkOption {
                default = 5054;

                description = ''
                  Port number of Beacon node metrics service.
                '';

                type = lib.types.port;
              };
            };

            openFirewall = lib.mkOption {
              default = false;

              description = ''
                Open the port in the firewall
              '';

              type = lib.types.bool;
            };

            port = lib.mkOption {
              default = 9000;

              description = ''
                Port number the Beacon node will be listening on.
              '';

              type = lib.types.port;
            };
          };
        };
      };

      extraArgs = lib.mkOption {
        default = "";

        description = ''
          Additional arguments passed to every lighthouse command.
        '';

        example = "";
        type = lib.types.str;
      };

      network = lib.mkOption {
        default = "mainnet";

        description = ''
          The network to connect to. Mainnet is the default ethereum network.
        '';

        type = lib.types.enum [
          "mainnet"
          "gnosis"
          "chiado"
          "sepolia"
          "holesky"
        ];
      };

      validator = lib.mkOption {
        default = { };
        description = "Validator node";

        type = lib.types.submodule {
          options = {
            enable = lib.mkOption {
              default = false;
              description = "Enable Lightouse Validator node.";
              type = lib.types.bool;
            };

            beaconNodes = lib.mkOption {
              default = [ "http://localhost:5052" ];

              description = ''
                Beacon nodes to connect to.
              '';

              type = lib.types.listOf lib.types.str;
            };

            dataDir = lib.mkOption {
              default = "/var/lib/lighthouse-validator";

              description = ''
                Directory where data will be stored. Each chain will be stored under it's own specific subdirectory.
              '';

              type = lib.types.str;
            };

            extraArgs = lib.mkOption {
              default = "";

              description = ''
                Additional arguments passed to the lighthouse validator command.
              '';

              example = "";
              type = lib.types.str;
            };

            metrics = {
              enable = lib.mkEnableOption "Validator node prometheus metrics";

              address = lib.mkOption {
                default = "127.0.0.1";

                description = ''
                  Listen address of Validator node metrics service.
                '';

                type = lib.types.str;
              };

              port = lib.mkOption {
                default = 5056;

                description = ''
                  Port number of Validator node metrics service.
                '';

                type = lib.types.port;
              };
            };
          };
        };
      };
    };
  };

  config = lib.mkIf (cfg.beacon.enable || cfg.validator.enable) {
    environment.systemPackages = [ cfg.package ];

    networking.firewall = lib.mkIf cfg.beacon.enable {
      allowedTCPPorts = lib.mkIf cfg.beacon.openFirewall [ cfg.beacon.port ];
      allowedUDPPorts = lib.mkIf cfg.beacon.openFirewall [ cfg.beacon.port ];
    };

    systemd.services.lighthouse-beacon = lib.mkIf cfg.beacon.enable {
      after = [ "network.target" ];
      description = "Lighthouse beacon node (connect to P2P nodes and verify blocks)";

      script = ''
        # make sure the chain data directory is created on first run
        mkdir -p ${cfg.beacon.dataDir}/${cfg.network}

        ${lib.getExe cfg.package} beacon_node \
          --disable-upnp \
          ${lib.optionalString cfg.beacon.disableDepositContractSync "--disable-deposit-contract-sync"} \
          --port ${toString cfg.beacon.port} \
          --listen-address ${cfg.beacon.address} \
          --network ${cfg.network} \
          --datadir ${cfg.beacon.dataDir}/${cfg.network} \
          --execution-endpoint http://${cfg.beacon.execution.address}:${toString cfg.beacon.execution.port} \
          --execution-jwt ''${CREDENTIALS_DIRECTORY}/LIGHTHOUSE_JWT \
          ${lib.optionalString cfg.beacon.http.enable "--http --http-address ${cfg.beacon.http.address} --http-port ${toString cfg.beacon.http.port}"} \
          ${lib.optionalString cfg.beacon.metrics.enable "--metrics --metrics-address ${cfg.beacon.metrics.address} --metrics-port ${toString cfg.beacon.metrics.port}"} \
          ${cfg.extraArgs} ${cfg.beacon.extraArgs}
      '';

      serviceConfig = {
        DynamicUser = true;
        LoadCredential = "LIGHTHOUSE_JWT:${cfg.beacon.execution.jwtPath}";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "noaccess";
        ReadWritePaths = [ cfg.beacon.dataDir ];
        RemoveIPC = true;
        Restart = "on-failure";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "lighthouse-beacon";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.lighthouse-validator = lib.mkIf cfg.validator.enable {
      after = [ "network.target" ];
      description = "Lighthouse validtor node (manages validators, using data obtained from the beacon node via a HTTP API)";

      script = ''
        # make sure the chain data directory is created on first run
        mkdir -p ${cfg.validator.dataDir}/${cfg.network}

        ${lib.getExe cfg.package} validator_client \
          --network ${cfg.network} \
          --beacon-nodes ${lib.concatStringsSep "," cfg.validator.beaconNodes} \
          --datadir ${cfg.validator.dataDir}/${cfg.network} \
          ${lib.optionalString cfg.validator.metrics.enable "--metrics --metrics-address ${cfg.validator.metrics.address} --metrics-port ${toString cfg.validator.metrics.port}"} \
          ${cfg.extraArgs} ${cfg.validator.extraArgs}
      '';

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "noaccess";
        ReadWritePaths = [ cfg.validator.dataDir ];
        RemoveIPC = true;
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "lighthouse-validator";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
