{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.asterisk;

  asteriskUser = "asterisk";
  asteriskGroup = "asterisk";

  varlibdir = "/var/lib/asterisk";
  spooldir = "/var/spool/asterisk";
  logdir = "/var/log/asterisk";

  # Add filecontents from files of useTheseDefaultConfFiles to confFiles, do not override
  defaultConfFiles = lib.subtractLists (lib.attrNames cfg.confFiles) cfg.useTheseDefaultConfFiles;
  allConfFiles = {
    # Default asterisk.conf file
    "asterisk.conf".text = ''
      [directories]
      astetcdir => /etc/asterisk
      astmoddir => ${cfg.package}/lib/asterisk/modules
      astvarlibdir => /var/lib/asterisk
      astdbdir => /var/lib/asterisk
      astkeydir => /var/lib/asterisk
      astdatadir => /var/lib/asterisk
      astagidir => /var/lib/asterisk/agi-bin
      astspooldir => /var/spool/asterisk
      astrundir => /run/asterisk
      astlogdir => /var/log/asterisk
      astsbindir => ${cfg.package}/sbin
      ${cfg.extraConfig}
    '';

    # Use syslog for logging so logs can be viewed with journalctl
    "logger.conf".text = ''
      [general]

      [logfiles]
      syslog.local0 => notice,warning,error
    '';

    # Loading all modules by default is considered sensible by the authors of
    # "Asterisk: The Definitive Guide". Secure sites will likely want to
    # specify their own "modules.conf" in the confFiles option.
    "modules.conf".text = ''
      [modules]
      autoload=yes
    '';
  }
  // lib.mapAttrs (name: text: { inherit text; }) cfg.confFiles
  // lib.listToAttrs (
    map (x: lib.nameValuePair x { source = cfg.package + "/etc/asterisk/" + x; }) defaultConfFiles
  );

in

{
  options = {
    services.asterisk = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the Asterisk PBX server.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "asterisk" { };

      confFiles = lib.mkOption {
        default = { };

        description = ''
          Sets the content of config files (typically ending with
          `.conf`) in the Asterisk configuration directory.

          Note that if you want to change {file}`asterisk.conf`, it
          is preferable to use the {option}`services.asterisk.extraConfig`
          option over this option. If `"asterisk.conf"` is
          specified with the {option}`confFiles` option (not recommended),
          you must be prepared to set your own `astetcdir`
          path.

          See
          <https://www.asterisk.org/community/documentation/>
          for more examples of what is possible here.
        '';

        example = lib.literalExpression ''
          {
            "extensions.conf" = '''
              [tests]
              ; Dial 100 for "hello, world"
              exten => 100,1,Answer()
              same  =>     n,Wait(1)
              same  =>     n,Playback(hello-world)
              same  =>     n,Hangup()

              [softphones]
              include => tests

              [unauthorized]
            ''';
            "sip.conf" = '''
              [general]
              allowguest=no              ; Require authentication
              context=unauthorized       ; Send unauthorized users to /dev/null
              srvlookup=no               ; Don't do DNS lookup
              udpbindaddr=0.0.0.0        ; Listen on all interfaces
              nat=force_rport,comedia    ; Assume device is behind NAT

              [softphone](!)
              type=friend                ; Match on username first, IP second
              context=softphones         ; Send to softphones context in
                                         ; extensions.conf file
              host=dynamic               ; Device will register with asterisk
              disallow=all               ; Manually specify codecs to allow
              allow=g722
              allow=ulaw
              allow=alaw

              [myphone](softphone)
              secret=GhoshevFew          ; Change this password!
            ''';
            "logger.conf" = '''
              [general]

              [logfiles]
              ; Add debug output to log
              syslog.local0 => notice,warning,error,debug
            ''';
          }
        '';

        type = lib.types.attrsOf lib.types.str;
      };

      extraArguments = lib.mkOption {
        default = [ ];

        description = ''
          Additional command line arguments to pass to Asterisk.
        '';

        example = [
          "-vvvddd"
          "-e"
          "1024"
        ];

        type = lib.types.listOf lib.types.str;
      };

      extraConfig = lib.mkOption {
        default = "";

        description = ''
          Extra configuration options appended to the default
          {file}`asterisk.conf` file.
        '';

        example = ''
          [options]
          verbose=3
          debug=3
        '';

        type = lib.types.lines;
      };

      useTheseDefaultConfFiles = lib.mkOption {
        default = [
          "ari.conf"
          "acl.conf"
          "agents.conf"
          "amd.conf"
          "calendar.conf"
          "cdr.conf"
          "cdr_syslog.conf"
          "cdr_custom.conf"
          "cel.conf"
          "cel_custom.conf"
          "cli_aliases.conf"
          "confbridge.conf"
          "dundi.conf"
          "features.conf"
          "hep.conf"
          "iax.conf"
          "pjsip.conf"
          "pjsip_wizard.conf"
          "phone.conf"
          "phoneprov.conf"
          "queues.conf"
          "res_config_sqlite3.conf"
          "res_parking.conf"
          "statsd.conf"
          "udptl.conf"
          "unistim.conf"
        ];

        description = ''
          Sets these config files to the default content. The default value for
                    this option contains all necesscary files to avoid errors at startup.
                    This does not override settings via {option}`services.asterisk.confFiles`.
        '';

        example = [
          "sip.conf"
          "dundi.conf"
        ];

        type = lib.types.listOf lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc = lib.mapAttrs' (
      name: value: lib.nameValuePair "asterisk/${name}" value
    ) allConfFiles;

    environment.systemPackages = [ cfg.package ];

    systemd.services.asterisk = {
      description = ''
        Asterisk PBX server
      '';

      preStart = ''
        # Copy skeleton directory tree to /var
        for d in '${varlibdir}' '${spooldir}' '${logdir}'; do
          # TODO: Make exceptions for /var directories that likely should be updated
          if [ ! -e "$d" ]; then
            mkdir -p "$d"
            cp --recursive ${cfg.package}/"$d"/* "$d"/
            chown --recursive ${asteriskUser}:${asteriskGroup} "$d"
            find "$d" -type d | xargs chmod 0755
          fi
        done
      '';

      # Do not restart, to avoid disruption of running calls. Restart unit by yourself!
      restartIfChanged = false;

      serviceConfig = {
        ExecReload = ''
          ${cfg.package}/bin/asterisk -C /etc/asterisk/asterisk.conf -x "core reload"
        '';

        ExecStart =
          let
            # FIXME: This doesn't account for arguments with spaces
            argString = lib.concatStringsSep " " cfg.extraArguments;
          in
          "${cfg.package}/bin/asterisk -U ${asteriskUser} -C /etc/asterisk/asterisk.conf ${argString} -F";

        PIDFile = "/run/asterisk/asterisk.pid";
        Type = "forking";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.asterisk = {
      gid = config.ids.gids.asterisk;
      name = asteriskGroup;
    };

    users.users.asterisk = {
      description = "Asterisk daemon user";
      group = asteriskGroup;
      home = varlibdir;
      name = asteriskUser;
      uid = config.ids.uids.asterisk;
    };
  };
}
