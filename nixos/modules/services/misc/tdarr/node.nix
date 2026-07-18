{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.tdarr;
  enabledNodes = lib.filterAttrs (_: nodeCfg: nodeCfg.enable) cfg.nodes;
  nodesEnabled = cfg.enable || (enabledNodes != { });
  serverEnabled = cfg.enable || cfg.server.enable;
  nodeConfigFiles = lib.mapAttrs (
    nodeId: nodeCfg:
    pkgs.writeText "Tdarr_Node_Config_${nodeId}.json" (
      builtins.toJSON { pathTranslators = nodeCfg.pathTranslators; }
    )
  ) enabledNodes;
in
{
  options.services.tdarr.nodes = lib.mkOption {
    default = { };
    description = "Attribute set of Tdarr processing nodes to run on this machine.";

    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            enable = lib.mkEnableOption "this Tdarr node" // {
              default = true;
            };

            package = lib.mkOption {
              default = cfg.package.node;
              defaultText = lib.literalExpression "config.services.tdarr.package.node";
              description = "Package to use for this Tdarr node.";
              type = lib.types.package;
            };

            cronPluginUpdate = lib.mkOption {
              default = "";
              description = "Cron expression for automatic plugin updates. Empty string disables.";
              type = lib.types.str;
            };

            dataDir = lib.mkOption {
              default = "${cfg.dataDir}/nodes/${name}";
              defaultText = lib.literalExpression ''"''${config.services.tdarr.dataDir}/nodes/''${name}"'';
              description = "Data directory for this node.";
              type = lib.types.path;
            };

            environmentFile = lib.mkOption {
              default = null;

              description = ''
                File containing environment variable overrides for this node,
                in the format accepted by systemd's `EnvironmentFile`.

                Useful for passing secrets like `apiKey` without putting them
                in the Nix store.
              '';

              example = "/run/secrets/tdarr-node-env";
              type = lib.types.nullOr lib.types.path;
            };

            maxLogSizeMB = lib.mkOption {
              default = 10;
              description = "Maximum log file size in megabytes.";
              type = lib.types.ints.unsigned;
            };

            name = lib.mkOption {
              default = "${config.networking.hostName}-${name}";
              defaultText = lib.literalExpression ''"''${config.networking.hostName}-''${name}"'';
              description = "Display name for this node in the Tdarr web UI.";
              type = lib.types.str;
            };

            pathTranslators = lib.mkOption {
              default = [ ];

              description = ''
                Path translations between server and node for cross-platform or
                cross-mount-point file access.
              '';

              example = lib.literalExpression ''
                [
                  { server = "/media"; node = "/mnt/media"; }
                  { server = "/cache"; node = "/mnt/cache"; }
                ]
              '';

              type = lib.types.listOf (
                lib.types.submodule {
                  options = {
                    node = lib.mkOption {
                      description = "Node-side path for path translation.";
                      type = lib.types.str;
                    };

                    server = lib.mkOption {
                      description = "Server-side path for path translation.";
                      type = lib.types.str;
                    };
                  };
                }
              );
            };

            pollInterval = lib.mkOption {
              default = 2000;
              description = "How often the node checks the server for work, in milliseconds.";
              type = lib.types.ints.unsigned;
            };

            priority = lib.mkOption {
              default = -1;

              description = ''
                Node priority for job assignment.

                `-1` means no priority. `0` is the highest priority, `1` is next, and so on.
              '';

              type = lib.types.int;
            };

            serverURL = lib.mkOption {
              default = "http://127.0.0.1:${toString cfg.server.serverPort}";
              defaultText = lib.literalExpression ''"http://127.0.0.1:''${toString config.services.tdarr.server.serverPort}"'';

              description = ''
                Full URL of the Tdarr server this node connects to.

                This is the recommended way to specify the server location.
                When running a local server, the default value is correct.
              '';

              type = lib.types.str;
            };

            startPaused = lib.mkOption {
              default = false;
              description = "Whether the node starts in a paused state.";
              type = lib.types.bool;
            };

            type = lib.mkOption {
              default = "mapped";

              description = ''
                Node type.

                - `mapped`: Node accesses files directly from the library paths.
                - `unmapped`: Node receives files over the network API.
              '';

              type = lib.types.enum [
                "mapped"
                "unmapped"
              ];
            };

            workers = {
              healthcheckCPU = lib.mkOption {
                default = 1;
                description = "Number of CPU healthcheck workers. Can be overridden in the web UI.";
                type = lib.types.ints.unsigned;
              };

              healthcheckGPU = lib.mkOption {
                default = 0;
                description = "Number of GPU healthcheck workers. Can be overridden in the web UI.";
                type = lib.types.ints.unsigned;
              };

              transcodeCPU = lib.mkOption {
                default = 2;
                description = "Number of CPU transcode workers. Can be overridden in the web UI.";
                type = lib.types.ints.unsigned;
              };

              transcodeGPU = lib.mkOption {
                default = 0;
                description = "Number of GPU transcode workers. Can be overridden in the web UI.";
                type = lib.types.ints.unsigned;
              };
            };
          };
        }
      )
    );
  };

  config = lib.mkIf nodesEnabled {
    systemd.services = lib.mapAttrs' (
      nodeId: nodeCfg:
      lib.nameValuePair "tdarr-node-${nodeId}" {
        after = [ "network.target" ] ++ lib.optionals serverEnabled [ "tdarr-server.service" ];
        description = "Tdarr Node - ${nodeCfg.name}";

        environment = {
          cronPluginUpdate = nodeCfg.cronPluginUpdate;
          healthcheckcpuWorkers = toString nodeCfg.workers.healthcheckCPU;
          healthcheckgpuWorkers = toString nodeCfg.workers.healthcheckGPU;
          maxLogSizeMB = toString nodeCfg.maxLogSizeMB;
          nodeName = nodeCfg.name;
          nodeType = nodeCfg.type;
          pollInterval = toString nodeCfg.pollInterval;
          priority = toString nodeCfg.priority;
          rootDataPath = toString nodeCfg.dataDir;
          serverURL = nodeCfg.serverURL;
          startPaused = lib.boolToString nodeCfg.startPaused;
          transcodecpuWorkers = toString nodeCfg.workers.transcodeCPU;
          transcodegpuWorkers = toString nodeCfg.workers.transcodeGPU;
        };

        serviceConfig = {
          ExecStart = lib.getExe nodeCfg.package;
          Group = cfg.group;
          # Hardening
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";

          ReadWritePaths = lib.optionals (!lib.hasPrefix "/var/lib/" (toString nodeCfg.dataDir)) [
            (toString nodeCfg.dataDir)
          ];

          Restart = "on-failure";
          RestartSec = 5;

          StateDirectory = lib.mkIf (lib.hasPrefix "/var/lib/" (toString nodeCfg.dataDir)) (
            let
              rel = lib.removePrefix "/var/lib/" (toString nodeCfg.dataDir);
            in
            "${rel} ${rel}/configs ${rel}/logs"
          );

          StateDirectoryMode = lib.mkIf (lib.hasPrefix "/var/lib/" (toString nodeCfg.dataDir)) "0750";
          Type = "simple";
          User = cfg.user;
          WorkingDirectory = toString nodeCfg.dataDir;
        }
        // lib.optionalAttrs (nodeCfg.environmentFile != null) {
          EnvironmentFile = nodeCfg.environmentFile;
        };

        wantedBy = [ "multi-user.target" ];
        wants = lib.optionals serverEnabled [ "tdarr-server.service" ];
      }
    ) enabledNodes;

    systemd.tmpfiles.rules = lib.concatMap (nodeId: [
      "d ${cfg.dataDir}/nodes/${nodeId} 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/nodes/${nodeId}/configs 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/nodes/${nodeId}/logs 0750 ${cfg.user} ${cfg.group} -"
      "L+ ${cfg.dataDir}/nodes/${nodeId}/configs/Tdarr_Node_Config.json - - - - ${nodeConfigFiles.${nodeId}}"
    ]) (builtins.attrNames enabledNodes);
  };
}
