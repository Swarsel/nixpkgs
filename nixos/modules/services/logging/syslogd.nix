{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.syslogd;

  syslogConf = pkgs.writeText "syslog.conf" ''
    ${lib.optionalString (cfg.tty != "") "kern.warning;*.err;authpriv.none /dev/${cfg.tty}"}
    ${cfg.defaultConfig}
    ${cfg.extraConfig}
  '';

  defaultConf = ''
    # Send emergency messages to all users.
    *.emerg                       *

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

    services.syslogd = {

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

      enableNetworkInput = lib.mkOption {
        default = false;

        description = ''
          Accept logging through UDP. Option -r of {manpage}`syslogd(8)`.
        '';

        type = lib.types.bool;
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
          Additional parameters passed to {command}`syslogd`.
        '';

        example = [ "-m 0" ];
        type = lib.types.listOf lib.types.str;
      };

      tty = lib.mkOption {
        default = "tty10";

        description = ''
          The tty device on which syslogd will print important log
          messages. Leave this option blank to disable tty logging.
        '';

        type = lib.types.str;
      };

    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = !config.services.rsyslogd.enable;
        message = "rsyslogd conflicts with syslogd";
      }
    ];

    environment.systemPackages = [ pkgs.sysklogd ];
    services.syslogd.extraParams = lib.optional cfg.enableNetworkInput "-r";

    # FIXME: restarting syslog seems to break journal logging.
    systemd.services.syslog = {
      description = "Syslog Daemon";
      requires = [ "syslog.socket" ];

      serviceConfig = {
        ExecStart = "${pkgs.sysklogd}/sbin/syslogd ${toString cfg.extraParams} -f ${syslogConf} -n";
        # Prevent syslogd output looping back through journald.
        StandardOutput = "null";
      };

      wantedBy = [ "multi-user.target" ];
    };

  };

}
