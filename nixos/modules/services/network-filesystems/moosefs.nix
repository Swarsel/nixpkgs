{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.moosefs;

  mfsUser = if cfg.runAsUser then "moosefs" else "root";

  settingsFormat =
    let
      listSep = " ";
      allowedTypes = with lib.types; [
        bool
        int
        float
        str
      ];
      valueToString =
        val:
        if lib.isList val then
          lib.concatStringsSep listSep (map (x: valueToString x) val)
        else if lib.isBool val then
          (if val then "1" else "0")
        else
          toString val;

    in
    {
      generate =
        name: value:
        pkgs.writeText name (
          lib.concatStringsSep "\n" (lib.mapAttrsToList (key: val: "${key} = ${valueToString val}") value)
        );

      type =
        with lib.types;
        let
          valueType =
            oneOf (
              [
                (listOf valueType)
              ]
              ++ allowedTypes
            )
            // {
              description = "Flat key-value file";
            };
        in
        attrsOf valueType;
    };

  # Manual initialization tool
  initTool = pkgs.writeShellScriptBin "mfsmaster-init" ''
    if [ ! -e ${cfg.master.settings.DATA_PATH}/metadata.mfs ]; then
      cp ${pkgs.moosefs}/var/mfs/metadata.mfs.empty ${cfg.master.settings.DATA_PATH}
      chmod +w ${cfg.master.settings.DATA_PATH}/metadata.mfs.empty
      ${pkgs.moosefs}/bin/mfsmaster -a -c ${masterCfg} start
      ${pkgs.moosefs}/bin/mfsmaster -c ${masterCfg} stop
      rm ${cfg.master.settings.DATA_PATH}/metadata.mfs.empty
    fi
  '';

  masterCfg = settingsFormat.generate "mfsmaster.cfg" cfg.master.settings;
  metaloggerCfg = settingsFormat.generate "mfsmetalogger.cfg" cfg.metalogger.settings;
  chunkserverCfg = settingsFormat.generate "mfschunkserver.cfg" cfg.chunkserver.settings;
  guiCfg = settingsFormat.generate "mfsgui.cfg" cfg.cgiserver.settings;

  systemdService = name: extraConfig: configFile: {
    after = [
      "network.target"
      "network-online.target"
    ];

    serviceConfig = {
      ExecReload = "${pkgs.moosefs}/bin/mfs${name} -c ${configFile} reload";
      ExecStart = "${pkgs.moosefs}/bin/mfs${name} -c ${configFile} start";
      ExecStop = "${pkgs.moosefs}/bin/mfs${name} -c ${configFile} stop";
      PIDFile = "${cfg."${name}".settings.DATA_PATH}/.mfs${name}.lock";
      Type = "forking";
    }
    // extraConfig;

    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
  };

