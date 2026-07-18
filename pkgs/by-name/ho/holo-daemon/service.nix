# Non-module dependencies (`importApply`)
{ pkgs }:

# Service module
{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkPackageOption
    mkOption
    types
    ;
  cfg = config.holo-daemon;
  format = pkgs.formats.toml { };
  configFile = format.generate "holod.toml" cfg.settings;
in
{
  _class = "service";

  config = {
    process.argv = [
      "${cfg.package}/bin/holod"
      "-c"
      configFile
    ];
  };

  options.holo-daemon = {
    package = mkPackageOption pkgs "holo-daemon" { };

    settings = mkOption {
      default = { };
      description = "Configuration for the holo daemon";

      type = types.submodule {
        freeformType = format.type;

        options = {
          # Needs to be writable by @user or @group
          database_path = mkOption {
            default = "/var/run/holod/holod.db";
            description = "Path to the holo database";
            type = types.str;
          };

          group = mkOption {
            default = "holo";
            description = "Group for the holo daemon";
            type = types.str;
          };

          logging = mkOption {
            default = { };
            description = "Logging configuration for the holo daemon";

            type = types.submodule {
              freeformType = format.type;

              options = {
                file = mkOption {
                  default = { };
                  description = "File logging configuration";

                  type = types.submodule {
                    options = {
                      dir = mkOption {
                        default = "/var/log/";
                        description = "Directory for log files";
                        type = types.str;
                      };

                      enabled = mkOption {
                        default = true;
                        description = "Enable or disable file logging";
                        type = types.bool;
                      };

                      name = mkOption {
                        default = "holod.log";
                        description = "Name of the log file";
                        type = types.str;
                      };
                    };
                  };
                };

                journald = mkOption {
                  default = { };
                  description = "Journald logging configuration";

                  type = types.submodule {
                    options = {
                      enabled = mkOption {
                        default = true;
                        description = "Enable or disable journald logging";
                        type = types.bool;
                      };
                    };
                  };
                };
              };
            };
          };

          plugins = mkOption {
            default = { };
            description = "Plugin configuration for the holo daemon";

            type = types.submodule {
              freeformType = format.type;

              options = {
                grpc = mkOption {
                  default = { };
                  description = "gRPC plugin configuration";

                  type = types.submodule {
                    options = {
                      address = mkOption {
                        default = "[::]:50051";
                        description = "gRPC server listening address";
                        type = types.str;
                      };

                      enabled = mkOption {
                        default = true;
                        description = "Enable or disable gRPC plugin";
                        type = types.bool;
                      };
                    };
                  };
                };
              };
            };
          };

          user = mkOption {
            default = "holo";
            description = "User for the holo daemon";
            type = types.str;
          };
        };
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ themadbit ];
}
