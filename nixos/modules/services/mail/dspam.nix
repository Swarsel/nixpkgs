{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.dspam;

  dspam = pkgs.dspam;

  defaultSock = "/run/dspam/dspam.sock";

  cfgfile = pkgs.writeText "dspam.conf" ''
    Home /var/lib/dspam
    StorageDriver ${dspam}/lib/dspam/lib${cfg.storageDriver}_drv.so

    Trust root
    Trust ${cfg.user}
    SystemLog on
    UserLog on

    ${lib.optionalString (cfg.domainSocket != null) ''
      ServerDomainSocketPath "${cfg.domainSocket}"
      ClientHost "${cfg.domainSocket}"
    ''}

    ${cfg.extraConfig}
  '';

in
{

  ###### interface

  options = {

    services.dspam = {

      enable = lib.mkOption {
        default = false;
        description = "Whether to enable the dspam spam filter.";
        type = lib.types.bool;
      };

      domainSocket = lib.mkOption {
        default = defaultSock;
        description = "Path to local domain socket which is used for communication with the daemon. Set to null to disable UNIX socket.";
        type = lib.types.nullOr lib.types.path;
      };

      extraConfig = lib.mkOption {
        default = "";
        description = "Additional dspam configuration.";
        type = lib.types.lines;
      };

      group = lib.mkOption {
        default = "dspam";
        description = "Group for the dspam daemon.";
        type = lib.types.str;
      };

      maintenanceInterval = lib.mkOption {
        default = null;
        description = "If set, maintenance script will be run at specified (in systemd.timer format) interval";
        type = lib.types.nullOr lib.types.str;
      };

      storageDriver = lib.mkOption {
        default = "hash";
        description = "Storage driver backend to use for dspam.";
        type = lib.types.str;
      };

      user = lib.mkOption {
        default = "dspam";
        description = "User for the dspam daemon.";
        type = lib.types.str;
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.etc."dspam/dspam.conf".source = cfgfile;
        environment.systemPackages = [ dspam ];

        systemd.services.dspam = {
          after = [ "postgresql.target" ];
          description = "dspam spam filtering daemon";
          restartTriggers = [ cfgfile ];

          serviceConfig = {
            ExecStart = "${dspam}/bin/dspam --daemon --nofork";
            Group = cfg.group;
            LogsDirectory = "dspam";
            LogsDirectoryMode = "0750";
            # DSPAM segfaults on just about every error
            Restart = "on-abort";
            RestartSec = "1s";
            RuntimeDirectory = lib.optional (cfg.domainSocket == defaultSock) "dspam";
            RuntimeDirectoryMode = lib.optional (cfg.domainSocket == defaultSock) "0750";
            StateDirectory = "dspam";
            StateDirectoryMode = "0750";
            User = cfg.user;
          };

          wantedBy = [ "multi-user.target" ];
        };

        users.groups = lib.optionalAttrs (cfg.group == "dspam") {
          dspam.gid = config.ids.gids.dspam;
        };

        users.users = lib.optionalAttrs (cfg.user == "dspam") {
          dspam = {
            group = cfg.group;
            uid = config.ids.uids.dspam;
          };
        };
      }

      (lib.mkIf (cfg.maintenanceInterval != null) {
        systemd.services.dspam-maintenance = {
          description = "dspam maintenance script";
          restartTriggers = [ cfgfile ];

          serviceConfig = {
            ExecStart = "${dspam}/bin/dspam_maintenance --verbose";
            Group = cfg.group;
            Type = "oneshot";
            User = cfg.user;
          };
        };

        systemd.timers.dspam-maintenance = {
          description = "Timer for dspam maintenance script";

          timerConfig = {
            OnCalendar = cfg.maintenanceInterval;
            Unit = "dspam-maintenance.service";
          };

          wantedBy = [ "timers.target" ];
        };
      })
    ]
  );
}