in
{
  ###### interface
  options = {
    services.moosefs = {
      cgiserver = {
        enable = lib.mkEnableOption ''
          MooseFS GUI server (mfsgui) for web interface.
          Warning: The GUI server interface should be properly secured from unauthorized access,
          as it provides full control over your MooseFS installation.
        '';

        openFirewall = lib.mkOption {
          default = false;
          description = "Whether to automatically open the web interface port.";
          type = lib.types.bool;
        };

        settings = lib.mkOption {
          default = { };
          description = "GUI server configuration options.";

          type = lib.types.submodule {
            options = {
              DATA_PATH = lib.mkOption {
                default = "/var/lib/mfs";
                description = "Directory for lock files.";
                type = lib.types.str;
              };

              GUISERV_LISTEN_HOST = lib.mkOption {
                default = "*";
                description = "IP address to bind GUI server to (* means any).";
                type = lib.types.str;
              };

              GUISERV_LISTEN_PORT = lib.mkOption {
                default = 9425;
                description = "Port for GUI server to listen on.";
                type = lib.types.port;
              };
            };

            freeformType = settingsFormat.type;
          };
        };
      };

      chunkserver = {
        enable = lib.mkEnableOption "MooseFS chunkserver daemon that stores file data";

        hdds = lib.mkOption {
          default = null;
          description = "Mount points used by chunkserver for data storage (see mfshdd.cfg).";

          example = [
            "/mnt/hdd1"
            "/mnt/hdd2"
          ];

          type = with lib.types; listOf str;
        };

        openFirewall = lib.mkOption {
          default = false;
          description = "Whether to automatically open required firewall ports for chunkserver service.";
          type = lib.types.bool;
        };

        settings = lib.mkOption {
          description = "Chunkserver configuration options (mfschunkserver.cfg).";

          type = lib.types.submodule {
            options.DATA_PATH = lib.mkOption {
              default = "/var/lib/mfs";
              description = "Directory for lock files and other runtime data.";
              type = lib.types.str;
            };

            freeformType = settingsFormat.type;
          };
        };
      };

      client.enable = lib.mkEnableOption "MooseFS client";

      master = {
        enable = lib.mkOption {
          default = false;

          description = ''
            Enable MooseFS master daemon.
            The master server coordinates all MooseFS operations and stores metadata.
          '';

          type = lib.types.bool;
        };

        autoInit = lib.mkOption {
          default = false;
          description = "Whether to automatically initialize the master's metadata directory on first run. Use with caution.";
          type = lib.types.bool;
        };

        exports = lib.mkOption {
          default = null;
          description = "Export definitions for MooseFS (see mfsexports.cfg).";

          example = [
            "* / rw,alldirs,admin,maproot=0:0"
            "* . rw"
          ];

          type = with lib.types; listOf str;
        };

        openFirewall = lib.mkOption {
          default = false;
          description = "Whether to automatically open required firewall ports for master service.";
          type = lib.types.bool;
        };

        settings = lib.mkOption {
          description = "Master configuration options (mfsmaster.cfg).";

          type = lib.types.submodule {
            options.DATA_PATH = lib.mkOption {
              default = "/var/lib/mfs";
              description = "Directory for storing master metadata.";
              type = lib.types.str;
            };

            freeformType = settingsFormat.type;
          };
        };
      };

      masterHost = lib.mkOption {
        default = null;
        description = "IP or DNS name of the MooseFS master server.";
        type = lib.types.str;
      };

      metalogger = {
        enable = lib.mkEnableOption "MooseFS metalogger daemon that maintains a backup copy of the master's metadata";

        settings = lib.mkOption {
          description = "Metalogger configuration options (mfsmetalogger.cfg).";

          type = lib.types.submodule {
            options.DATA_PATH = lib.mkOption {
              default = "/var/lib/mfs";
              description = "Directory for storing metalogger data.";
              type = lib.types.str;
            };

            freeformType = settingsFormat.type;
          };
        };
      };

      runAsUser = lib.mkOption {
        default = true;
        description = "Run daemons as moosefs user instead of root for better security.";
        example = true;
        type = lib.types.bool;
      };
    };
  };

  ###### implementation
  config =
    lib.mkIf
      (
        cfg.client.enable
        || cfg.master.enable
        || cfg.metalogger.enable
        || cfg.chunkserver.enable
        || cfg.cgiserver.enable
      )
      {
        environment.systemPackages =
          (lib.optional cfg.client.enable pkgs.moosefs) ++ (lib.optional cfg.master.enable initTool);

        networking.firewall.allowedTCPPorts = lib.mkMerge [
          (lib.optionals cfg.master.openFirewall [
            9419
            9420
            9421
          ])
          (lib.optional cfg.chunkserver.openFirewall 9422)
          (lib.optional (
            cfg.cgiserver.enable && cfg.cgiserver.openFirewall
          ) cfg.cgiserver.settings.GUISERV_LISTEN_PORT)
        ];

        services.moosefs = {
          cgiserver.settings = lib.mkIf cfg.cgiserver.enable {
            WORKING_USER = mfsUser;
          };

          chunkserver.settings = lib.mkIf cfg.chunkserver.enable {
            HDD_CONF_FILENAME = toString (
              pkgs.writeText "mfshdd.cfg" (lib.concatStringsSep "\n" cfg.chunkserver.hdds)
            );

            MASTER_HOST = cfg.masterHost;
            WORKING_USER = mfsUser;
          };

          master.settings = lib.mkIf cfg.master.enable {
            EXPORTS_FILENAME = toString (
              pkgs.writeText "mfsexports.cfg" (lib.concatStringsSep "\n" cfg.master.exports)
            );

            WORKING_USER = mfsUser;
          };

          metalogger.settings = lib.mkIf cfg.metalogger.enable {
            MASTER_HOST = cfg.masterHost;
            WORKING_USER = mfsUser;
          };
        };

        systemd.services = lib.mkMerge [
          (lib.mkIf cfg.master.enable {
            mfs-master = (
              lib.mkMerge [
                (systemdService "master" {
                  Restart = "on-failure";
                  TimeoutStartSec = 1800;
                  TimeoutStopSec = 1800;
                  User = mfsUser;
                } masterCfg)
                {
                  preStart = lib.mkIf cfg.master.autoInit "${initTool}/bin/mfsmaster-init";
                }
              ]
            );
          })

          (lib.mkIf cfg.metalogger.enable {
            mfs-metalogger = systemdService "metalogger" {
              Restart = "on-abnormal";
              User = mfsUser;
            } metaloggerCfg;
          })

          (lib.mkIf cfg.chunkserver.enable {
            mfs-chunkserver = systemdService "chunkserver" {
              Restart = "on-abnormal";
              User = mfsUser;
            } chunkserverCfg;
          })

          (lib.mkIf cfg.cgiserver.enable {
            mfs-cgiserv = {
              after = [ "mfs-master.service" ];
              description = "MooseFS GUI Server";

              path = [
                pkgs.bash
                pkgs.coreutils
                pkgs.python3
              ];

              serviceConfig = {
                ExecReload = "${pkgs.moosefs}/bin/mfsgui -c ${guiCfg} reload";
                ExecStart = "${pkgs.moosefs}/bin/mfsgui -f -c ${guiCfg} start";
                ExecStop = "${pkgs.moosefs}/bin/mfsgui -c ${guiCfg} stop";
                Group = mfsUser;
                Restart = "on-failure";
                RestartSec = "30s";
                Type = "simple";
                User = mfsUser;
                WorkingDirectory = cfg.cgiserver.settings.DATA_PATH;
              };

              wantedBy = [ "multi-user.target" ];
            };
          })
        ];

        systemd.tmpfiles.rules = [
          # Master directories
          (lib.optionalString cfg.master.enable "d ${cfg.master.settings.DATA_PATH} 0700 ${mfsUser} ${mfsUser} -")

          # Metalogger directories
          (lib.optionalString cfg.metalogger.enable "d ${cfg.metalogger.settings.DATA_PATH} 0700 ${mfsUser} ${mfsUser} -")

          # Chunkserver directories
          (lib.optionalString cfg.chunkserver.enable "d ${cfg.chunkserver.settings.DATA_PATH} 0700 ${mfsUser} ${mfsUser} -")

          # GUI server directories
          (lib.optionalString cfg.cgiserver.enable "d ${cfg.cgiserver.settings.DATA_PATH} 0700 ${mfsUser} ${mfsUser} -")
        ]
        ++ lib.optionals (cfg.chunkserver.enable && cfg.chunkserver.hdds != null) (
          map (dir: "d ${dir} 0755 ${mfsUser} ${mfsUser} -") cfg.chunkserver.hdds
        );

        users =
          lib.mkIf
            (
              cfg.runAsUser
              && (cfg.master.enable || cfg.metalogger.enable || cfg.chunkserver.enable || cfg.cgiserver.enable)
            )
            {
              groups.moosefs = { };

              users.moosefs = {
                description = "MooseFS daemon user";
                group = "moosefs";
                isSystemUser = true;
              };
            };

        warnings = [
          (lib.mkIf (!cfg.runAsUser) "Running MooseFS services as root is not recommended.")
        ];
      };
}
