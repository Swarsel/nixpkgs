{
  config,
  lib,
  pkgs,
  ...
}:
{

  options = {

    services.nullmailer = {
      config = {
        adminaddr = lib.mkOption {
          default = null;

          description = ''
            If set, all recipients to users at either "localhost" (the literal string)
            or the canonical host name (from the me control attribute) are remapped to this address.
            This is provided to allow local daemons to be able to send email to
            "somebody@localhost" and have it go somewhere sensible instead of being  bounced
            by your relay host. To send to multiple addresses,
            put them all on one line separated by a comma.
          '';

          type = lib.types.nullOr lib.types.str;
        };

        allmailfrom = lib.mkOption {
          default = null;

          description = ''
            If set, content will override the envelope sender on all messages.
          '';

          type = lib.types.nullOr lib.types.str;
        };

        defaultdomain = lib.mkOption {
          default = null;

          description = ''
            The content of this attribute is appended to any host name that
            does not contain a period (except localhost), including defaulthost
            and idhost. Defaults to the value of the me attribute, if it exists,
            otherwise the literal name defauldomain.
          '';

          type = lib.types.nullOr lib.types.str;
        };

        defaulthost = lib.mkOption {
          default = null;

          description = ''
            The content of this attribute is appended to any address that
            is missing a host name. Defaults to the value of the me control
            attribute, if it exists, otherwise the literal name defaulthost.
          '';

          type = lib.types.nullOr lib.types.str;
        };

        doublebounceto = lib.mkOption {
          default = null;

          description = ''
            If the original sender was empty (the original message was a
            delivery status or disposition notification), the double bounce
            is sent to the address in this attribute.
          '';

          type = lib.types.nullOr lib.types.str;
        };

        helohost = lib.mkOption {
          default = null;

          description = ''
            Sets  the  environment variable $HELOHOST which is used by the
            SMTP protocol module to set the parameter given to the HELO command.
            Defaults to the value of the me configuration attribute.
          '';

          type = lib.types.nullOr lib.types.str;
        };

        idhost = lib.mkOption {
          default = null;

          description = ''
            The content of this attribute is used when building the message-id
            string for the message. Defaults to the canonicalized value of defaulthost.
          '';

          type = lib.types.nullOr lib.types.str;
        };

        maxpause = lib.mkOption {
          default = null;

          description = ''
            The maximum time to pause between successive queue runs, in seconds.
            Defaults to 24 hours (86400).
          '';

          type =
            with lib.types;
            nullOr (oneOf [
              str
              int
            ]);
        };

        me = lib.mkOption {
          default = null;

          description = ''
            The fully-qualifiled host name of the computer running nullmailer.
            Defaults to the literal name me.
          '';

          type = lib.types.nullOr lib.types.str;
        };

        pausetime = lib.mkOption {
          default = null;

          description = ''
            The minimum time to pause between successive queue runs when there
            are messages in the queue, in seconds. Defaults to 1 minute (60).
            Each time this timeout is reached, the timeout is doubled to a
            maximum of maxpause. After new messages are injected, the timeout
            is reset.  If this is set to 0, nullmailer-send will exit
            immediately after going through the queue once (one-shot mode).
          '';

          type =
            with lib.types;
            nullOr (oneOf [
              str
              int
            ]);
        };

        remotes = lib.mkOption {
          default = null;

          description = ''
            A list of remote servers to which to send each message. Each line
            contains a remote host name or address followed by an optional
            protocol string, separated by white space.

            See `man 8 nullmailer-send` for syntax and available
            options.

            WARNING: This is stored world-readable in the nix store. If you need
            to specify any secret credentials here, consider using the
            `remotesFile` option instead.
          '';

          type = lib.types.nullOr lib.types.str;
        };

        sendtimeout = lib.mkOption {
          default = null;

          description = ''
            The  time to wait for a remote module listed above to complete sending
            a message before killing it and trying again, in seconds.
            Defaults to 1 hour (3600).  If this is set to 0, nullmailer-send
            will wait forever for messages to complete sending.
          '';

          type =
            with lib.types;
            nullOr (oneOf [
              str
              int
            ]);
        };
      };

      enable = lib.mkOption {
        default = false;
        description = "Whether to enable nullmailer daemon.";
        type = lib.types.bool;
      };

      group = lib.mkOption {
        default = "nullmailer";

        description = ''
          Group to use to run nullmailer-send.
        '';

        type = lib.types.str;
      };

      remotesFile = lib.mkOption {
        default = null;

        description = ''
          Path to the `remotes` control file. This file contains a
          list of remote servers to which to send each message.

          See `man 8 nullmailer-send` for syntax and available
          options.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      setSendmail = lib.mkOption {
        default = true;
        description = "Whether to set the system sendmail to nullmailer's.";
        type = lib.types.bool;
      };

      user = lib.mkOption {
        default = "nullmailer";

        description = ''
          User to use to run nullmailer-send.
        '';

        type = lib.types.str;
      };
    };
  };

  config =
    let
      cfg = config.services.nullmailer;
    in
    lib.mkIf cfg.enable {

      assertions = [
        {
          assertion = cfg.config.remotes == null || cfg.remotesFile == null;
          message = "Only one of `remotesFile` or `config.remotes` may be used at a time.";
        }
      ];

      environment = {
        etc =
          let
            validAttrs = lib.mapAttrs (_: toString) (lib.filterAttrs (_: value: value != null) cfg.config);
          in
          (lib.foldl' (as: name: as // { "nullmailer/${name}".text = validAttrs.${name}; }) { } (
            lib.attrNames validAttrs
          ))
          // lib.optionalAttrs (cfg.remotesFile != null) { "nullmailer/remotes".source = cfg.remotesFile; };

        systemPackages = [ pkgs.nullmailer ];
      };

      services.mail.sendmailSetuidWrapper = lib.mkIf cfg.setSendmail {
        inherit (cfg) group;
        owner = cfg.user;
        program = "sendmail";
        setgid = true;
        setuid = true;
        source = "${pkgs.nullmailer}/bin/sendmail";
      };

      systemd.services.nullmailer = {
        after = [ "network.target" ];
        description = "nullmailer";

        serviceConfig = {
          ExecStart = "${pkgs.nullmailer}/bin/nullmailer-send";

          ExecStartPre = [
            "${lib.getExe' pkgs.coreutils "rm"} -f /var/spool/nullmailer/trigger"
            "${lib.getExe' pkgs.coreutils "mkfifo"} -m 660 /var/spool/nullmailer/trigger"
          ];

          Group = cfg.group;
          Restart = "always";
          User = cfg.user;
        };

        wantedBy = [ "multi-user.target" ];
      };

      systemd.tmpfiles.rules = [
        "d /var/spool/nullmailer - ${cfg.user} ${cfg.group} - -"
        "d /var/spool/nullmailer/failed 770 ${cfg.user} ${cfg.group} - -"
        "d /var/spool/nullmailer/queue 770 ${cfg.user} ${cfg.group} - -"
        "d /var/spool/nullmailer/tmp 770 ${cfg.user} ${cfg.group} - -"
      ];

      users = {
        groups.${cfg.group} = { };

        users.${cfg.user} = {
          inherit (cfg) group;
          description = "Nullmailer relay-only mta user";
          isSystemUser = true;
        };
      };
    };
}
