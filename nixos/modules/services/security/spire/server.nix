{
  config,
  lib,
  pkgs,
  ...
}:
let
  format = pkgs.formats.hcl1 { };
  cfg = config.services.spire.server;
in
{
  imports = [ ./server-tpm.nix ];

  options.services.spire.server = {
    enable = lib.mkEnableOption "SPIRE Server";
    package = lib.mkPackageOption pkgs "spire" { };

    configFile = lib.mkOption {
      default = format.generate "server.conf" (lib.filterAttrsRecursive (_: v: v != null) cfg.settings);
      defaultText = "Config file generated from services.spire.server.settings";

      description = ''
        Path to the SPIRE server configuration file. See [the documentation](https://spiffe.io/docs/latest/deploying/spire_server/) for more information.
      '';

      type = lib.types.path;
    };

    expandEnv = lib.mkOption {
      default = true;
      description = "Expand environment variables in services.spire.server.settings and services.spire.server.configFile";
      type = lib.types.bool;
    };

    openFirewall = lib.mkOption {
      default = false;
      description = "Whether to open firewall";
      type = lib.types.bool;
    };

    settings = lib.mkOption {
      description = ''
        SPIRE Server configuration file options. See [the documentation](https://spiffe.io/docs/latest/deploying/spire_server/) for all available options.
      '';

      type = lib.types.submodule {
        options = {
          plugins = lib.mkOption {
            description = ''
              Built-in plugin types can be found at [the plugin types documentation](https://spiffe.io/docs/latest/deploying/spire_server/#plugin-types).
              See [plugin configuration](https://spiffe.io/docs/latest/deploying/spire_server/#plugin-configuration) for options and how to configure external plugins.
            '';

            example = {
              DataStore.sql.plugin_data = {
                connection_string = "$STATE_DIRECTORY/datastore.sqlite3";
                database_type = "sqlite3";
              };

              KeyManager.memory.plugin_data = { };
              NodeAttestor.join_token.plugin_data = { };
            };

            type = lib.types.submodule {
              options.NodeAttestor = lib.mkOption {
                default = { };

                description = ''
                  NodeAttestor plugins implement validation logic for nodes attempting to assert their identity.
                  They are generally paired with an agent plugin of the same type.
                  See [the documentation](https://spiffe.io/docs/latest/deploying/spire_server/#nodeattestor)
                  for the list of built-in NodeAttestor plugins.
                '';

                type = lib.types.submodule {
                  options.join_token = lib.mkOption {
                    default = null;
                    description = "Join token based node attestation.";

                    type = lib.types.nullOr (
                      lib.types.submodule {
                        options.plugin_data = lib.mkOption {
                          default = { };
                          description = "Plugin data for the join_token NodeAttestor.";
                          type = format.type;
                        };

                        freeformType = format.type;
                      }
                    );
                  };

                  freeformType = format.type;
                };
              };

              freeformType = format.type;
            };
          };

          server = {
            bind_address = lib.mkOption {
              default = "[::]";
              description = "The address on which the SPIRE server is listening";
              type = lib.types.str;
            };

            bind_port = lib.mkOption {
              default = 8081;
              description = "The port on which the SPIRE server is listening";
              type = lib.types.port;
            };

            data_dir = lib.mkOption {
              default = "$STATE_DIRECTORY";
              description = "The directory where SPIRE server stores its data";
              type = lib.types.str;
            };

            socket_path = lib.mkOption {
              default = "/run/spire/server/private/api.sock";
              description = "Path to bind the SPIRE Server API Socket to";
              type = lib.types.str;
            };

            trust_domain = lib.mkOption {
              description = "The trust domain that this server belongs to";
              example = "example.com";
              type = lib.types.str;
            };
          };
        };

        freeformType = format.type;
      };
    };

  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.settings.server.bind_port ];

    systemd.services.spire-server = {
      description = "SPIRE Server";
      documentation = [ "https://spiffe.io/docs/latest/deploying/spire_server/" ];

      serviceConfig = {
        DynamicUser = true;

        ExecStart =
          "${lib.getExe' cfg.package "spire-server"} run "
          + lib.cli.toCommandLineShellGNU { } {
            inherit (cfg) expandEnv;
            config = cfg.configFile;
          };

        Restart = "on-failure";
        RuntimeDirectory = "spire/server";
        StateDirectory = "spire/server";
        StateDirectoryMode = "0700";
        UMask = "0027";
        # TODO: hardening
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.arianvp ];
}
