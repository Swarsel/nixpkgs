{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.icingaweb2.modules.monitoring;

  configIni = ''
    [security]
    protected_customvars = "${concatStringsSep "," cfg.generalConfig.protectedVars}"
  '';

  backendsIni =
    let
      formatBool = b: if b then "1" else "0";
    in
    concatStringsSep "\n" (
      mapAttrsToList (name: config: ''
        [${name}]
        type = "ido"
        resource = "${config.resource}"
        disabled = "${formatBool config.disabled}"
      '') cfg.backends
    );

  transportsIni = concatStringsSep "\n" (
    mapAttrsToList (name: config: ''
      [${name}]
      type = "${config.type}"
      ${optionalString (config.instance != null) ''instance = "${config.instance}"''}
      ${optionalString (config.type == "local" || config.type == "remote") ''path = "${config.path}"''}
      ${optionalString (config.type != "local") ''
        host = "${config.host}"
        ${optionalString (config.port != null) ''port = "${toString config.port}"''}
        user${optionalString (config.type == "api") "name"} = "${config.username}"
      ''}
      ${optionalString (config.type == "api") ''password = "${config.password}"''}
      ${optionalString (config.type == "remote") ''resource = "${config.resource}"''}
    '') cfg.transports
  );

in
{
  options.services.icingaweb2.modules.monitoring = with types; {
    enable = mkOption {
      default = true;
      description = "Whether to enable the icingaweb2 monitoring module.";
      type = bool;
    };

    backends = mkOption {
      default = {
        icinga = {
          resource = "icinga_ido";
        };
      };

      description = "Monitoring backends to define";

      type = attrsOf (
        submodule (
          { name, ... }:
          {
            options = {
              disabled = mkOption {
                default = false;
                description = "Disable this backend";
                type = bool;
              };

              name = mkOption {
                default = name;
                description = "Name of this backend";
                type = str;
                visible = false;
              };

              resource = mkOption {
                description = "Name of the IDO resource";
                type = str;
              };
            };
          }
        )
      );
    };

    generalConfig = {
      mutable = mkOption {
        default = false;
        description = "Make config.ini of the monitoring module mutable (e.g. via the web interface).";
        type = bool;
      };

      protectedVars = mkOption {
        default = [
          "*pw*"
          "*pass*"
          "community"
        ];

        description = "List of string patterns for custom variables which should be excluded from user’s view.";
        type = listOf str;
      };
    };

    mutableBackends = mkOption {
      default = false;
      description = "Make backends.ini of the monitoring module mutable (e.g. via the web interface).";
      type = bool;
    };

    mutableTransports = mkOption {
      default = true;
      description = "Make commandtransports.ini of the monitoring module mutable (e.g. via the web interface).";
      type = bool;
    };

    transports = mkOption {
      default = { };
      description = "Command transports to define";

      type = attrsOf (
        submodule (
          { name, ... }:
          {
            options = {
              host = mkOption {
                description = "Host for the api or remote transport";
                type = str;
              };

              instance = mkOption {
                default = null;
                description = "Assign a icinga instance to this transport";
                type = nullOr str;
              };

              name = mkOption {
                default = name;
                description = "Name of this transport";
                type = str;
                visible = false;
              };

              password = mkOption {
                description = "Password for the api transport";
                type = str;
              };

              path = mkOption {
                description = "Path to the socket for local or remote transports";
                type = str;
              };

              port = mkOption {
                default = null;
                description = "Port to connect to for the api or remote transport";
                type = nullOr str;
              };

              resource = mkOption {
                description = "SSH identity resource for the remote transport";
                type = str;
              };

              type = mkOption {
                default = "api";
                description = "Type of  this transport";

                type = enum [
                  "api"
                  "local"
                  "remote"
                ];
              };

              username = mkOption {
                description = "Username for the api or remote transport";
                type = str;
              };
            };
          }
        )
      );
    };
  };

  config = mkIf (config.services.icingaweb2.enable && cfg.enable) {
    environment.etc = {
      "icingaweb2/enabledModules/monitoring" = {
        source = "${pkgs.icingaweb2}/modules/monitoring";
      };
    }
    // optionalAttrs (!cfg.generalConfig.mutable) {
      "icingaweb2/modules/monitoring/config.ini".text = configIni;
    }
    // optionalAttrs (!cfg.mutableBackends) {
      "icingaweb2/modules/monitoring/backends.ini".text = backendsIni;
    }
    // optionalAttrs (!cfg.mutableTransports) {
      "icingaweb2/modules/monitoring/commandtransports.ini".text = transportsIni;
    };
  };
}
