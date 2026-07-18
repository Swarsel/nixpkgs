{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.rsyslogd;

  syslogConf = pkgs.writeText "syslog.conf" ''
    $ModLoad imuxsock
    $SystemLogSocketName /run/systemd/journal/syslog
    $WorkDirectory /var/spool/rsyslog

    ${cfg.defaultConfig}
    ${cfg.extraConfig}
  '';

  defaultConf = ''
    # "local1" is used for dhcpd messages.
    local1.*                     -/var/log/dhcpd

    mail.*                       -/var/log/mail

    *.=warning;*.=err            -/var/log/warn
    *.crit                        /var/log/warn

    *.*;mail.none;local1.none    -/var/log/messages
  '';

in

{
  ###### interface

  options = {

    services.rsyslogd = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable syslogd.  Note that systemd also logs
          syslog messages, so you normally don't need to run syslogd.
        '';

        type = lib.types.bool;
      };

      defaultConfig = lib.mkOption {
        default = defaultConf;

        description = ''
          The default {file}`syslog.conf` file configures a
          fairly standard setup of log files, which can be extended by
          means of {var}`extraConfig`.
        '';

        type = lib.types.lines;
      };

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Additional text appended to {file}`syslog.conf`,
          i.e. the contents of {var}`defaultConfig`.
        '';

        example = "news.* -/var/log/news";
        type = lib.types.lines;
      };

      extraParams = lib.mkOption {
        default = [ ];

        description = ''
          Additional parameters passed to {command}`rsyslogd`.
        '';

        example = [ "-m 0" ];
        type = lib.types.listOf lib.types.str;
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.rsyslog ];

    systemd.services.syslog = {
      description = "Syslog Daemon";
      requires = [ "syslog.socket" ];

      serviceConfig = {
        ExecStart = "${pkgs.rsyslog}/sbin/rsyslogd ${toString cfg.extraParams} -f ${syslogConf} -n";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/spool/rsyslog";
        # Prevent syslogd output looping back through journald.
        StandardOutput = "null";
      };

      wantedBy = [ "multi-user.target" ];
    };

  };

}
