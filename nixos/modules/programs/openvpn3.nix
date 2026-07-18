{
  config,
  lib,
  pkgs,
  ...
}:

let
  json = pkgs.formats.json { };
  cfg = config.programs.openvpn3;

  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    literalExpression
    max
    options
    lists
    ;
  inherit (lib.types)
    bool
    submodule
    ints
    attrsOf
    ;
in
{
  options.programs.openvpn3 = {
    enable = mkEnableOption "the openvpn3 client";
    package = mkPackageOption pkgs "openvpn3" { };

    log-service = mkOption {
      default = { };
      description = "Log service configuration";

      type = submodule {
        options = {
          settings = mkOption {
            default = { };
            description = "Options stored in {file}`/etc/openvpn3/log-service.json` configuration file";

            type = submodule {
              options = {
                journald = mkOption {
                  default = true;
                  description = "Use systemd-journald";
                  example = false;
                  type = bool;
                };

                log_dbus_details = mkOption {
                  default = true;
                  description = "Add D-Bus details in log file/syslog";
                  example = false;
                  type = bool;
                };

                log_level = mkOption {
                  default = 3;
                  description = "How verbose should the logging be";
                  example = 6;

                  type = (ints.between 0 7) // {
                    merge = _loc: defs: lists.foldl max 0 (options.getValues defs);
                  };
                };

                timestamp = mkOption {
                  default = false;
                  description = "Add timestamp log file";
                  example = true;
                  type = bool;
                };
              };

              freeformType = attrsOf json.type;
            };
          };
        };
      };
    };

    netcfg = mkOption {
      default = { };
      description = "Network configuration";

      type = submodule {
        options = {
          settings = mkOption {
            default = { };
            description = "Options stored in {file}`/etc/openvpn3/netcfg.json` configuration file";

            type = submodule {
              options = {
                systemd_resolved = mkOption {
                  default = config.services.resolved.enable;
                  defaultText = literalExpression "config.services.resolved.enable";
                  description = "Whether to use systemd-resolved integration";
                  example = false;
                  type = bool;
                };
              };

              freeformType = attrsOf json.type;
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      etc = {
        "openvpn3/log-service.json".source = json.generate "log-service.json" cfg.log-service.settings;
        "openvpn3/netcfg.json".source = json.generate "netcfg.json" cfg.netcfg.settings;
      };

      systemPackages = [ cfg.package ];
    };

    services.dbus.packages = [ cfg.package ];

    systemd = {
      packages = [ cfg.package ];

      tmpfiles.rules = [
        "d /etc/openvpn3/configs 0750 openvpn openvpn - -"
      ];
    };

    users.groups.openvpn = {
      gid = config.ids.gids.openvpn;
    };

    users.users.openvpn = {
      group = "openvpn";
      isSystemUser = true;
      uid = config.ids.uids.openvpn;
    };
  };

  meta.maintainers = with lib.maintainers; [
    progrm_jarvis
  ];
}
