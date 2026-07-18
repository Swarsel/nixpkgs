{
  config,
  lib,
  pkgs,
  ...
}:

let
  settingsFormat = pkgs.formats.yaml { };

  upperConfig = config;
  cfg = config.services.mautrix-meta;
  upperCfg = cfg;

  fullDataDir = cfg: "/var/lib/${cfg.dataDir}";

  settingsFile = cfg: "${fullDataDir cfg}/config.yaml";
  settingsFileUnsubstituted = cfg: settingsFormat.generate "mautrix-meta-config.yaml" cfg.settings;

  metaName = name: "mautrix-meta-${name}";

  enabledInstances = lib.filterAttrs (
    name: config: config.enable
  ) config.services.mautrix-meta.instances;
  registerToSynapseInstances = lib.filterAttrs (
    name: config: config.enable && config.registerToSynapse
  ) config.services.mautrix-meta.instances;
in
{
  options = {
    services.mautrix-meta = {

      package = lib.mkPackageOption pkgs "mautrix-meta" { };

      instances = lib.mkOption {
        description = ''
          Configuration of multiple `mautrix-meta` instances.
          `services.mautrix-meta.instances.facebook` and `services.mautrix-meta.instances.instagram`
          come preconfigured with network.mode, appservice.id, bot username, display name and avatar.
        '';

        example = ''
          {
            facebook = {
              enable = true;
              settings = {
                homeserver.domain = "example.com";
              };
            };

            instagram = {
              enable = true;
              settings = {
                homeserver.domain = "example.com";
              };
            };

            messenger = {
              enable = true;
              settings = {
                network.mode = "messenger";
                homeserver.domain = "example.com";
                appservice = {
                  id = "messenger";
                  bot = {
                    username = "messengerbot";
                    displayname = "Messenger bridge bot";
                    avatar = "mxc://maunium.net/ygtkteZsXnGJLJHRchUwYWak";
                  };
                };
              };
            };
          }
        '';

        type = lib.types.attrsOf (
          lib.types.submodule (
            { config, name, ... }:
            {

              options = {

                enable = lib.mkEnableOption "Mautrix-Meta, a Matrix <-> Facebook and Matrix <-> Instagram hybrid puppeting/relaybot bridge";

                dataDir = lib.mkOption {
                  default = metaName name;

                  description = ''
                    Path to the directory with database, registration, and other data for the bridge service.
                    This path is relative to `/var/lib`, it cannot start with `../` (it cannot be outside of `/var/lib`).
                  '';

                  type = lib.types.str;
                };

                environmentFile = lib.mkOption {
                  default = null;

                  description = ''
                    File containing environment variables to substitute when copying the configuration
                    out of Nix store to the `services.mautrix-meta.dataDir`.

                    Can be used for storing the secrets without making them available in the Nix store.

                    For example, you can set `services.mautrix-meta.settings.appservice.as_token = "$MAUTRIX_META_APPSERVICE_AS_TOKEN"`
                    and then specify `MAUTRIX_META_APPSERVICE_AS_TOKEN="{token}"` in the environment file.
                    This value will get substituted into the configuration file as as token.
                  '';

                  type = lib.types.nullOr lib.types.path;
                };

                registerToSynapse = lib.mkOption {
                  default = true;

                  description = ''
                    Whether to add registration file to `services.matrix-synapse.settings.app_service_config_files` and
                    make Synapse wait for registration service.
                  '';

                  type = lib.types.bool;
                };

                registrationFile = lib.mkOption {
                  description = ''
                    Path to the yaml registration file of the appservice.
                  '';

                  readOnly = true;
                  type = lib.types.path;
                };

                registrationServiceUnit = lib.mkOption {
                  description = ''
                    The registration service that generates the registration file.

                    Systemd unit (a service or a target) for other services to depend on if they
                    need to be started after mautrix-meta registration service.

                    This option is useful as the actual parent unit for all matrix-synapse processes
                    changes when configuring workers.
                  '';

                  readOnly = true;
                  type = lib.types.str;
                };

                serviceDependencies = lib.mkOption {
                  default = [
                    config.registrationServiceUnit
                  ]
                  ++ (lib.lists.optional upperConfig.services.matrix-synapse.enable upperConfig.services.matrix-synapse.serviceUnit)
                  ++ (lib.lists.optional upperConfig.services.matrix-conduit.enable "matrix-conduit.service")
                  ++ (lib.lists.optional upperConfig.services.dendrite.enable "dendrite.service");

                  defaultText = ''
                    [ config.registrationServiceUnit ] ++
                    (lib.lists.optional upperConfig.services.matrix-synapse.enable upperConfig.services.matrix-synapse.serviceUnit) ++
                    (lib.lists.optional upperConfig.services.matrix-conduit.enable "matrix-conduit.service") ++
                    (lib.lists.optional upperConfig.services.dendrite.enable "dendrite.service");
                  '';

                  description = ''
                    List of Systemd services to require and wait for when starting the application service.
                  '';

                  type = lib.types.listOf lib.types.str;
                };

                serviceUnit = lib.mkOption {
                  description = ''
                    The systemd unit (a service or a target) for other services to depend on if they
                    need to be started after matrix-synapse.

                    This option is useful as the actual parent unit for all matrix-synapse processes
                    changes when configuring workers.
                  '';

                  readOnly = true;
                  type = lib.types.str;
                };

                settings = lib.mkOption rec {
                  inherit (settingsFormat) type;
                  apply = lib.recursiveUpdate default;

                  default = {
                    appservice = {
                      address = "http://${config.settings.appservice.hostname}:${toString config.settings.appservice.port}";

                      bot = {
                        username = "";
                      };

                      hostname = "localhost";
                      id = "";
                      port = 29319;
                    };

                    bridge = {
                      permissions = { };
                    };

                    database = {
                      type = "sqlite3-fk-wal";
                      uri = "file:${fullDataDir config}/mautrix-meta.db?_txlock=immediate";
                    };

                    # Enable encryption by default to make the bridge more secure
                    encryption = {
                      allow = true;
                      default = true;

                      # Recommended options from mautrix documentation
                      # for additional security.
                      delete_keys = {
                        delete_fully_used_on_decrypt = true;
                        delete_on_device_delete = true;
                        delete_outdated_inbound = true;
                        delete_prev_on_new_session = true;
                        dont_store_outbound = true;
                        periodically_delete_expired = true;
                        ratchet_on_decrypt = true;
                      };

                      # TODO: This effectively disables encryption. But this is the value provided when a <0.4 config is migrated. Changing it will corrupt the database.
                      # https://github.com/mautrix/meta/blob/f5440b05aac125b4c95b1af85635a717cbc6dd0e/cmd/mautrix-meta/legacymigrate.go#L24
                      # If you wish to encrypt the local database you should set this to an environment variable substitution and reset the bridge or somehow migrate the DB.
                      pickle_key = "mautrix.bridge.e2ee";
                      require = true;

                      verification_levels = {
                        receive = "cross-signed-tofu";
                        send = "cross-signed-tofu";
                        share = "cross-signed-tofu";
                      };
                    };

                    homeserver = {
                      address = "";
                      domain = "";
                      software = "standard";
                    };

                    logging = {
                      min_level = "info";

                      writers = lib.singleton {
                        format = "pretty-colored";
                        time_format = " ";
                        type = "stdout";
                      };
                    };

                    network = {
                      mode = "";
                    };
                  };

                  defaultText = ''
                    {
                      homeserver = {
                        software = "standard";
                        address = "https://''${config.settings.homeserver.domain}";
                      };

                      appservice = {
                        database = {
                          type = "sqlite3-fk-wal";
                          uri = "file:''${fullDataDir config}/mautrix-meta.db?_txlock=immediate";
                        };

                        hostname = "localhost";
                        port = 29319;
                        address = "http://''${config.settings.appservice.hostname}:''${toString config.settings.appservice.port}";
                      };

                      bridge = {
                        # Require encryption by default to make the bridge more secure
                        encryption = {
                          allow = true;
                          default = true;
                          require = true;

                          # Recommended options from mautrix documentation
                          # for optimal security.
                          delete_keys = {
                            dont_store_outbound = true;
                            ratchet_on_decrypt = true;
                            delete_fully_used_on_decrypt = true;
                            delete_prev_on_new_session = true;
                            delete_on_device_delete = true;
                            periodically_delete_expired = true;
                            delete_outdated_inbound = true;
                          };

                          verification_levels = {
                            receive = "cross-signed-tofu";
                            send = "cross-signed-tofu";
                            share = "cross-signed-tofu";
                          };
                        };
                      };

                      logging = {
                        min_level = "info";
                        writers = lib.singleton {
                          type = "stdout";
                          format = "pretty-colored";
                          time_format = " ";
                        };
                      };
                    };
                  '';

                  description = ''
                    {file}`config.yaml` configuration as a Nix attribute set.
                    Configuration options should match those described in
                    [example-config.yaml](https://github.com/mautrix/meta/blob/main/example-config.yaml).

                    Secret tokens should be specified using {option}`environmentFile`
                    instead
                  '';
                };
              };

              config = {
                registrationFile = (fullDataDir config) + "/meta-registration.yaml";
                registrationServiceUnit = (metaName name) + "-registration.service";
                serviceUnit = (metaName name) + ".service";
              };
            }
          )
        );
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (enabledInstances != { }) {
      assertions = lib.mkMerge (
        lib.attrValues (
          lib.mapAttrs (name: cfg: [
            {
              assertion = cfg.settings.homeserver.domain != "" && cfg.settings.homeserver.address != "";

              message = ''
                The options with information about the homeserver:
                `services.mautrix-meta.instances.${name}.settings.homeserver.domain` and
                `services.mautrix-meta.instances.${name}.settings.homeserver.address` have to be set.
              '';
            }
            {
              assertion = builtins.elem cfg.settings.network.mode [
                "facebook"
                "facebook-tor"
                "messenger"
                "instagram"
              ];

              message = ''
                The option `services.mautrix-meta.instances.${name}.settings.network.mode` has to be set
                to one of: facebook, facebook-tor, messenger, instagram.
                This configures the mode of the bridge.
              '';
            }
            {
              assertion = cfg.settings.bridge.permissions != { };

              message = ''
                The option `services.mautrix-meta.instances.${name}.settings.bridge.permissions` has to be set.
              '';
            }
            {
              assertion = cfg.settings.appservice.id != "";

              message = ''
                The option `services.mautrix-meta.instances.${name}.settings.appservice.id` has to be set.
              '';
            }
            {
              assertion = cfg.settings.appservice.bot.username != "";

              message = ''
                The option `services.mautrix-meta.instances.${name}.settings.appservice.bot.username` has to be set.
              '';
            }
            {
              assertion = !(cfg.settings ? bridge.disable_xma);

              message = ''
                The option `bridge.disable_xma` has been moved to `network.disable_xma_always`. Please [migrate your configuration](https://github.com/mautrix/meta/releases/tag/v0.4.0). You may wish to use [the auto-migration code](https://github.com/mautrix/meta/blob/f5440b05aac125b4c95b1af85635a717cbc6dd0e/cmd/mautrix-meta/legacymigrate.go#L23) for reference.
              '';
            }
            {
              assertion = !(cfg.settings ? bridge.displayname_template);

              message = ''
                The option `bridge.displayname_template` has been moved to `network.displayname_template`. Please [migrate your configuration](https://github.com/mautrix/meta/releases/tag/v0.4.0). You may wish to use [the auto-migration code](https://github.com/mautrix/meta/blob/f5440b05aac125b4c95b1af85635a717cbc6dd0e/cmd/mautrix-meta/legacymigrate.go#L23) for reference.
              '';
            }
            {
              assertion = !(cfg.settings ? meta);

              message = ''
                The options in `meta` have been moved to `network`. Please [migrate your configuration](https://github.com/mautrix/meta/releases/tag/v0.4.0). You may wish to use [the auto-migration code](https://github.com/mautrix/meta/blob/f5440b05aac125b4c95b1af85635a717cbc6dd0e/cmd/mautrix-meta/legacymigrate.go#L23) for reference.
              '';
            }
          ]) enabledInstances
        )
      );

      services.matrix-synapse = lib.mkIf (config.services.matrix-synapse.enable) (
        let
          registrationFiles = lib.attrValues (
            lib.mapAttrs (name: cfg: cfg.registrationFile) registerToSynapseInstances
          );
        in
        {
          settings.app_service_config_files = registrationFiles;
        }
      );

      systemd.services = lib.mkMerge [
        {
          matrix-synapse = lib.mkIf (config.services.matrix-synapse.enable) (
            let
              registrationServices = lib.attrValues (
                lib.mapAttrs (name: cfg: cfg.registrationServiceUnit) registerToSynapseInstances
              );
            in
            {
              after = registrationServices;
              wants = registrationServices;
            }
          );
        }

        (lib.mapAttrs' (
          name: cfg:
          lib.nameValuePair "${metaName name}-registration" {
            description = "Mautrix-Meta registration generation service - ${metaName name}";

            path = [
              pkgs.yq
              pkgs.envsubst
              upperCfg.package
            ];

            restartTriggers = [ (settingsFileUnsubstituted cfg) ];

            script = ''
              # substitute the settings file by environment variables
              # in this case read from EnvironmentFile
              rm -f '${settingsFile cfg}'
              old_umask=$(umask)
              umask 0177
              envsubst \
                -o '${settingsFile cfg}' \
                -i '${settingsFileUnsubstituted cfg}'

              config_has_tokens=$(yq '.appservice | has("as_token") and has("hs_token")' '${settingsFile cfg}')
              registration_already_exists=$([[ -f '${cfg.registrationFile}' ]] && echo "true" || echo "false")

              echo "There are tokens in the config: $config_has_tokens"
              echo "Registration already existed: $registration_already_exists"

              # tokens not configured from config/environment file, and registration file
              # is already generated, override tokens in config to make sure they are not lost
              if [[ $config_has_tokens == "false" && $registration_already_exists == "true" ]]; then
                echo "Copying as_token, hs_token from registration into configuration"
                yq -sY '.[0].appservice.as_token = .[1].as_token
                  | .[0].appservice.hs_token = .[1].hs_token
                  | .[0]' '${settingsFile cfg}' '${cfg.registrationFile}' \
                  > '${settingsFile cfg}.tmp'
                mv '${settingsFile cfg}.tmp' '${settingsFile cfg}'
              fi

              # make sure --generate-registration does not affect config.yaml
              cp '${settingsFile cfg}' '${settingsFile cfg}.tmp'

              echo "Generating registration file"
              mautrix-meta \
                --generate-registration \
                --config='${settingsFile cfg}.tmp' \
                --registration='${cfg.registrationFile}'

              rm '${settingsFile cfg}.tmp'

              # no tokens configured, and new were just generated by generate registration for first time
              if [[ $config_has_tokens == "false" && $registration_already_exists == "false" ]]; then
                echo "Copying newly generated as_token, hs_token from registration into configuration"
                yq -sY '.[0].appservice.as_token = .[1].as_token
                  | .[0].appservice.hs_token = .[1].hs_token
                  | .[0]' '${settingsFile cfg}' '${cfg.registrationFile}' \
                  > '${settingsFile cfg}.tmp'
                mv '${settingsFile cfg}.tmp' '${settingsFile cfg}'
              fi

              # Make sure correct tokens are in the registration file
              if [[ $config_has_tokens == "true" || $registration_already_exists == "true" ]]; then
                echo "Copying as_token, hs_token from configuration to the registration file"
                yq -sY '.[1].as_token = .[0].appservice.as_token
                  | .[1].hs_token = .[0].appservice.hs_token
                  | .[1]' '${settingsFile cfg}' '${cfg.registrationFile}' \
                  > '${cfg.registrationFile}.tmp'
                mv '${cfg.registrationFile}.tmp' '${cfg.registrationFile}'
              fi

              umask $old_umask

              chown :mautrix-meta-registration '${cfg.registrationFile}'
              chmod 640 '${cfg.registrationFile}'
            '';

            serviceConfig = {
              EnvironmentFile = cfg.environmentFile;
              Group = "mautrix-meta";
              ProtectHome = true;
              ProtectSystem = "strict";
              ReadWritePaths = fullDataDir cfg;
              StateDirectory = cfg.dataDir;
              SystemCallFilter = [ "@system-service" ];
              Type = "oneshot";
              UMask = 27;
              User = "mautrix-meta-${name}";
            };
          }
        ) enabledInstances)

        (lib.mapAttrs' (
          name: cfg:
          lib.nameValuePair "${metaName name}" {
            after = [ "network-online.target" ] ++ cfg.serviceDependencies;
            description = "Mautrix-Meta bridge - ${metaName name}";
            restartTriggers = [ (settingsFileUnsubstituted cfg) ];

            serviceConfig = {
              EnvironmentFile = cfg.environmentFile;

              ExecStart = lib.escapeShellArgs [
                (lib.getExe upperCfg.package)
                "--config=${settingsFile cfg}"
              ];

              Group = "mautrix-meta";
              LockPersonality = true;
              MemoryDenyWriteExecute = true;
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
              ProtectSystem = "strict";
              ReadWritePaths = fullDataDir cfg;
              Restart = "on-failure";
              RestartSec = "30s";
              RestrictRealtime = true;
              RestrictSUIDSGID = true;
              StateDirectory = cfg.dataDir;
              SystemCallArchitectures = "native";
              SystemCallErrorNumber = "EPERM";
              SystemCallFilter = [ "@system-service" ];
              Type = "simple";
              UMask = 27;
              User = "mautrix-meta-${name}";
              WorkingDirectory = fullDataDir cfg;
            };

            wantedBy = [ "multi-user.target" ];
            wants = [ "network-online.target" ] ++ cfg.serviceDependencies;
          }
        ) enabledInstances)
      ];

      users.groups.mautrix-meta = { };

      users.groups.mautrix-meta-registration = {
        members = lib.lists.optional config.services.matrix-synapse.enable "matrix-synapse";
      };

      users.users = lib.mapAttrs' (
        name: cfg:
        lib.nameValuePair "mautrix-meta-${name}" {
          description = "Mautrix-Meta-${name} bridge user";
          extraGroups = [ "mautrix-meta-registration" ];
          group = "mautrix-meta";
          isSystemUser = true;
        }
      ) enabledInstances;
    })
    {
      services.mautrix-meta.instances =
        let
          inherit (lib.modules) mkDefault;
        in
        {
          facebook = {
            settings = {
              appservice = {
                bot = {
                  avatar = mkDefault "mxc://maunium.net/ygtkteZsXnGJLJHRchUwYWak";
                  displayname = mkDefault "Facebook bridge bot";
                  username = mkDefault "facebookbot";
                };

                id = mkDefault "facebook";
                port = mkDefault 29321;
                username_template = mkDefault "facebook_{{.}}";
              };

              network.mode = mkDefault "facebook";
            };
          };

          instagram = {
            settings = {
              appservice = {
                bot = {
                  avatar = mkDefault "mxc://maunium.net/JxjlbZUlCPULEeHZSwleUXQv";
                  displayname = mkDefault "Instagram bridge bot";
                  username = mkDefault "instagrambot";
                };

                id = mkDefault "instagram";
                port = mkDefault 29320;
                username_template = mkDefault "instagram_{{.}}";
              };

              network.mode = mkDefault "instagram";
            };
          };
        };
    }
  ];

  meta.maintainers = [ ];
}
