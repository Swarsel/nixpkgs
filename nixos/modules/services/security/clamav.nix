{
  config,
  lib,
  pkgs,
  ...
}:
let
  clamavUser = "clamav";
  stateDir = "/var/lib/clamav";
  clamavGroup = clamavUser;
  cfg = config.services.clamav;

  toKeyValue = lib.generators.toKeyValue {
    listsAsDuplicateKeys = true;
    mkKeyValue = lib.generators.mkKeyValueDefault { } " ";
  };

  clamdConfigFile = pkgs.writeText "clamd.conf" (toKeyValue cfg.daemon.settings);
  freshclamConfigFile = pkgs.writeText "freshclam.conf" (toKeyValue cfg.updater.settings);
  fangfrischConfigFile = pkgs.writeText "fangfrisch.conf" ''
    ${lib.generators.toINI { } cfg.fangfrisch.settings}
  '';
in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "clamav"
      "updater"
      "config"
    ] "Use services.clamav.updater.settings instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "clamav"
      "updater"
      "extraConfig"
    ] "Use services.clamav.updater.settings instead.")
    (lib.mkRemovedOptionModule [
      "services"
      "clamav"
      "daemon"
      "extraConfig"
    ] "Use services.clamav.daemon.settings instead.")
  ];

  options = {
    services.clamav = {
      package = lib.mkPackageOption pkgs "clamav" { };

      clamonacc = {
        enable = lib.mkOption {
          default = false;

          description = ''
            Whether to enable ClamAV on-access scanner.

            The settings for ClamAV's on-access scanner is configured in `clamd.conf` via `services.clamav.daemon.settings`.
            Refer to <https://docs.clamav.net/manual/OnAccess.html> on how to configure it.

            Example to scan `/home/foo/Downloads` (and block access until scanning is completed) would be:
            ```
            services.clamav = {
              daemon.enable = true;
              clamonacc.enable = true;

              daemon.settings = {
                OnAccessPrevention = true;
                OnAccessIncludePath = "/home/foo/Downloads";
              };
            };
            ```
          '';

          example = true;
          type = lib.types.bool;
        };
      };

      daemon = {
        enable = lib.mkEnableOption "ClamAV clamd daemon";

        settings = lib.mkOption {
          default = { };

          description = ''
            ClamAV configuration. Refer to <https://linux.die.net/man/5/clamd.conf>,
            for details on supported values.
          '';

          type =
            with lib.types;
            attrsOf (oneOf [
              bool
              int
              str
              (listOf str)
            ]);
        };
      };

      fangfrisch = {
        enable = lib.mkEnableOption "ClamAV fangfrisch updater";

        interval = lib.mkOption {
          default = "hourly";

          description = ''
            How often freshclam is invoked. See {manpage}`systemd.time(7)` for more
            information about the format.
          '';

          type = lib.types.str;
        };

        settings = lib.mkOption {
          default = { };

          description = ''
            fangfrisch configuration. Refer to <https://rseichter.github.io/fangfrisch/#_configuration>,
            for details on supported values.
            Note that by default urlhaus and sanesecurity are enabled.
          '';

          example = {
            securiteinfo = {
              customer_id = "your customer_id";
              enabled = "yes";
            };
          };

          type = lib.types.submodule {
            freeformType =
              with lib.types;
              attrsOf (
                attrsOf (oneOf [
                  str
                  int
                  bool
                ])
              );
          };
        };
      };

      scanner = {
        enable = lib.mkEnableOption "ClamAV scanner";

        interval = lib.mkOption {
          default = "*-*-* 04:00:00";

          description = ''
            How often clamdscan is invoked. See {manpage}`systemd.time(7)` for more
            information about the format.
            By default this runs using 10 cores at most, be sure to run it at a time of low traffic.
          '';

          type = lib.types.str;
        };

        scanDirectories = lib.mkOption {
          default = [
            "/home"
            "/var/lib"
            "/tmp"
            "/etc"
            "/var/tmp"
          ];

          description = ''
            List of directories to scan.
            The default includes everything I could think of that is valid for nixos. Feel free to contribute a PR to add to the default if you see something missing.
          '';

          type = with lib.types; listOf str;
        };
      };

      updater = {
        enable = lib.mkEnableOption "ClamAV freshclam updater";

        frequency = lib.mkOption {
          default = 12;

          description = ''
            Number of database checks per day.
          '';

          type = lib.types.int;
        };

        interval = lib.mkOption {
          default = "hourly";

          description = ''
            How often freshclam is invoked. See {manpage}`systemd.time(7)` for more
            information about the format.
          '';

          type = lib.types.str;
        };

        settings = lib.mkOption {
          default = { };

          description = ''
            freshclam configuration. Refer to <https://linux.die.net/man/5/freshclam.conf>,
            for details on supported values.
          '';

          type =
            with lib.types;
            attrsOf (oneOf [
              bool
              int
              str
              (listOf str)
            ]);
        };
      };
    };
  };

  config = lib.mkIf (cfg.updater.enable || cfg.daemon.enable) {
    assertions = [
      {
        assertion = cfg.scanner.enable -> cfg.daemon.enable;
        message = "ClamAV scanner requires ClamAV daemon to operate";
      }
      {
        assertion = cfg.clamonacc.enable -> cfg.daemon.enable;
        message = "ClamAV on-access scanner requires ClamAV daemon to operate";
      }
    ];

    environment.etc."clamav/clamd.conf".source = clamdConfigFile;
    environment.etc."clamav/freshclam.conf".source = freshclamConfigFile;
    environment.systemPackages = [ cfg.package ];

    services.clamav.daemon.settings = {
      DatabaseDirectory = stateDir;
      Foreground = true;
      LocalSocket = "/run/clamav/clamd.ctl";
      # Prevent infinite recursion in scanning
      OnAccessExcludeUname = clamavUser;
      PidFile = "/run/clamav/clamd.pid";
      User = clamavUser;
    };

    services.clamav.fangfrisch.settings = {
      DEFAULT.db_url = lib.mkDefault "sqlite:////var/lib/clamav/fangfrisch_db.sqlite";
      DEFAULT.local_directory = lib.mkDefault stateDir;
      DEFAULT.log_level = lib.mkDefault "INFO";
      sanesecurity.enabled = lib.mkDefault "yes";
      urlhaus.enabled = lib.mkDefault "yes";
      urlhaus.max_size = lib.mkDefault "2MB";
    };

    services.clamav.updater.settings = {
      Checks = cfg.updater.frequency;
      DatabaseDirectory = stateDir;
      DatabaseMirror = [ "database.clamav.net" ];
      Foreground = true;
    };

    systemd.services.clamav-clamonacc = lib.mkIf cfg.clamonacc.enable {
      after = [ "clamav-daemon.socket" ];
      description = "ClamAV on-access scanner (clamonacc)";
      requires = [ "clamav-daemon.socket" ];
      restartTriggers = [ clamdConfigFile ];

      # This unit must start as root to be able to use fanotify.
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/clamonacc -F --fdpass";
        Slice = "system-clamav.slice";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.clamav-daemon = lib.mkIf cfg.daemon.enable {
      after = lib.optionals cfg.updater.enable [ "clamav-freshclam.service" ];
      description = "ClamAV daemon (clamd)";
      documentation = [ "man:clamd(8)" ];
      requires = [ "clamav-daemon.socket" ];
      restartTriggers = [ clamdConfigFile ];

      serviceConfig = {
        ExecReload = "${pkgs.coreutils}/bin/kill -USR2 $MAINPID";
        ExecStart = "${cfg.package}/bin/clamd";
        Group = clamavGroup;
        PrivateDevices = "yes";
        PrivateNetwork = "yes";
        PrivateTmp = "yes";
        RuntimeDirectory = "clamav";
        Slice = "system-clamav.slice";
        StateDirectory = "clamav";
        User = clamavUser;
      };

      wantedBy = [ "multi-user.target" ];
      wants = lib.optionals cfg.updater.enable [ "clamav-freshclam.service" ];
    };

    systemd.services.clamav-fangfrisch = lib.mkIf cfg.fangfrisch.enable {
      after = [
        "network-online.target"
        "clamav-fangfrisch-init.service"
      ];

      description = "ClamAV virus database updater (fangfrisch)";
      requires = [ "network-online.target" ];
      restartTriggers = [ fangfrischConfigFile ];

      serviceConfig = {
        ExecStart = "${pkgs.fangfrisch}/bin/fangfrisch --conf ${fangfrischConfigFile} refresh";
        Group = clamavGroup;
        PrivateDevices = "yes";
        PrivateTmp = "yes";
        Slice = "system-clamav.slice";
        StateDirectory = "clamav";
        Type = "oneshot";
        User = clamavUser;
      };
    };

    systemd.services.clamav-fangfrisch-init = lib.mkIf cfg.fangfrisch.enable {
      # if the sqlite file can be found assume the database has already been initialised
      script = ''
        db_url="${cfg.fangfrisch.settings.DEFAULT.db_url}"
        db_path="''${db_url#sqlite:///}"

        if [ ! -f "$db_path" ]; then
          ${pkgs.fangfrisch}/bin/fangfrisch --conf ${fangfrischConfigFile} initdb
        fi
      '';

      serviceConfig = {
        Group = clamavGroup;
        PrivateDevices = "yes";
        PrivateTmp = "yes";
        Slice = "system-clamav.slice";
        StateDirectory = "clamav";
        Type = "oneshot";
        User = clamavUser;
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.clamav-freshclam = lib.mkIf cfg.updater.enable {
      after = [ "network-online.target" ];
      description = "ClamAV virus database updater (freshclam)";
      documentation = [ "man:freshclam(1)" ];
      requires = [ "network-online.target" ];
      restartTriggers = [ freshclamConfigFile ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/freshclam";
        Group = clamavGroup;
        PrivateDevices = "yes";
        PrivateTmp = "yes";
        Slice = "system-clamav.slice";
        StateDirectory = "clamav";
        SuccessExitStatus = "1"; # if databases are up to date
        Type = "oneshot";
        User = clamavUser;
      };
    };

    systemd.services.clamdscan = lib.mkIf cfg.scanner.enable {
      after = lib.optionals cfg.updater.enable [ "clamav-freshclam.service" ];
      description = "ClamAV virus scanner";
      documentation = [ "man:clamdscan(1)" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/clamdscan --multiscan --fdpass --infected --allmatch ${lib.concatStringsSep " " cfg.scanner.scanDirectories}";
        Slice = "system-clamav.slice";
        Type = "oneshot";
      };

      wants = lib.optionals cfg.updater.enable [ "clamav-freshclam.service" ];
    };

    systemd.slices.system-clamav = {
      description = "ClamAV Antivirus Slice";
    };

    systemd.sockets.clamav-daemon = lib.mkIf cfg.daemon.enable {
      description = "Socket for ClamAV daemon (clamd)";

      listenStreams = [
        cfg.daemon.settings.LocalSocket
      ];

      socketConfig = {
        SocketGroup = clamavGroup;
        # LocalSocketMode setting in clamd.conf is not prefixed with octal 0, add it here.
        SocketMode = "0${cfg.daemon.settings.LocalSocketMode or "666"}";
        SocketUser = clamavUser;
      };

      wantedBy = [ "sockets.target" ];
    };

    systemd.timers.clamav-fangfrisch = lib.mkIf cfg.fangfrisch.enable {
      description = "Timer for ClamAV virus database updater (fangfrisch)";

      timerConfig = {
        OnCalendar = cfg.fangfrisch.interval;
        Unit = "clamav-fangfrisch.service";
      };

      wantedBy = [ "timers.target" ];
    };

    systemd.timers.clamav-freshclam = lib.mkIf cfg.updater.enable {
      description = "Timer for ClamAV virus database updater (freshclam)";

      timerConfig = {
        OnCalendar = cfg.updater.interval;
        Unit = "clamav-freshclam.service";
      };

      wantedBy = [ "timers.target" ];
    };

    systemd.timers.clamdscan = lib.mkIf cfg.scanner.enable {
      description = "Timer for ClamAV virus scanner";

      timerConfig = {
        OnCalendar = cfg.scanner.interval;
        Unit = "clamdscan.service";
      };

      wantedBy = [ "timers.target" ];
    };

    users.groups.${clamavGroup} = {
      gid = config.ids.gids.clamav;
    };

    users.users.${clamavUser} = {
      description = "ClamAV daemon user";
      group = clamavGroup;
      home = stateDir;
      uid = config.ids.uids.clamav;
    };
  };
}
