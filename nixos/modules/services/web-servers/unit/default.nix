{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.unit;

  configFile = pkgs.writeText "unit.json" cfg.config;

in
{
  options = {
    services.unit = {
      config = mkOption {
        default = ''
          {
            "listeners": {},
            "applications": {}
          }
        '';

        description = "Unit configuration in JSON format. More details here <https://unit.nginx.org/configuration>";

        example = ''
          {
            "listeners": {
              "*:8300": {
                "application": "example-php-72"
              }
            },
            "applications": {
              "example-php-72": {
                "type": "php 7.2",
                "processes": 4,
                "user": "nginx",
                "group": "nginx",
                "root": "/var/www",
                "index": "index.php",
                "options": {
                  "file": "/etc/php.d/default.ini",
                  "admin": {
                    "max_execution_time": "30",
                    "max_input_time": "30",
                    "display_errors": "off",
                    "display_startup_errors": "off",
                    "open_basedir": "/dev/urandom:/proc/cpuinfo:/proc/meminfo:/etc/ssl/certs:/var/www",
                    "disable_functions": "exec,passthru,shell_exec,system"
                  }
                }
              }
            }
          }
        '';

        type = types.str;
      };

      enable = mkEnableOption "Unit App Server";
      package = mkPackageOption pkgs "unit" { };

      group = mkOption {
        default = "unit";
        description = "Group account under which unit runs.";
        type = types.str;
      };

      logDir = mkOption {
        default = "/var/log/unit";
        description = "Unit log directory.";
        type = types.path;
      };

      stateDir = mkOption {
        default = "/var/spool/unit";
        description = "Unit data directory.";
        type = types.path;
      };

      user = mkOption {
        default = "unit";
        description = "User account under which unit runs.";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    systemd.services.unit = {
      after = [ "network.target" ];
      description = "Unit App Server";

      postStart = ''
        ${pkgs.curl}/bin/curl -X PUT --data-binary '@${configFile}' --unix-socket '/run/unit/control.unit.sock' 'http://localhost/config'
      '';

      preStart = ''
        [ ! -e '${cfg.stateDir}/conf.json' ] || rm -f '${cfg.stateDir}/conf.json'
      '';

      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/unitd --control 'unix:/run/unit/control.unit.sock' --pid '/run/unit/unit.pid' \
                                   --log '${cfg.logDir}/unit.log' --statedir '${cfg.stateDir}' --tmpdir '/tmp' \
                                   --user ${cfg.user} --group ${cfg.group}
        '';

        ExecStop = ''
          ${pkgs.curl}/bin/curl -X DELETE --unix-socket '/run/unit/control.unit.sock' 'http://localhost/config'
        '';

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        # Security
        NoNewPrivileges = true;
        PIDFile = "/run/unit/unit.pid";
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = false;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        # Sandboxing
        ProtectSystem = "strict";

        # Access write directories
        ReadWritePaths = [
          cfg.stateDir
          cfg.logDir
        ];

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        # Runtime directory and mode
        RuntimeDirectory = "unit";
        RuntimeDirectoryMode = "0750";
        # System Call Filtering
        SystemCallArchitectures = "native";
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.stateDir}' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.logDir}' 0750 ${cfg.user} ${cfg.group} - -"
    ];

    users.groups = optionalAttrs (cfg.group == "unit") {
      unit = { };
    };

    users.users = optionalAttrs (cfg.user == "unit") {
      unit = {
        group = cfg.group;
        isSystemUser = true;
      };
    };

  };
}
