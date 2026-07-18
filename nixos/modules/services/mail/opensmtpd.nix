{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.opensmtpd;
  conf = pkgs.writeText "smtpd.conf" cfg.serverConfiguration;
  args = lib.concatStringsSep " " cfg.extraServerArgs;

  sendmail = pkgs.runCommand "opensmtpd-sendmail" { preferLocalBuild = true; } ''
    mkdir -p $out/bin
    ln -s ${cfg.package}/sbin/smtpctl $out/bin/sendmail
  '';

in
{

  ###### interface

  imports = [
    (lib.mkRenamedOptionModule
      [ "services" "opensmtpd" "addSendmailToSystemPath" ]
      [ "services" "opensmtpd" "setSendmail" ]
    )
  ];

  options = {

    services.opensmtpd = {

      enable = lib.mkOption {
        default = false;
        description = "Whether to enable the OpenSMTPD server.";
        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "opensmtpd" { };

      extraServerArgs = lib.mkOption {
        default = [ ];

        description = ''
          Extra command line arguments provided when the smtpd process
          is started.
        '';

        example = [
          "-v"
          "-P mta"
        ];

        type = lib.types.listOf lib.types.str;
      };

      procPackages = lib.mkOption {
        default = [ ];

        description = ''
          Packages to search for filters, tables, queues, and schedulers.

          Add packages here if you want to use them as as such, for example
          from the opensmtpd-table-* packages.
        '';

        type = lib.types.listOf lib.types.package;
      };

      serverConfiguration = lib.mkOption {
        description = ''
          The contents of the smtpd.conf configuration file. See the
          OpenSMTPD documentation for syntax information.
        '';

        example = ''
          listen on lo
          accept for any deliver to lmtp localhost:24
        '';

        type = lib.types.lines;
      };

      setSendmail = lib.mkOption {
        default = true;
        description = "Whether to set the system sendmail to OpenSMTPD's.";
        type = lib.types.bool;
      };
    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable rec {
    security.wrappers = {
      makemap = {
        group = "smtpq";
        owner = "root";
        setgid = true;
        setuid = false;
        source = "${cfg.package}/bin/smtpctl";
      };

      smtpctl = {
        group = "smtpq";
        owner = "root";
        setgid = true;
        setuid = false;
        source = "${cfg.package}/bin/smtpctl";
      };
    };

    services.mail.sendmailSetuidWrapper = lib.mkIf cfg.setSendmail (
      security.wrappers.smtpctl
      // {
        program = "sendmail";
        source = "${sendmail}/bin/sendmail";
      }
    );

    systemd.services.opensmtpd =
      let
        procEnv = pkgs.buildEnv {
          name = "opensmtpd-procs";
          paths = [ cfg.package ] ++ cfg.procPackages;
          pathsToLink = [ "/libexec/smtpd" ];
        };
      in
      {
        after = [ "network.target" ];
        environment.OPENSMTPD_PROC_PATH = "${procEnv}/libexec/smtpd";
        serviceConfig.ExecStart = "${cfg.package}/sbin/smtpd -d -f ${conf} ${args}";
        wantedBy = [ "multi-user.target" ];
      };

    systemd.tmpfiles.settings.opensmtpd = {
      "/var/spool/smtpd".d = {
        mode = "0711";
        user = "root";
      };

      "/var/spool/smtpd/offline".d = {
        group = "smtpq";
        mode = "0770";
        user = "root";
      };

      "/var/spool/smtpd/purge".d = {
        group = "root";
        mode = "0700";
        user = "smtpq";
      };

      "/var/spool/smtpd/queue".d = {
        group = "root";
        mode = "0700";
        user = "smtpq";
      };
    };

    users.groups = {
      smtpd.gid = config.ids.gids.smtpd;
      smtpq.gid = config.ids.gids.smtpq;
    };

    users.users = {
      smtpd = {
        description = "OpenSMTPD process user";
        group = "smtpd";
        uid = config.ids.uids.smtpd;
      };

      smtpq = {
        description = "OpenSMTPD queue user";
        group = "smtpq";
        uid = config.ids.uids.smtpq;
      };
    };
  };
}
