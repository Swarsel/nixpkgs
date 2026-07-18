{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  # Put all the system cronjobs together.
  systemCronJobsFile = pkgs.writeText "system-crontab" ''
    SHELL=${pkgs.bash}/bin/bash
    PATH=${config.system.path}/bin:${config.system.path}/sbin
    ${optionalString (config.services.cron.mailto != null) ''
      MAILTO="${config.services.cron.mailto}"
    ''}
    NIX_CONF_DIR=/etc/nix
    ${lib.concatStrings (map (job: job + "\n") config.services.cron.systemCronJobs)}
  '';

  # Vixie cron requires build-time configuration for the sendmail path.
  cronNixosPkg = pkgs.cron.override {
    # The mail.nix nixos module, if there is any local mail system enabled,
    # should have sendmail in this path.
    sendmailPath = "/run/wrappers/bin/sendmail";
  };

  allFiles =
    optional (config.services.cron.systemCronJobs != [ ]) systemCronJobsFile
    ++ config.services.cron.cronFiles;

in

{

  ###### interface

  options = {

    services.cron = {

      enable = mkOption {
        default = false;
        description = "Whether to enable the Vixie cron daemon.";
        type = types.bool;
      };

      cronFiles = mkOption {
        default = [ ];

        description = ''
          A list of extra crontab files that will be read and appended to the main
          crontab file when the cron service starts.
        '';

        type = types.listOf types.path;
      };

      mailto = mkOption {
        default = null;
        description = "Email address to which job output will be mailed.";
        type = types.nullOr types.str;
      };

      systemCronJobs = mkOption {
        default = [ ];

        description = ''
          A list of Cron jobs to be appended to the system-wide
          crontab.  See the manual page for crontab for the expected
          format. If you want to get the results mailed you must setuid
          sendmail. See {option}`security.wrappers`

          If neither /var/cron/cron.deny nor /var/cron/cron.allow exist only root
          is allowed to have its own crontab file. The /var/cron/cron.deny file
          is created automatically for you, so every user can use a crontab.

          Many nixos modules set systemCronJobs, so if you decide to disable vixie cron
          and enable another cron daemon, you may want it to get its system crontab
          based on systemCronJobs.
        '';

        example = literalExpression ''
          [ "* * * * *  test   ls -l / > /tmp/cronout 2>&1"
            "* * * * *  eelco  echo Hello World > /home/eelco/cronout"
          ]
        '';

        type = types.listOf types.str;
      };

    };

  };

  ###### implementation

  config = mkMerge [

    { services.cron.enable = mkDefault (allFiles != [ ]); }
    (mkIf (config.services.cron.enable) {
      environment.etc.crontab = {
        mode = "0600"; # Cron requires this.

        source =
          pkgs.runCommand "crontabs"
            {
              inherit allFiles;
              preferLocalBuild = true;
            }
            ''
              touch $out
              for i in $allFiles; do
                cat "$i" >> $out
              done
            '';
      };

      environment.systemPackages = [ cronNixosPkg ];

      security.wrappers.crontab = {
        group = "root";
        owner = "root";
        setuid = true;
        source = "${cronNixosPkg}/bin/crontab";
      };

      systemd.services.cron = {
        description = "Cron Daemon";

        preStart = ''
          (umask 022 && mkdir -p /var)
          (umask 067 && mkdir -p /var/cron)

          # By default, allow all users to create a crontab.  This
          # is denoted by the existence of an empty cron.deny file.
          if ! test -e /var/cron/cron.allow -o -e /var/cron/cron.deny; then
              touch /var/cron/cron.deny
          fi
        '';

        restartTriggers = [ config.time.timeZone ];
        serviceConfig.ExecStart = "${cronNixosPkg}/bin/cron -n";
        wantedBy = [ "multi-user.target" ];
      };

    })

  ];

}
