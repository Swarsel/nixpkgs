{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.syslog-ng;

  syslogngConfig = pkgs.writeText "syslog-ng.conf" ''
    ${cfg.configHeader}
    ${cfg.extraConfig}
  '';

  ctrlSocket = "/run/syslog-ng/syslog-ng.ctl";
  pidFile = "/run/syslog-ng/syslog-ng.pid";
  persistFile = "/var/syslog-ng/syslog-ng.persist";

  syslogngOptions = [
    "--foreground"
    "--module-path=${
      lib.concatStringsSep ":" ([ "${cfg.package}/lib/syslog-ng" ] ++ cfg.extraModulePaths)
    }"
    "--cfgfile=${syslogngConfig}"
    "--control=${ctrlSocket}"
    "--persist-file=${persistFile}"
    "--pidfile=${pidFile}"
  ];

in
{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "syslog-ng" "serviceName" ] "")
    (lib.mkRemovedOptionModule [ "services" "syslog-ng" "listenToJournal" ] "")
  ];

  options = {

    services.syslog-ng = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the syslog-ng daemon.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "syslogng" { };

      configHeader = lib.mkOption {
        default = ''
          @version: 4.4
          @include "scl.conf"
        '';

        description = ''
          The very first lines of the configuration file. Should usually contain
          the syslog-ng version header.
        '';

        type = lib.types.lines;
      };

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Configuration added to the end of `syslog-ng.conf`.
        '';

        type = lib.types.lines;
      };

      extraModulePaths = lib.mkOption {
        default = [ ];

        description = ''
          A list of paths that should be included in syslog-ng's
          `--module-path` option. They should usually
          end in `/lib/syslog-ng`
        '';

        type = lib.types.listOf lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.syslog-ng = {
      after = [ "multi-user.target" ]; # makes sure hostname etc is set
      description = "syslog-ng daemon";

      serviceConfig = {
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${cfg.package}/sbin/syslog-ng ${lib.concatStringsSep " " syslogngOptions}";
        ExecStartPre = "${lib.getExe' pkgs.coreutils "mkdir"} -p /var/syslog-ng /run/syslog-ng";
        PIDFile = pidFile;
        Restart = "on-failure";
        StandardOutput = "null";
        Type = "notify";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

}
