{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.errbot;
  pluginEnv =
    plugins:
    pkgs.buildEnv {
      name = "errbot-plugins";
      paths = plugins;
    };
  mkConfigDir =
    instanceCfg: dataDir:
    pkgs.writeTextDir "config.py" ''
      import logging
      BACKEND = '${instanceCfg.backend}'
      BOT_DATA_DIR = '${dataDir}'
      BOT_EXTRA_PLUGIN_DIR = '${pluginEnv instanceCfg.plugins}'

      BOT_LOG_LEVEL = logging.${instanceCfg.logLevel}
      BOT_LOG_FILE = False

      BOT_ADMINS = (${lib.concatMapStringsSep "," (name: "'${name}'") instanceCfg.admins})

      BOT_IDENTITY = ${builtins.toJSON instanceCfg.identity}

      ${instanceCfg.extraConfig}
    '';
in
{
  options = {
    services.errbot.instances = lib.mkOption {
      default = { };
      description = "Errbot instance configs";

      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            admins = lib.mkOption {
              default = [ ];
              description = "List of identifiers of errbot admins.";
              type = lib.types.listOf lib.types.str;
            };

            backend = lib.mkOption {
              default = "XMPP";
              description = "Errbot backend name.";
              type = lib.types.str;
            };

            dataDir = lib.mkOption {
              default = null;
              description = "Data directory for errbot instance.";
              type = lib.types.nullOr lib.types.path;
            };

            extraConfig = lib.mkOption {
              default = "";
              description = "String to be appended to the config verbatim";
              type = lib.types.lines;
            };

            identity = lib.mkOption {
              description = "Errbot identity configuration";
              type = lib.types.attrs;
            };

            logLevel = lib.mkOption {
              default = "INFO";
              description = "Errbot log level";
              type = lib.types.str;
            };

            plugins = lib.mkOption {
              default = [ ];
              description = "List of errbot plugin derivations.";
              type = lib.types.listOf lib.types.package;
            };
          };
        }
      );
    };
  };

  config = lib.mkIf (cfg.instances != { }) {
    systemd.services = lib.mapAttrs' (
      name: instanceCfg:
      lib.nameValuePair "errbot-${name}" (
        let
          dataDir = if instanceCfg.dataDir != null then instanceCfg.dataDir else "/var/lib/errbot/${name}";
        in
        {
          after = [ "network-online.target" ];

          serviceConfig = {
            ExecStart = "${pkgs.errbot}/bin/errbot -c ${mkConfigDir instanceCfg dataDir}/config.py";

            ExecStartPre = [
              "${lib.getExe' pkgs.coreutils "mkdir"} -p ${dataDir}"
              "${lib.getExe' pkgs.coreutils "chown"} -R errbot:errbot ${dataDir}"
            ];

            PermissionsStartOnly = true;
            Restart = "on-failure";
            User = "errbot";
          };

          wantedBy = [ "multi-user.target" ];
        }
      )
    ) cfg.instances;

    users.groups.errbot = { };

    users.users.errbot = {
      group = "errbot";
      isSystemUser = true;
    };
  };
}
