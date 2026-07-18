{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.fcron;

  queuelen = optionalString (cfg.queuelen != null) "-q ${toString cfg.queuelen}";

  # Duplicate code, also found in cron.nix. Needs deduplication.
  systemCronJobs = ''
    SHELL=${pkgs.bash}/bin/bash
    PATH=${config.system.path}/bin:${config.system.path}/sbin
    ${optionalString (config.services.cron.mailto != null) ''
      MAILTO="${config.services.cron.mailto}"
    ''}
    NIX_CONF_DIR=/etc/nix
    ${lib.concatStrings (map (job: job + "\n") config.services.cron.systemCronJobs)}
  '';

  allowdeny = target: users: {
    gid = config.ids.gids.fcron;
    mode = "644";
    source = pkgs.writeText "fcron.${target}" (concatStringsSep "\n" users);
    target = "fcron.${target}";
  };

in

{

  ###### interface

  options = {

    services.fcron = {

      enable = mkOption {
        default = false;
        description = "Whether to enable the {command}`fcron` daemon.";
        type = types.bool;
      };

      allow = mkOption {
        default = [ "all" ];

        description = ''
          Users allowed to use fcrontab and fcrondyn (one name per
          line, `all` for everyone).
        '';

        type = types.listOf types.str;
      };

      deny = mkOption {
        default = [ ];
        description = "Users forbidden from using fcron.";
        type = types.listOf types.str;
      };

      maxSerialJobs = mkOption {
        default = 1;
        description = "Maximum number of serial jobs which can run simultaneously.";
        type = types.int;
      };

      queuelen = mkOption {
        default = null;
        description = "Number of jobs the serial queue and the lavg queue can contain.";
        type = types.nullOr types.int;
      };

      systab = mkOption {
        default = "";
        description = ''The "system" crontab contents.'';
        type = types.lines;
      };
    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    environment.etc = listToAttrs (
      map
        (x: {
          name = x.target;
          value = x;
        })
        [
          (allowdeny "allow" (cfg.allow))
          (allowdeny "deny" cfg.deny)
          # see man 5 fcron.conf
          {
            gid = config.ids.gids.fcron;
            mode = "0644";

            source =
              let
                isSendmailWrapped = lib.hasAttr "sendmail" config.security.wrappers;
                sendmailPath =
                  if isSendmailWrapped then "/run/wrappers/bin/sendmail" else "${config.system.path}/bin/sendmail";
              in
              pkgs.writeText "fcron.conf" ''
                fcrontabs   =       /var/spool/fcron
                pidfile     =       /run/fcron.pid
                fifofile    =       /run/fcron.fifo
                fcronallow  =       /etc/fcron.allow
                fcrondeny   =       /etc/fcron.deny
                shell       =       /bin/sh
                sendmail    =       ${sendmailPath}
                editor      =       ${pkgs.vim}/bin/vim
              '';

            target = "fcron.conf";
          }
        ]
    );

    environment.systemPackages = [ pkgs.fcron ];

    security.wrappers = {
      fcrondyn = {
        group = "fcron";
        owner = "fcron";
        setgid = true;
        setuid = false;
        source = "${pkgs.fcron}/bin/fcrondyn";
      };

      fcronsighup = {
        group = "fcron";
        owner = "root";
        setuid = true;
        source = "${pkgs.fcron}/bin/fcronsighup";
      };

      fcrontab = {
        group = "fcron";
        owner = "fcron";
        setgid = true;
        setuid = true;
        source = "${pkgs.fcron}/bin/fcrontab";
      };
    };

    services.fcron.systab = systemCronJobs;

    systemd.services.fcron = {
      description = "fcron daemon";
      path = [ pkgs.fcron ];

      preStart = ''
        install \
          --mode 0770 \
          --owner fcron \
          --group fcron \
          --directory /var/spool/fcron
        # load system crontab file
        /run/wrappers/bin/fcrontab -u systab - < ${pkgs.writeText "systab" cfg.systab}
      '';

      serviceConfig = {
        ExecStart = "${pkgs.fcron}/sbin/fcron -m ${toString cfg.maxSerialJobs} ${queuelen}";
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.fcron.gid = config.ids.gids.fcron;

    users.users.fcron = {
      group = "fcron";
      home = "/var/spool/fcron";
      uid = config.ids.uids.fcron;
    };
  };
}
