{
  config,
  lib,
  pkgs,
  ...
}:
let

  format = pkgs.formats.yaml { };

  rootDir = "/var/lib/crowdsec";
  stateDir = "${rootDir}/state";
  confDir = "/etc/crowdsec/";
  hubDir = "${stateDir}/hub/";
  notificationsDir = "${confDir}/notifications/";
  pluginDir = "${confDir}/plugins/";
  parsersDir = "${confDir}/parsers/";
  localPostOverflowsDir = "${confDir}/postoverflows/";
  localPostOverflowsS01WhitelistDir = "${localPostOverflowsDir}/s01-whitelist/";
  localScenariosDir = "${confDir}/scenarios/";
  localParsersS00RawDir = "${parsersDir}/s00-raw/";
  localParsersS01ParseDir = "${parsersDir}/s01-parse/";
  localParsersS02EnrichDir = "${parsersDir}/s02-enrich/";
  localContextsDir = "${confDir}/contexts/";

in
{

  options.services.crowdsec = {
    enable = lib.mkEnableOption "CrowdSec Security Engine";
    package = lib.mkPackageOption pkgs "crowdsec" { };
    autoUpdateService = lib.mkEnableOption "if `true` `cscli hub update` will be executed daily. See `https://docs.crowdsec.net/docs/cscli/cscli_hub_update/` for more information";

    group = lib.mkOption {
      default = "crowdsec";
      description = "The group to run crowdsec as";
      type = lib.types.str;
    };

    hub = lib.mkOption {
      default = { };

      description = ''
        Hub collections, parsers, AppSec rules, etc.
      '';

      type = lib.types.submodule {
        options = {
          appSecConfigs = lib.mkOption {
            default = [ ];
            description = "List of hub appsec configurations to install";
            example = [ "crowdsecurity/appsec-default" ];
            type = lib.types.listOf lib.types.str;
          };

          appSecRules = lib.mkOption {
            default = [ ];
            description = "List of hub appsec rules to install";
            example = [ "crowdsecurity/base-config" ];
            type = lib.types.listOf lib.types.str;
          };

          branch = lib.mkOption {
            default = "master";

            description = ''
              The git branch on which cscli is going to fetch configurations.

              See `https://docs.crowdsec.net/docs/configuration/crowdsec_configuration/#hub_branch` for more information.
            '';

            example = [
              "master"
              "v1.4.3"
              "v1.4.2"
            ];

            type = lib.types.str;
          };

          collections = lib.mkOption {
            default = [ ];
            description = "List of hub collections to install";
            example = [ "crowdsecurity/linux" ];
            type = lib.types.listOf lib.types.str;
          };

          parsers = lib.mkOption {
            default = [ ];
            description = "List of hub parsers to install";
            example = [ "crowdsecurity/sshd-logs" ];
            type = lib.types.listOf lib.types.str;
          };

          postOverflows = lib.mkOption {
            default = [ ];
            description = "List of hub postoverflows to install";
            example = [ "crowdsecurity/auditd-nix-wrappers-whitelist-process" ];
            type = lib.types.listOf lib.types.str;
          };

          scenarios = lib.mkOption {
            default = [ ];
            description = "List of hub scenarios to install";
            example = [ "crowdsecurity/ssh-bf" ];
            type = lib.types.listOf lib.types.str;
          };
        };
      };
    };

    localConfig = lib.mkOption {
      default = { };

      description = ''
        The configuration for a crowdsec security engine.
      '';

      type = lib.types.submodule {
        options = {
          acquisitions = lib.mkOption {
            default = [ ];

            description = ''
              A list of acquisition specifications, which define the data sources you want to be parsed.

              See <https://docs.crowdsec.net/docs/data_sources/intro> for details.
            '';

            example = [
              {
                journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];

                labels = {
                  type = "syslog";
                };

                source = "journalctl";
              }
            ];

            type = lib.types.listOf format.type;
          };

          contexts = lib.mkOption {
            default = [ ];

            description = ''
              A list of additional contexts to specify.

              See <https://docs.crowdsec.net/docs/next/log_processor/alert_context/intro> for details.
            '';

            example = [
              {
                context = {
                  method = [ "evt.Meta.http_verb" ];
                  status = [ "evt.Meta.http_status" ];
                  target_uri = [ "evt.Meta.http_path" ];
                  user_agent = [ "evt.Meta.http_user_agent" ];
                };
              }
            ];

            type = lib.types.listOf format.type;
          };

          notifications = lib.mkOption {
            default = [ ];

            description = ''
              A list of notifications to enable and use in your profiles. Note that for now, only the plugins shipped by default with CrowdSec are supported.

              See <https://docs.crowdsec.net/docs/notification_plugins/intro> for details.
            '';

            example = [
              {
                format = ''
                  {{.|toJson}}
                '';

                log_level = "info";
                method = "POST";
                name = "default_http_notification";
                type = "http";
                url = "https://example.com/hook";
              }
            ];

            type = lib.types.listOf format.type;
          };

          parsers = lib.mkOption {
            default = { };

            description = ''
              The set of parser specifications.

              See <https://docs.crowdsec.net/docs/parsers/intro> for details.
            '';

            type = lib.types.submodule {
              options = {
                s00Raw = lib.mkOption {
                  default = [ ];

                  description = ''
                    A list of stage s00-raw specifications. Most of the time, those are already included in the hub, but are presented here anyway.

                    See <https://docs.crowdsec.net/docs/parsers/intro> for details.
                  '';

                  type = lib.types.listOf format.type;
                };

                s01Parse = lib.mkOption {
                  default = [ ];

                  description = ''
                    A list of stage s01-parse specifications.

                    See <https://docs.crowdsec.net/docs/parsers/intro> for details.
                  '';

                  example = [
                    {
                      debug = true;
                      description = "Parsing custom service logs";
                      filter = "1=1";

                      grok = {
                        apply_on = "message";
                        pattern = "^%{DATA:some_data}$";
                      };

                      name = "example/custom-service-logs";
                      onsuccess = "next_stage";

                      statics = [
                        {
                          parsed = "is_my_custom_service";
                          value = "yes";
                        }
                      ];
                    }
                  ];

                  type = lib.types.listOf format.type;
                };

                s02Enrich = lib.mkOption {
                  default = [ ];

                  description = ''
                    A list of stage s02-enrich specifications. Inside this list, you can specify Parser Whitelists.

                    See <https://docs.crowdsec.net/docs/whitelist/intro> for details.
                  '';

                  example = [
                    {
                      description = "Whitelist parse events from my IPs";
                      name = "myips/whitelist";

                      whitelist = {
                        cidr = [
                          "1.2.3.0/24"
                        ];

                        ip = [
                          "1.2.3.4"
                        ];

                        reason = "My IP ranges";
                      };
                    }
                  ];

                  type = lib.types.listOf format.type;
                };
              };
            };
          };

          patterns = lib.mkOption {
            default = [ ];

            description = ''
              A list of files containing custom grok patterns.
            '';

            example = lib.literalExpression ''
              [ (pkgs.writeTextDir "custom_service_logs" (builtins.readFile ./custom_service_logs)) ]
            '';

            type = lib.types.listOf lib.types.package;
          };

          postOverflows = lib.mkOption {
            default = { };

            description = ''
              The set of Postoverflows specifications.

              See <https://docs.crowdsec.net/docs/next/log_processor/parsers/intro#postoverflows> for details.
            '';

            type = lib.types.submodule {
              options = {
                s01Whitelist = lib.mkOption {
                  default = [ ];

                  description = ''
                    A list of stage s01-whitelist specifications. Inside this list, you can specify Postoverflows Whitelists.

                    See <https://docs.crowdsec.net/docs/whitelist/intro> for details.
                  '';

                  example = [
                    {
                      description = "Whitelist my reverse DNS";
                      name = "postoverflows/whitelist_my_dns_domain";

                      whitelist = {
                        expression = [
                          "evt.Enriched.reverse_dns endsWith '.local.'"
                        ];

                        reason = "Don't ban me";
                      };
                    }
                  ];

                  type = lib.types.listOf format.type;
                };
              };
            };
          };

          profiles = lib.mkOption {
            default = [
              {
                decisions = [
                  {
                    duration = "4h";
                    type = "ban";
                  }
                ];

                filters = [
                  "Alert.Remediation == true && Alert.GetScope() == 'Ip'"
                ];

                name = "default_ip_remediation";
                on_success = "break";
              }
              {
                decisions = [
                  {
                    duration = "4h";
                    type = "ban";
                  }
                ];

                filters = [
                  "Alert.Remediation == true && Alert.GetScope() == 'Range'"
                ];

                name = "default_range_remediation";
                on_success = "break";
              }
            ];

            description = ''
              A list of profiles to enable.

              See <https://docs.crowdsec.net/docs/profiles/intro> for more details.
            '';

            example = [
              {
                decisions = [
                  {
                    duration = "4h";
                    type = "ban";
                  }
                ];

                filters = [
                  "Alert.Remediation == true && Alert.GetScope() == 'Ip'"
                ];

                name = "default_ip_remediation";
                on_success = "break";
              }
              {
                decisions = [
                  {
                    duration = "4h";
                    type = "ban";
                  }
                ];

                filters = [
                  "Alert.Remediation == true && Alert.GetScope() == 'Range'"
                ];

                name = "default_range_remediation";
                on_success = "break";
              }
            ];

            type = lib.types.listOf format.type;
          };

          scenarios = lib.mkOption {
            default = [ ];

            description = ''
              A list of scenarios specifications.

              See <https://docs.crowdsec.net/docs/scenarios/intro> for details.
            '';

            example = [
              {
                capacity = 5;
                description = "Detect myservice bruteforce";
                filter = "evt.Meta.log_type == 'myservice_failed_auth'";
                groupby = "evt.Meta.source_ip";
                leakspeed = "10s";
                name = "crowdsecurity/myservice-bf";
                type = "leaky";
              }
            ];

            type = lib.types.listOf format.type;
          };
        };
      };
    };

    name = lib.mkOption {
      default = config.networking.hostName;
      defaultText = lib.literalExpression "config.networking.hostName";

      description = ''
        Name of the machine when registering it at the central or local api.
      '';

      type = lib.types.str;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Whether to automatically open firewall ports for `crowdsec`.
      '';

      example = true;
      type = lib.types.bool;
    };

    settings = lib.mkOption {
      description = ''
        Set of various configuration attributes
      '';

      type = lib.types.submodule {
        options = {
          capi = lib.mkOption {
            default = { };

            description = ''
              CAPI Configuration attributes
            '';

            type = lib.types.submodule {
              options = {
                credentialsFile = lib.mkOption {
                  default = null;

                  description = ''
                    The CAPI credential file to use.
                  '';

                  example = "/run/crowdsec/capi.yaml";
                  type = lib.types.nullOr lib.types.path;
                };
              };
            };
          };

          console = lib.mkOption {
            default = { };

            description = ''
              Console Configuration attributes
            '';

            type = lib.types.submodule {
              options = {
                configuration = lib.mkOption {
                  default = {
                    share_context = false;
                    share_custom = false;
                    share_manual_decisions = false;
                    share_tainted = false;
                  };

                  description = ''
                    Attributes inside the console.yaml file.
                  '';

                  type = format.type;
                };

                tokenFile = lib.mkOption {
                  default = null;

                  description = ''
                    The Console Token file to use.
                  '';

                  example = "/run/crowdsec/console_token.yaml";
                  type = lib.types.nullOr lib.types.path;
                };
              };
            };
          };

          general = lib.mkOption {
            default = { };

            description = ''
              Settings for the main CrowdSec configuration file.

              Refer to the defaults at <https://github.com/crowdsecurity/crowdsec/blob/master/config/config.yaml>.
            '';

            type = format.type;
          };

          lapi = lib.mkOption {
            default = { };

            description = ''
              LAPI Configuration attributes
            '';

            type = lib.types.submodule {
              options = {
                credentialsFile = lib.mkOption {
                  default = null;

                  description = ''
                    The LAPI credential file to use.
                  '';

                  example = "/run/crowdsec/lapi.yaml";
                  type = lib.types.nullOr lib.types.path;
                };
              };
            };
          };

          simulation = lib.mkOption {
            default = {
              simulation = false;
            };

            description = ''
              Attributes inside the simulation.yaml file.
            '';

            type = format.type;
          };
        };
      };
    };

    user = lib.mkOption {
      default = "crowdsec";
      description = "The user to run crowdsec as";
      type = lib.types.str;
    };
  };

  config =
    let
      cfg = config.services.crowdsec;
      configFile = format.generate "crowdsec.yaml" cfg.settings.general;
      simulationFile = format.generate "simulation.yaml" cfg.settings.simulation;
      consoleFile = format.generate "console.yaml" cfg.settings.console.configuration;
      patternsDir = pkgs.buildPackages.symlinkJoin {
        name = "crowdsec-patterns";

        paths = [
          cfg.localConfig.patterns
          "${lib.attrsets.getOutput "out" cfg.package}/share/crowdsec/config/patterns/"
        ];
      };

      cscli = pkgs.writeShellScriptBin "cscli" ''
        set -euo pipefail
        # cscli needs crowdsec on it's path in order to be able to run `cscli explain`
        export PATH="$PATH:${lib.makeBinPath [ cfg.package ]}"
                sudo=exec
        if [ "$USER" != "${cfg.user}" ]; then
          ${
            if config.security.sudo.enable then
              "sudo='exec ${config.security.wrapperDir}/sudo -u ${cfg.user}'"
            else
              ">&2 echo 'Aborting, cscli must be run as user `${cfg.user}`!'; exit 2"
          }
        fi
        $sudo ${lib.getExe' cfg.package "cscli"} -c=${configFile} "$@"
      '';

      localScenariosMap = (map (format.generate "scenario.yaml") cfg.localConfig.scenarios);
      localParsersS00RawMap = (
        map (format.generate "parsers-s00-raw.yaml") cfg.localConfig.parsers.s00Raw
      );
      localParsersS01ParseMap = (
        map (format.generate "parsers-s01-parse.yaml") cfg.localConfig.parsers.s01Parse
      );
      localParsersS02EnrichMap = (
        map (format.generate "parsers-s02-enrich.yaml") cfg.localConfig.parsers.s02Enrich
      );
      localPostOverflowsS01WhitelistMap = (
        map (format.generate "postoverflows-s01-whitelist.yaml") cfg.localConfig.postOverflows.s01Whitelist
      );
      localContextsMap = (map (format.generate "context.yaml") cfg.localConfig.contexts);
      localNotificationsMap = (map (format.generate "notification.yaml") cfg.localConfig.notifications);
      localProfilesFile = pkgs.writeText "local_profiles.yaml" ''
        ---
        ${lib.strings.concatMapStringsSep "\n---\n" builtins.toJSON cfg.localConfig.profiles}
        ---
      '';
      localAcquisisionFile = pkgs.writeText "local_acquisisions.yaml" ''
        ---
        ${lib.strings.concatMapStringsSep "\n---\n" builtins.toJSON cfg.localConfig.acquisitions}
        ---
      '';

      scriptArray = [
        "set -euo pipefail"
        "${lib.getExe' pkgs.coreutils "mkdir"} -p '${hubDir}'"
        "${lib.getExe cscli} hub update"
      ]
      ++ lib.optionals (cfg.hub.collections != [ ]) [
        "${lib.getExe cscli} collections install ${
          lib.strings.concatMapStringsSep " " (x: lib.escapeShellArg x) cfg.hub.collections
        }"
      ]
      ++ lib.optionals (cfg.hub.scenarios != [ ]) [
        "${lib.getExe cscli} scenarios install ${
          lib.strings.concatMapStringsSep " " (x: lib.escapeShellArg x) cfg.hub.scenarios
        }"
      ]
      ++ lib.optionals (cfg.hub.parsers != [ ]) [
        "${lib.getExe cscli} parsers install ${
          lib.strings.concatMapStringsSep " " (x: lib.escapeShellArg x) cfg.hub.parsers
        }"
      ]
      ++ lib.optionals (cfg.hub.postOverflows != [ ]) [
        "${lib.getExe cscli} postoverflows install ${
          lib.strings.concatMapStringsSep " " (x: lib.escapeShellArg x) cfg.hub.postOverflows
        }"
      ]
      ++ lib.optionals (cfg.hub.appSecConfigs != [ ]) [
        "${lib.getExe cscli} appsec-configs install ${
          lib.strings.concatMapStringsSep " " (x: lib.escapeShellArg x) cfg.hub.appSecConfigs
        }"
      ]
      ++ lib.optionals (cfg.hub.appSecRules != [ ]) [
        "${lib.getExe cscli} appsec-rules install ${
          lib.strings.concatMapStringsSep " " (x: lib.escapeShellArg x) cfg.hub.appSecRules
        }"
      ]
      ++ lib.optionals (cfg.settings.general.api.server.enable) [
        ''
          if [ ! -s "${cfg.settings.general.api.client.credentials_path}" ]; then
            ${lib.getExe cscli} machine add "${cfg.name}" --auto
          fi
        ''
      ]
      ++ lib.optionals (cfg.settings.capi.credentialsFile != null) [
        ''
          if ! ${lib.getExe pkgs.gnugrep} -q password "${cfg.settings.capi.credentialsFile}" ]; then
            ${lib.getExe cscli} capi register
          fi
        ''
      ]
      ++ lib.optionals (cfg.settings.console.tokenFile != null) [
        ''
          if [ ! -e "${cfg.settings.console.tokenFile}" ]; then
            ${lib.getExe cscli} console enroll "$(${lib.getExe' pkgs.coreutils "cat"} ${cfg.settings.console.tokenFile})" --name ${cfg.name}
          fi
        ''
      ];

      setupScript = pkgs.writeShellScriptBin "crowdsec-setup" (
        lib.strings.concatStringsSep "\n" scriptArray
      );

    in
    lib.mkIf (cfg.enable) {

      environment = {
        systemPackages = [ cscli ];
      };

      networking.firewall.allowedTCPPorts =
        let
          parsePortFromURLOption =
            url: option:
            builtins.addErrorContext "extracting a port from URL: `${option}` requires a port to be specified, but we failed to parse a port from '${url}'" (
              lib.strings.toInt (lib.last (lib.strings.splitString ":" url))
            );
        in
        lib.mkIf cfg.openFirewall [
          cfg.settings.general.prometheus.listen_port
          (parsePortFromURLOption cfg.settings.general.api.server.listen_uri "config.services.crowdsec.settings.general.api.server.listen_uri")
        ];

      services.crowdsec.settings.general = {
        api = {
          client = {
            credentials_path = cfg.settings.lapi.credentialsFile;
          };

          server = {
            enable = lib.mkDefault false;
            console_path = lib.mkDefault consoleFile;
            listen_uri = lib.mkDefault "127.0.0.1:8080";

            online_client = lib.mkDefault {
              credentials_path = cfg.settings.capi.credentialsFile;

              pull = lib.mkDefault {
                blocklists = lib.mkDefault true;
                community = lib.mkDefault true;
              };

              sharing = lib.mkDefault true;
            };

            profiles_path = lib.mkDefault localProfilesFile;
          };
        };

        common = {
          log_media = "stdout";
        };

        config_paths = {
          config_dir = confDir;
          data_dir = stateDir;
          hub_dir = hubDir;
          index_path = lib.strings.normalizePath "${stateDir}/hub/.index.json";
          notification_dir = notificationsDir;
          pattern_dir = patternsDir;
          plugin_dir = pluginDir;
          simulation_path = simulationFile;
        };

        crowdsec_service = {
          enable = lib.mkDefault true;
          acquisition_path = lib.mkDefault localAcquisisionFile;
        };

        cscli = {
          hub_branch = cfg.hub.branch;
        };

        db_config = {
          db_path = lib.mkDefault (lib.strings.normalizePath "${stateDir}/crowdsec.db");
          type = lib.mkDefault "sqlite";
          use_wal = lib.mkDefault true;
        };

        prometheus = {
          enabled = lib.mkDefault true;
          level = lib.mkDefault "full";
          listen_addr = lib.mkDefault "127.0.0.1";
          listen_port = lib.mkDefault 6060;
        };
      };

      systemd.packages = [ cfg.package ];

      systemd.services = {
        crowdsec = {
          after = [ "network-online.target" ];
          description = "CrowdSec agent";

          environment = {
            LANG = "C";
            LC_ALL = "C";
          };

          path = lib.mkForce [ ];

          serviceConfig = {
            CapabilityBoundingSet = [
              " " # Reset all capabilities to an empty set
              "CAP_SYSLOG" # Add capability to read syslog
            ];

            DevicePolicy = "closed";
            DynamicUser = true;

            ExecReload = [
              " " # This is needed to clear the ExecReload definitions from upstream
            ];

            ExecStart = [
              " " # This is needed to clear the ExecStart definitions from upstream
              "${lib.getExe' cfg.package "crowdsec"} -c ${configFile} -info"
            ];

            ExecStartPre = [
              " " # This is needed to clear the ExecStartPre definitions from upstream
              "${lib.getExe setupScript}"
              "${lib.getExe' cfg.package "crowdsec"} -c ${configFile} -t -error"
            ];

            Group = cfg.group;
            LimitNOFILE = 65536;
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

            ReadWritePaths = [
              rootDir
              confDir
            ];

            RemoveIPC = true;
            RestartSec = 60;

            RestrictAddressFamilies = [
              " " # This is needed to clear the RestrictAddressFamilies existing definitions
              "none" # Remove all addresses families
              "AF_UNIX"
              "AF_INET"
              "AF_INET6"
            ];

            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SystemCallArchitectures = "native";

            SystemCallFilter = [
              " " # This is needed to clear the SystemCallFilter existing definitions
              "~@reboot"
              "~@swap"
              "~@obsolete"
              "~@mount"
              "~@module"
              "~@debug"
              "~@cpu-emulation"
              "~@clock"
              "~@raw-io"
              "~@privileged"
              "~@resources"
            ];

            Type = "notify";
            UMask = "0077";
            User = cfg.user;
          };

          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
        };

        crowdsec-update-hub = lib.mkIf (cfg.autoUpdateService) {
          description = "Update the crowdsec hub index";

          serviceConfig = {
            CapabilityBoundingSet = [
              " " # Reset all capabilities to an empty set
            ];

            DevicePolicy = "closed";
            DynamicUser = true;
            ExecStart = "${lib.getExe cscli} --error hub update";
            ExecStartPost = "systemctl reload crowdsec.service";
            Group = cfg.group;
            LimitNOFILE = 65536;
            LockPersonality = true;
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateTmp = true;
            PrivateUsers = true;
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "invisible";
            ProtectSystem = "strict";

            ReadWritePaths = [
              rootDir
              confDir
            ];

            RemoveIPC = true;

            RestrictAddressFamilies = [
              " " # This is needed to clear the RestrictAddressFamilies existing definitions
              "none" # Remove all addresses families
              "AF_UNIX"
              "AF_INET"
              "AF_INET6"
            ];

            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SystemCallArchitectures = "native";

            SystemCallFilter = [
              " " # This is needed to clear the SystemCallFilter existing definitions
              "~@reboot"
              "~@swap"
              "~@obsolete"
              "~@mount"
              "~@module"
              "~@debug"
              "~@cpu-emulation"
              "~@clock"
              "~@raw-io"
              "~@privileged"
              "~@resources"
            ];

            Type = "oneshot";
            UMask = "0077";
            User = cfg.user;
          };
        };
      };

      systemd.timers.crowdsec-update-hub = lib.mkIf (cfg.autoUpdateService) {
        description = "Update the crowdsec hub index";

        timerConfig = {
          OnCalendar = "daily";
          Persistent = "yes";
          RandomizedDelaySec = 300;
          Unit = "crowdsec-update-hub.service";
        };

        wantedBy = [ "timers.target" ];
      };

      systemd.tmpfiles.settings = {
        "10-crowdsec" =

          builtins.listToAttrs (
            map
              (dirName: {
                inherit cfg;
                name = lib.strings.normalizePath dirName;

                value = {
                  d = {
                    group = cfg.group;
                    mode = "0750";
                    user = cfg.user;
                  };
                };
              })
              [
                stateDir
                hubDir
                confDir
                localScenariosDir
                localPostOverflowsDir
                localPostOverflowsS01WhitelistDir
                parsersDir
                localParsersS00RawDir
                localParsersS01ParseDir
                localParsersS02EnrichDir
                localContextsDir
                notificationsDir
                pluginDir
              ]
          )
          // builtins.listToAttrs (
            map (scenarioFile: {
              inherit cfg;
              name = lib.strings.normalizePath "${localScenariosDir}/${builtins.unsafeDiscardStringContext (baseNameOf scenarioFile)}";

              value = {
                link = {
                  argument = "${scenarioFile}";
                  type = "L+";
                };
              };
            }) localScenariosMap
          )
          // builtins.listToAttrs (
            map (parser: {
              inherit cfg;
              name = lib.strings.normalizePath "${localParsersS00RawDir}/${builtins.unsafeDiscardStringContext (baseNameOf parser)}";

              value = {
                link = {
                  argument = "${parser}";
                  type = "L+";
                };
              };
            }) localParsersS00RawMap
          )
          // builtins.listToAttrs (
            map (parser: {
              inherit cfg;
              name = lib.strings.normalizePath "${localParsersS01ParseDir}/${builtins.unsafeDiscardStringContext (baseNameOf parser)}";

              value = {
                link = {
                  argument = "${parser}";
                  type = "L+";
                };
              };
            }) localParsersS01ParseMap
          )
          // builtins.listToAttrs (
            map (parser: {
              inherit cfg;
              name = lib.strings.normalizePath "${localParsersS02EnrichDir}/${builtins.unsafeDiscardStringContext (baseNameOf parser)}";

              value = {
                link = {
                  argument = "${parser}";
                  type = "L+";
                };
              };
            }) localParsersS02EnrichMap
          )
          // builtins.listToAttrs (
            map (postoverflow: {
              inherit cfg;
              name = lib.strings.normalizePath "${localPostOverflowsS01WhitelistDir}/${builtins.unsafeDiscardStringContext (baseNameOf postoverflow)}";

              value = {
                link = {
                  argument = "${postoverflow}";
                  type = "L+";
                };
              };
            }) localPostOverflowsS01WhitelistMap
          )
          // builtins.listToAttrs (
            map (context: {
              inherit cfg;
              name = lib.strings.normalizePath "${localContextsDir}/${builtins.unsafeDiscardStringContext (baseNameOf context)}";

              value = {
                link = {
                  argument = "${context}";
                  type = "L+";
                };
              };
            }) localContextsMap
          )
          // builtins.listToAttrs (
            map (notification: {
              inherit cfg;
              name = lib.strings.normalizePath "${notificationsDir}/${builtins.unsafeDiscardStringContext (baseNameOf notification)}";

              value = {
                link = {
                  argument = "${notification}";
                  type = "L+";
                };
              };
            }) localNotificationsMap
          );
      };

      users.groups.${cfg.group} = lib.mapAttrs (name: lib.mkDefault) { };

      users.users.${cfg.user} = {
        description = lib.mkDefault "CrowdSec service user";
        extraGroups = [ "systemd-journal" ];
        group = cfg.group;
        isSystemUser = true;
        name = cfg.user;
      };

      warnings =
        [ ]
        ++ lib.optionals (cfg.localConfig.profiles == [ ]) [
          "By not specifying profiles in services.crowdsec.localConfig.profiles, CrowdSec will not react to any alert by default."
        ]
        ++ lib.optionals (cfg.localConfig.acquisitions == [ ]) [
          "By not specifying acquisitions in services.crowdsec.localConfig.acquisitions, CrowdSec will not look for any data source."
        ];
    };

  meta = {
    maintainers = with lib.maintainers; [
      M0ustach3
      tornax
      jk
    ];
  };
}
