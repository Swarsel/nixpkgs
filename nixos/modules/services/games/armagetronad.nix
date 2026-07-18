{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkMerge
    literalExpression
    ;
  inherit (lib)
    mapAttrsToList
    filterAttrs
    unique
    types
    ;

  mkValueStringArmagetron =
    with lib;
    v:
    if isInt v then
      toString v
    else if isFloat v then
      toString v
    else if isString v then
      v
    else if true == v then
      "1"
    else if false == v then
      "0"
    else if null == v then
      ""
    else
      throw "unsupported type: ${builtins.typeOf v}: ${(lib.generators.toPretty { } v)}";

  settingsFormat = pkgs.formats.keyValue {
    listsAsDuplicateKeys = true;

    mkKeyValue = lib.generators.mkKeyValueDefault {
      mkValueString = mkValueStringArmagetron;
    } " ";
  };

  cfg = config.services.armagetronad;
  enabledServers = lib.filterAttrs (n: v: v.enable) cfg.servers;
  nameToId = serverName: "armagetronad-${serverName}";
  getStateDirectory = serverName: "armagetronad/${serverName}";
  getServerRoot = serverName: "/var/lib/${getStateDirectory serverName}";
in
{
  options = {
    services.armagetronad = {
      servers = mkOption {
        default = { };
        description = "Armagetron server definitions.";

        type = types.attrsOf (
          types.submodule {
            options = {
              enable = mkEnableOption "armagetronad";

              package = lib.mkPackageOption pkgs "armagetronad-dedicated" {
                example = ''
                  pkgs.armagetronad."0.2.9-sty+ct+ap".dedicated
                '';

                extraDescription = ''
                  Ensure that you use a derivation which contains the path `bin/armagetronad-dedicated`.
                '';
              };

              dns = mkOption {
                default = null;
                description = "DNS address to use for this server. Optional.";
                type = types.nullOr types.str;
              };

              host = mkOption {
                default = "0.0.0.0";
                description = "Host to listen on. Used for SERVER_IP.";
                type = types.str;
              };

              name = mkOption {
                description = "The name of this server.";
                type = types.str;
              };

              openFirewall = mkOption {
                default = true;
                description = "Set to true to open the configured UDP port for Armagetron Advanced.";
                type = types.bool;
              };

              port = mkOption {
                default = 4534;
                description = "Port to listen on. Used for SERVER_PORT.";
                type = types.port;
              };

              roundSettings = mkOption {
                default = { };

                description = ''
                  Armagetron Advanced server per-round configuration. Refer to:
                  <https://wiki.armagetronad.org/index.php?title=Console_Commands>
                  or `armagetronad-dedicated --doc` for a list.

                  This attrset is used to populate `everytime.cfg`; see:
                  <https://wiki.armagetronad.org/index.php/Configuration_Files>
                '';

                example = literalExpression ''
                  {
                    SAY = [
                      "Hosted on NixOS"
                      "https://nixos.org"
                      "iD Tech High Rubber rul3z!! Happy New Year 2008!!1"
                    ];
                  }
                '';

                type = settingsFormat.type;
              };

              settings = mkOption {
                default = { };

                description = ''
                  Armagetron Advanced server rules configuration. Refer to:
                  <https://wiki.armagetronad.org/index.php?title=Console_Commands>
                  or `armagetronad-dedicated --doc` for a list.

                  This attrset is used to populate `settings_custom.cfg`; see:
                  <https://wiki.armagetronad.org/index.php/Configuration_Files>
                '';

                example = literalExpression ''
                  {
                    CYCLE_RUBBER = 40;
                  }
                '';

                type = settingsFormat.type;
              };
            };
          }
        );
      };
    };
  };

  config = mkIf (enabledServers != { }) {
    networking.firewall.allowedUDPPorts = unique (
      mapAttrsToList (serverName: serverCfg: serverCfg.port) (
        filterAttrs (serverName: serverCfg: serverCfg.openFirewall) enabledServers
      )
    );

    systemd.services = mkMerge (
      mapAttrsToList (
        serverName: serverCfg:
        let
          serverId = nameToId serverName;
        in
        {
          "armagetronad-${serverName}" = {
            after = [
              "basic.target"
              "network.target"
              "multi-user.target"
            ];

            description = "Armagetron Advanced Dedicated Server for ${serverName}";

            serviceConfig =
              let
                serverRoot = getServerRoot serverName;
              in
              {
                CapabilityBoundingSet = "";
                ExecStart = "${lib.getExe serverCfg.package} --daemon --input ${serverRoot}/input --userdatadir ${serverRoot}/data --userconfigdir ${serverRoot}/settings --vardir ${serverRoot}/var --autoresourcedir ${serverRoot}/resource";
                Group = serverId;
                LockPersonality = true;
                NoNewPrivileges = true;
                PrivateDevices = true;
                PrivateTmp = true;
                PrivateUsers = true;
                ProtectClock = true;
                ProtectControlGroups = true;
                ProtectHome = true;
                ProtectHostname = true;
                ProtectKernelLogs = true;
                ProtectKernelModules = true;
                ProtectKernelTunables = true;
                ProtectProc = "invisible";
                ProtectSystem = "strict";
                Restart = "on-failure";
                RestrictNamespaces = true;
                RestrictSUIDSGID = true;
                StateDirectory = getStateDirectory serverName;
                Type = "simple";
                User = serverId;
              };

            wantedBy = [ "multi-user.target" ];
            wants = [ "basic.target" ];
          };
        }
      ) enabledServers
    );

    systemd.tmpfiles.settings = mkMerge (
      mapAttrsToList (
        serverName: serverCfg:
        let
          serverId = nameToId serverName;
          serverRoot = getServerRoot serverName;
          serverInfo = (
            {
              SERVER_IP = serverCfg.host;
              SERVER_NAME = serverCfg.name;
              SERVER_PORT = serverCfg.port;
            }
            // (lib.optionalAttrs (serverCfg.dns != null) { SERVER_DNS = serverCfg.dns; })
          );
          customSettings = serverCfg.settings;
          everytimeSettings = serverCfg.roundSettings;

          serverInfoCfg = settingsFormat.generate "server_info.${serverName}.cfg" serverInfo;
          customSettingsCfg = settingsFormat.generate "settings_custom.${serverName}.cfg" customSettings;
          everytimeSettingsCfg = settingsFormat.generate "everytime.${serverName}.cfg" everytimeSettings;
        in
        {
          "10-armagetronad-${serverId}" = {
            "${serverRoot}/data" = {
              d = {
                group = serverId;
                mode = "0750";
                user = serverId;
              };
            };

            "${serverRoot}/input" = {
              "f+" = {
                group = serverId;
                mode = "0640";
                user = serverId;
              };
            };

            "${serverRoot}/resource" = {
              d = {
                group = serverId;
                mode = "0750";
                user = serverId;
              };
            };

            "${serverRoot}/settings" = {
              d = {
                group = serverId;
                mode = "0750";
                user = serverId;
              };
            };

            "${serverRoot}/settings/everytime.cfg" = {
              "L+" = {
                argument = "${everytimeSettingsCfg}";
              };
            };

            "${serverRoot}/settings/server_info.cfg" = {
              "L+" = {
                argument = "${serverInfoCfg}";
              };
            };

            "${serverRoot}/settings/settings_custom.cfg" = {
              "L+" = {
                argument = "${customSettingsCfg}";
              };
            };

            "${serverRoot}/var" = {
              d = {
                group = serverId;
                mode = "0750";
                user = serverId;
              };
            };
          };
        }
      ) enabledServers
    );

    users.groups = mkMerge (
      mapAttrsToList (serverName: serverCfg: {
        ${nameToId serverName} = { };
      }) enabledServers
    );

    users.users = mkMerge (
      mapAttrsToList (serverName: serverCfg: {
        ${nameToId serverName} = {
          description = "Armagetron Advanced dedicated user for server ${serverName}";
          group = nameToId serverName;
          isSystemUser = true;
        };
      }) enabledServers
    );
  };
}
