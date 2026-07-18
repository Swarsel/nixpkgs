{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.oxidized;
in
{
  options.services.oxidized = {
    enable = lib.mkEnableOption "the oxidized configuration backup service";
    package = lib.mkPackageOption pkgs "oxidized" { };

    configFile = lib.mkOption {
      description = ''
        Path to the oxidized configuration file.
      '';

      example = lib.literalExpression ''
        pkgs.writeText "oxidized-config.yml" '''
          ---
          debug: true
          use_syslog: true
          input:
            default: ssh
            ssh:
              secure: true
          interval: 3600
          model_map:
            dell: powerconnect
            hp: procurve
          source:
            default: csv
            csv:
              delimiter: !ruby/regexp /:/
              file: "/var/lib/oxidized/.config/oxidized/router.db"
              map:
                name: 0
                model: 1
                username: 2
                password: 3
          pid: "/var/lib/oxidized/.config/oxidized/pid"
          rest: 127.0.0.1:8888
          retries: 3
          # ... additional config
        ''';
      '';

      type = lib.types.nullOr lib.types.path;
    };

    dataDir = lib.mkOption {
      default = "/var/lib/oxidized";
      description = "State directory for the oxidized service.";
      type = lib.types.path;
    };

    group = lib.mkOption {
      default = "oxidized";

      description = ''
        Group under which the oxidized service runs.
      '';

      type = lib.types.str;
    };

    routerDB = lib.mkOption {
      default = null;

      description = ''
        Path to the file/database which contains the targets for oxidized.
      '';

      example = lib.literalExpression ''
        pkgs.writeText "oxidized-router.db" '''
          hostname-sw1:powerconnect:username1:password2
          hostname-sw2:procurve:username2:password2
          # ... additional hosts
        '''
      '';

      type = lib.types.nullOr lib.types.path;
    };

    user = lib.mkOption {
      default = "oxidized";

      description = ''
        User under which the oxidized service runs.
      '';

      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.oxidized = {
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        Group = cfg.group;
        KillSignal = "SIGKILL";
        NoNewPrivileges = true;
        PIDFile = "${cfg.dataDir}/.config/oxidized/pid";
        Restart = "always";
        UMask = "0077";
        User = cfg.user;
        WorkingDirectory = cfg.dataDir;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings."10-oxidized" = {
      "${cfg.dataDir}" = {
        d = {
          group = cfg.group;
          mode = "0750";
          user = cfg.user;
        };
      };

      "${cfg.dataDir}/.config" = {
        d = {
          group = cfg.group;
          mode = "0750";
          user = cfg.user;
        };
      };

      "${cfg.dataDir}/.config/oxidized" = {
        d = {
          group = cfg.group;
          mode = "0750";
          user = cfg.user;
        };
      };

    }
    // lib.optionalAttrs (cfg.configFile != null) {
      "${cfg.dataDir}/.config/oxidized/config" = {
        "L+" = {
          argument = "${cfg.configFile}";
          group = cfg.group;
          user = cfg.user;
        };
      };

    }
    // lib.optionalAttrs (cfg.routerDB != null) {
      "${cfg.dataDir}/.config/oxidized/router.db" = {
        "L+" = {
          argument = "${cfg.routerDB}";
          group = cfg.group;
          user = cfg.user;
        };
      };
    };

    users.groups.${cfg.group} = { };

    users.users.${cfg.user} = {
      createHome = true;
      description = "Oxidized service user";
      group = cfg.group;
      home = cfg.dataDir;
      isSystemUser = true;
    };
  };
}
