{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.node-red;
  defaultUser = "node-red";
in
{
  options.services.node-red = {
    enable = mkEnableOption "the Node-RED service";
    package = mkPackageOption pkgs [ "node-red" ] { };

    configFile = mkOption {
      default = "${cfg.package}/lib/node_modules/node-red/packages/node_modules/node-red/settings.js";
      defaultText = literalExpression ''"''${package}/lib/node_modules/node-red/packages/node_modules/node-red/settings.js"'';

      description = ''
        Path to the JavaScript configuration file.
        See <https://github.com/node-red/node-red/blob/master/packages/node_modules/node-red/settings.js>
        for a configuration example.
      '';

      type = types.path;
    };

    define = mkOption {
      default = { };
      description = "List of settings.js overrides to pass via -D to Node-RED.";

      example = literalExpression ''
        {
          "logging.console.level" = "trace";
        }
      '';

      type = types.attrs;
    };

    group = mkOption {
      default = defaultUser;

      description = ''
        Group under which Node-RED runs.If left as the default value this group
        will automatically be created on system activation, otherwise the
        sysadmin is responsible for ensuring the group exists.
      '';

      type = types.str;
    };

    openFirewall = mkOption {
      default = false;

      description = ''
        Open ports in the firewall for the server.
      '';

      type = types.bool;
    };

    port = mkOption {
      default = 1880;
      description = "Listening port.";
      type = types.port;
    };

    safe = mkOption {
      default = false;
      description = "Whether to launch Node-RED in --safe mode.";
      type = types.bool;
    };

    user = mkOption {
      default = defaultUser;

      description = ''
        User under which Node-RED runs.If left as the default value this user
        will automatically be created on system activation, otherwise the
        sysadmin is responsible for ensuring the user exists.
      '';

      type = types.str;
    };

    userDir = mkOption {
      default = "/var/lib/node-red";

      description = ''
        The directory to store all user data, such as flow and credential files and all library data. If left
        as the default value this directory will automatically be created before the node-red service starts,
        otherwise the sysadmin is responsible for ensuring the directory exists with appropriate ownership
        and permissions.
      '';

      type = types.path;
    };

    withNpmAndGcc = mkOption {
      default = false;

      description = ''
        Give Node-RED access to npm and GCC at runtime, so 'Nodes' can be
        downloaded and managed imperatively via the 'Palette Manager'.
      '';

      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.node-red = {
      after = [ "network.target" ];
      description = "Node-RED Service";

      environment = {
        HOME = cfg.userDir;
      };

      path = lib.optionals cfg.withNpmAndGcc [
        pkgs.nodejs
        pkgs.gcc
      ];

      serviceConfig = mkMerge [
        {
          ExecStart = "${cfg.package}/bin/node-red ${pkgs.lib.optionalString cfg.safe "--safe"} --settings ${cfg.configFile} --port ${toString cfg.port} --userDir ${cfg.userDir} ${
            concatStringsSep " " (mapAttrsToList (name: value: "-D ${name}=${value}") cfg.define)
          }";

          Group = cfg.group;
          PrivateTmp = true;
          Restart = "always";
          User = cfg.user;
          WorkingDirectory = cfg.userDir;
        }
        (mkIf (cfg.userDir == "/var/lib/node-red") { StateDirectory = "node-red"; })
      ];

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = optionalAttrs (cfg.group == defaultUser) {
      ${defaultUser} = { };
    };

    users.users = optionalAttrs (cfg.user == defaultUser) {
      ${defaultUser} = {
        group = defaultUser;
        isSystemUser = true;
      };
    };
  };
}
