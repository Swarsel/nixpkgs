{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.flexget;
  pkg = cfg.package;
  ymlFile = pkgs.writeText "flexget.yml" ''
    ${cfg.config}

    ${lib.optionalString cfg.systemScheduler "schedules: no"}
  '';
  configFile = "${toString cfg.homeDir}/flexget.yml";
in
{
  options = {
    services.flexget = {
      config = lib.mkOption {
        default = "";
        description = "The YAML configuration for FlexGet.";
        type = lib.types.lines;
      };

      enable = lib.mkEnableOption "FlexGet daemon";
      package = lib.mkPackageOption pkgs "flexget" { };

      homeDir = lib.mkOption {
        default = "/var/lib/deluge";
        description = "Where files live.";
        example = "/home/flexget";
        type = lib.types.path;
      };

      interval = lib.mkOption {
        default = "10m";
        description = "When to perform a {command}`flexget` run. See {command}`man 7 systemd.time` for the format.";
        example = "1h";
        type = lib.types.str;
      };

      systemScheduler = lib.mkOption {
        default = true;
        description = "When true, execute the runs via the flexget-runner.timer. If false, you have to specify the settings yourself in the YML file.";
        example = false;
        type = lib.types.bool;
      };

      user = lib.mkOption {
        default = "deluge";
        description = "The user under which to run flexget.";
        example = "some_user";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkg ];

    systemd.services = {
      flexget = {
        description = "FlexGet Daemon";
        path = [ pkg ];

        serviceConfig = {
          ExecReload = "${pkg}/bin/flexget -c ${configFile} daemon reload";
          ExecStart = "${pkg}/bin/flexget -c ${configFile} daemon start";
          ExecStartPre = "${pkgs.coreutils}/bin/install -m644 ${ymlFile} ${configFile}";
          ExecStop = "${pkg}/bin/flexget -c ${configFile} daemon stop";
          PrivateTmp = true;
          Restart = "on-failure";
          User = cfg.user;
          WorkingDirectory = toString cfg.homeDir;
        };

        wantedBy = [ "multi-user.target" ];
      };

      flexget-runner = lib.mkIf cfg.systemScheduler {
        after = [ "flexget.service" ];
        description = "FlexGet Runner";

        serviceConfig = {
          ExecStart = "${pkg}/bin/flexget -c ${configFile} execute";
          PrivateTmp = true;
          User = cfg.user;
          WorkingDirectory = toString cfg.homeDir;
        };

        wants = [ "flexget.service" ];
      };
    };

    systemd.timers.flexget-runner = lib.mkIf cfg.systemScheduler {
      description = "Run FlexGet every ${cfg.interval}";

      timerConfig = {
        OnBootSec = "5m";
        OnUnitInactiveSec = cfg.interval;
        Unit = "flexget-runner.service";
      };

      wantedBy = [ "timers.target" ];
    };
  };
}
