{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  inherit (lib)
    mkRenamedOptionModule
    mkAliasOptionModule
    mkEnableOption
    mkOption
    types
    literalExpression
    mkPackageOption
    mkIf
    optionalString
    optional
    mkDefault
    mkOptionDefault
    versionOlder
    escapeShellArgs
    optionalAttrs
    mkMerge
    ;

  cfg = config.services.transmission;
  opt = options.services.transmission;
  apparmor = config.security.apparmor;
  rootDir = "/run/transmission";
  settingsDir = ".config/transmission-daemon";
  downloadsDir = "Downloads";
  incompleteDir = ".incomplete";
  watchDir = "watchdir";
  settingsFormat = pkgs.formats.json { };
  settingsFile = settingsFormat.generate "settings.json" cfg.settings;
in
{
  imports = [
    (mkRenamedOptionModule
      [
        "services"
        "transmission"
        "port"
      ]
      [
        "services"
        "transmission"
        "settings"
        "rpc-port"
      ]
    )
    (mkAliasOptionModule
      [
        "services"
        "transmission"
        "openFirewall"
      ]
      [
        "services"
        "transmission"
        "openPeerPorts"
      ]
    )
  ];

  options = {
    services.transmission = {
      enable = mkEnableOption "transmission" // {
        description = ''
          Whether to enable the headless Transmission BitTorrent daemon.

          Transmission daemon can be controlled via the RPC interface using
          transmission-remote, the WebUI (http://127.0.0.1:9091/ by default),
          or other clients like stig or tremc.

          Torrents are downloaded to [](#opt-services.transmission.home)/${downloadsDir} by default and are
          accessible to users in the "transmission" group.
        '';
      };

      package =
        mkPackageOption pkgs "transmission" {
          default = "transmission_4";
          example = "pkgs.transmission_4";
        }
        // {
          defaultText = ''
            if lib.versionAtLeast config.system.stateVersion "25.11" then
              pkgs.transmission_4
            else
              «error message»
          '';
        };

      credentialsFile = mkOption {
        default = "/dev/null";

        description = ''
          Path to a JSON file to be merged with the settings.
          Useful to merge a file which is better kept out of the Nix store
          to set secret config parameters like `rpc-password`.
        '';

        example = "/var/lib/secrets/transmission/settings.json";
        type = types.path;
      };

      downloadDirPermissions = mkOption {
        default = null;

        description = ''
          If not `null`, is used as the permissions set by
          `transmission-setup.service` on the directories
          [](#opt-services.transmission.settings.download-dir),
          [](#opt-services.transmission.settings.incomplete-dir)
          and [](#opt-services.transmission.settings.watch-dir).
          Note that you may also want to change
          [](#opt-services.transmission.settings.umask).

          Keep in mind, that if the default user is used, the `home` directory
          is locked behind a `750` permission, which affects all subdirectories
          as well. There are 3 ways to get around this:

          1. (Recommended) add the users that should have access to the group
             set by [](#opt-services.transmission.group)
          2. Change [](#opt-services.transmission.settings.download-dir) to be
             under a directory that has the right permissions
          3. Change `systemd.services.transmission.serviceConfig.StateDirectoryMode`
             to the same value as this option
        '';

        example = "770";
        type = with types; nullOr str;
      };

      extraFlags = mkOption {
        default = [ ];

        description = ''
          Extra flags passed to the transmission command in the service definition.
        '';

        example = [ "--log-debug" ];
        type = types.listOf types.str;
      };

      group = mkOption {
        default = "transmission";
        description = "Group account under which Transmission runs.";
        type = types.str;
      };

      home = mkOption {
        default = "/var/lib/transmission";

        description = ''
          The directory where Transmission will create `${settingsDir}`.
          as well as `${downloadsDir}/` unless
          [](#opt-services.transmission.settings.download-dir) is changed,
          and `${incompleteDir}/` unless
          [](#opt-services.transmission.settings.incomplete-dir) is changed.
        '';

        type = types.path;
      };

      openPeerPorts = mkEnableOption "opening of the peer port(s) in the firewall";
      openRPCPort = mkEnableOption "opening of the RPC port in the firewall";

      performanceNetParameters = mkEnableOption "performance tweaks" // {
        description = ''
          Whether to enable tweaking of kernel parameters
          to open many more connections at the same time.

          Note that you may also want to increase
          `peer-limit-global`.
          And be aware that these settings are quite aggressive
          and might not suite your regular desktop use.
          For instance, SSH sessions may time out more easily.
        '';
      };

      settings = mkOption {
        default = { };

        description = ''
          Settings whose options overwrite fields in
          `.config/transmission-daemon/settings.json`
          (each time the service starts).

          See [Transmission's documentation](https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md#options)
          for documentation of settings not explicitly covered by this module.
        '';

        type = types.submodule {
          options = {
            download-dir = mkOption {
              default = "${cfg.home}/${downloadsDir}";
              defaultText = literalExpression ''"''${config.${opt.home}}/${downloadsDir}"'';
              description = "Directory where to download torrents.";
              type = types.path;
            };

            incomplete-dir = mkOption {
              default = "${cfg.home}/${incompleteDir}";
              defaultText = literalExpression ''"''${config.${opt.home}}/${incompleteDir}"'';

              description = ''
                When enabled with
                services.transmission.home
                [](#opt-services.transmission.settings.incomplete-dir-enabled),
                new torrents will download the files to this directory.
                When complete, the files will be moved to download-dir
                [](#opt-services.transmission.settings.download-dir).
              '';

              type = types.path;
            };

            incomplete-dir-enabled = mkOption {
              default = true;
              description = "";
              type = types.bool;
            };

            message-level = mkOption {
              default = 2;
              description = "Set verbosity of transmission messages.";
              type = types.ints.between 0 6;
            };

            peer-port = mkOption {
              default = 51413;
              description = "The peer port to listen for incoming connections.";
              type = types.port;
            };

            peer-port-random-high = mkOption {
              default = 65535;

              description = ''
                The maximum peer port to listen to for incoming connections
                when [](#opt-services.transmission.settings.peer-port-random-on-start) is enabled.
              '';

              type = types.port;
            };

            peer-port-random-low = mkOption {
              default = 65535;

              description = ''
                The minimal peer port to listen to for incoming connections
                when [](#opt-services.transmission.settings.peer-port-random-on-start) is enabled.
              '';

              type = types.port;
            };

            peer-port-random-on-start = mkOption {
              default = false;
              description = "Randomize the peer port.";
              type = types.bool;
            };

            rpc-bind-address = mkOption {
              default = "127.0.0.1";

              description = ''
                Where to listen for RPC connections.
                Use `0.0.0.0` to listen on all interfaces.
              '';

              example = "0.0.0.0";
              type = types.str;
            };

            rpc-port = mkOption {
              default = 9091;
              description = "The RPC port to listen to.";
              type = types.port;
            };

            script-torrent-done-enabled = mkOption {
              default = false;

              description = ''
                Whether to run
                [](#opt-services.transmission.settings.script-torrent-done-filename)
                at torrent completion.
              '';

              type = types.bool;
            };

            script-torrent-done-filename = mkOption {
              default = null;
              description = "Executable to be run at torrent completion.";
              type = types.nullOr types.path;
            };

            trash-original-torrent-files = mkOption {
              default = false;

              description = ''
                Whether to delete torrents added from the
                                [](#opt-services.transmission.settings.watch-dir).
              '';

              type = types.bool;
            };

            umask = mkOption {
              default = "022";

              description = ''
                Sets transmission's file mode creation mask.
                See the {manpage}`umask(2)` manpage for more information.
                Users who want their saved torrents to be world-writable
                may want to set this value to 0/`"000"`.
              '';

              type = types.either types.int types.str;
            };

            utp-enabled = mkOption {
              default = true;

              description = ''
                Whether to enable [Micro Transport Protocol (µTP)](https://en.wikipedia.org/wiki/Micro_Transport_Protocol).
              '';

              type = types.bool;
            };

            watch-dir = mkOption {
              default = "${cfg.home}/${watchDir}";
              defaultText = literalExpression ''"''${config.${opt.home}}/${watchDir}"'';
              description = "Watch a directory for torrent files and add them to transmission.";
              type = types.path;
            };

            watch-dir-enabled = mkOption {
              default = false;

              description = ''
                Whether to enable the
                                [](#opt-services.transmission.settings.watch-dir).
              '';

              type = types.bool;
            };
          };

          freeformType = settingsFormat.type;
        };
      };

      user = mkOption {
        default = "transmission";
        description = "User account under which Transmission runs.";
        type = types.str;
      };

      webHome = mkOption {
        default = null;

        description = ''
          If not `null`, sets the value of the `TRANSMISSION_WEB_HOME`
          environment variable used by the service. Useful for overriding
          the web interface files, without overriding the transmission
          package and thus requiring rebuilding it locally. Use this if
          you want to use an alternative web interface, such as
          `pkgs.flood-for-transmission`.
        '';

        example = "pkgs.flood-for-transmission";
        type = types.nullOr types.path;
      };
    };
  };

  config = mkIf cfg.enable {
    boot.kernel.sysctl = mkMerge [
      # Transmission uses a single UDP socket in order to implement multiple uTP sockets,
      # and thus expects large kernel buffers for the UDP socket,
      # https://trac.transmissionbt.com/browser/trunk/libtransmission/tr-udp.c?rev=11956.
      # at least up to the values hardcoded here:
      (mkIf cfg.settings.utp-enabled {
        "net.core.rmem_max" = mkDefault 4194304; # 4MB
        "net.core.wmem_max" = mkDefault 1048576; # 1MB
      })
      (mkIf cfg.performanceNetParameters {
        # Increase the number of available source (local) TCP and UDP ports to 49151.
        # Usual default is 32768 60999, ie. 28231 ports.
        # Find out your current usage with: ss -s
        "net.ipv4.ip_local_port_range" = mkDefault "16384 65535";
        # Timeout faster generic TCP states.
        # Usual default is 600.
        # Find out your current usage with: watch -n 1 netstat -nptuo
        "net.netfilter.nf_conntrack_generic_timeout" = mkDefault 60;
        # Increase the number of trackable connections.
        # Usual default is 262144.
        # Find out your current usage with: conntrack -C
        "net.netfilter.nf_conntrack_max" = mkDefault 1048576;
        # Timeout faster established but inactive connections.
        # Usual default is 432000.
        "net.netfilter.nf_conntrack_tcp_timeout_established" = mkDefault 600;
        # Clear immediately TCP states after timeout.
        # Usual default is 120.
        "net.netfilter.nf_conntrack_tcp_timeout_time_wait" = mkDefault 1;
      })
    ];

    # It's useful to have transmission in path, e.g. for remote control
    environment.systemPackages = [ cfg.package ];

    networking.firewall = mkMerge [
      (mkIf cfg.openPeerPorts (
        if cfg.settings.peer-port-random-on-start then
          {
            allowedTCPPortRanges = [
              {
                from = cfg.settings.peer-port-random-low;
                to = cfg.settings.peer-port-random-high;
              }
            ];

            allowedUDPPortRanges = [
              {
                from = cfg.settings.peer-port-random-low;
                to = cfg.settings.peer-port-random-high;
              }
            ];
          }
        else
          {
            allowedTCPPorts = [ cfg.settings.peer-port ];
            allowedUDPPorts = [ cfg.settings.peer-port ];
          }
      ))
      (mkIf cfg.openRPCPort { allowedTCPPorts = [ cfg.settings.rpc-port ]; })
    ];

    security.apparmor.includes."local/bin.transmission-daemon" = ''
      ${config.systemd.services.transmission.environment.CURL_CA_BUNDLE} r,

      owner ${cfg.home}/${settingsDir}/** rw,
      ${cfg.settings.download-dir}/** rw,
      ${optionalString cfg.settings.incomplete-dir-enabled ''
        ${cfg.settings.incomplete-dir}/** rw,
      ''}
      ${optionalString cfg.settings.watch-dir-enabled ''
        ${cfg.settings.watch-dir}/** r${optionalString cfg.settings.trash-original-torrent-files "w"},
      ''}
      profile dirs {
        ${cfg.settings.download-dir}/** rw,
        ${optionalString cfg.settings.incomplete-dir-enabled ''
          ${cfg.settings.incomplete-dir}/** rw,
        ''}
        ${optionalString cfg.settings.watch-dir-enabled ''
          ${cfg.settings.watch-dir}/** r${optionalString cfg.settings.trash-original-torrent-files "w"},
        ''}
      }

      ${optionalString
        (cfg.settings.script-torrent-done-enabled && cfg.settings.script-torrent-done-filename != null)
        ''
          # Stack transmission_directories profile on top of
          # any existing profile for script-torrent-done-filename
          # FIXME: to be tested as I'm not sure it works well with NoNewPrivileges=
          # https://gitlab.com/apparmor/apparmor/-/wikis/AppArmorStacking#seccomp-and-no_new_privs
          ${cfg.settings.script-torrent-done-filename} px -> &@{dirs},
        ''
      }

      ${optionalString (cfg.webHome != null) ''
        ${cfg.webHome}/** r,
      ''}
    '';

    security.apparmor.policies."bin.transmission-daemon".profile = ''
      include "${cfg.package.apparmor}/bin.transmission-daemon"
    '';

    services.transmission.package = mkIf (versionOlder config.system.stateVersion "25.11") (
      mkOptionDefault (throw ''
        `services.transmission.package` previously defaulted to
        `pkgs.transmission_3`, which has been removed in favour
        of `pkgs.transmission_4`.

        Please set `services.transmission.package` to
        `pkgs.transmission_4` explicitly. Note that upgrade
        caused data loss for some users so backup is recommended
        (see NixOS 24.11 release notes for details)
      '')
    );

    systemd.services.transmission = {
      after = [ "network.target" ] ++ optional apparmor.enable "apparmor.service";
      description = "Transmission BitTorrent Service";

      environment = {
        CURL_CA_BUNDLE = config.security.pki.caBundle;
        TRANSMISSION_WEB_HOME = lib.mkIf (cfg.webHome != null) cfg.webHome;
      };

      requires = optional apparmor.enable "apparmor.service";

      serviceConfig = {
        # The following options are only for optimizing:
        # systemd-analyze security transmission
        AmbientCapabilities = "";

        BindPaths = [
          "${cfg.home}/${settingsDir}"
          cfg.settings.download-dir
          # Transmission may need to read in the host's /run (eg. /run/systemd/resolve)
          # or write in its private /run (eg. /run/host).
          "/run"
        ]
        ++ optional cfg.settings.incomplete-dir-enabled cfg.settings.incomplete-dir
        ++ optional (
          cfg.settings.watch-dir-enabled && cfg.settings.trash-original-torrent-files
        ) cfg.settings.watch-dir;

        BindReadOnlyPaths = [
          # No confinement done of /nix/store here like in systemd-confinement.nix,
          # an AppArmor profile is provided to get a confinement based upon paths and rights.
          builtins.storeDir
          "/etc"
        ]
        ++ optional (
          cfg.settings.script-torrent-done-enabled && cfg.settings.script-torrent-done-filename != null
        ) cfg.settings.script-torrent-done-filename
        ++ optional (
          cfg.settings.watch-dir-enabled && !cfg.settings.trash-original-torrent-files
        ) cfg.settings.watch-dir;

        CapabilityBoundingSet = "";
        # ProtectClock= adds DeviceAllow=char-rtc r
        DeviceAllow = "";
        ExecStart = "${cfg.package}/bin/transmission-daemon -f -g ${cfg.home}/${settingsDir} ${escapeShellArgs cfg.extraFlags}";

        # Use "+" because credentialsFile may not be accessible to User= or Group=.
        ExecStartPre = [
          (
            "+"
            + pkgs.writeShellScript "transmission-prestart" ''
              set -eu${lib.optionalString (cfg.settings.message-level >= 3) "x"}
              ${pkgs.jq}/bin/jq --slurp add ${settingsFile} '${cfg.credentialsFile}' |
              install -D -m 600 -o '${cfg.user}' -g '${cfg.group}' /dev/stdin \
              '${cfg.home}/${settingsDir}/settings.json'
            ''
          )
        ];

        Group = cfg.group;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        MountAPIVFS = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = mkDefault true;
        PrivateNetwork = mkDefault false;
        PrivateTmp = true;
        PrivateUsers = mkDefault true;
        ProtectClock = true;
        ProtectControlGroups = true;
        # ProtectHome=true would not allow BindPaths= to work across /home,
        # and ProtectHome=tmpfs would break statfs(),
        # preventing transmission-daemon to report the available free space.
        # However, RootDirectory= is used, so this is not a security concern
        # since there would be nothing in /home but any BindPaths= wanted by the user.
        ProtectHome = "read-only";
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RemoveIPC = true;

        # AF_UNIX may become usable one day:
        # https://github.com/transmission/transmission/issues/441
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        # Using RootDirectory= makes it possible
        # to use the same paths download-dir/incomplete-dir
        # (which appear in user's interfaces) without requiring cfg.user
        # to have access to their parent directories,
        # by using BindPaths=/BindReadOnlyPaths=.
        # Note that TemporaryFileSystem= could have been used instead
        # but not without adding some BindPaths=/BindReadOnlyPaths=
        # that would only be needed for ExecStartPre=,
        # because RootDirectoryStartOnly=true would not help.
        RootDirectory = rootDir;
        RootDirectoryStartOnly = true;
        # Create rootDir in the host's mount namespace.
        RuntimeDirectory = [ (baseNameOf rootDir) ];
        RuntimeDirectoryMode = "755";

        StateDirectory = [
          "transmission"
          "transmission/${settingsDir}"
          "transmission/${incompleteDir}"
          "transmission/${downloadsDir}"
          "transmission/${watchDir}"
        ];

        StateDirectoryMode = mkDefault 750;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          # Groups in @system-service which do not contain a syscall
          # listed by perf stat -e 'syscalls:sys_enter_*' transmission-daemon -f
          # in tests, and seem likely not necessary for transmission-daemon.
          "~@aio"
          "~@chown"
          "~@keyring"
          "~@memlock"
          "~@resources"
          "~@setuid"
          "~@timer"
          # In the @privileged group, but reached when querying infos through RPC (eg. with stig).
          "quotactl"
        ];

        # This is for BindPaths= and BindReadOnlyPaths=
        # to allow traversal of directories they create in RootDirectory=.
        UMask = "0066";
        User = cfg.user;
      }
      // (
        if lib.versionAtLeast cfg.package.version "4.1.1" then
          {
            Type = "notify-reload";
          }
        else
          {
            ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
            Type = "notify";
          }
      );

      wantedBy = [ "multi-user.target" ];
    };

    # Note that using systemd.tmpfiles would not work here
    # because it would fail when creating a directory
    # with a different owner than its parent directory, by saying:
    # Detected unsafe path transition /home/foo → /home/foo/Downloads during canonicalization of /home/foo/Downloads
    # when /home/foo is not owned by cfg.user.
    # Note also that using an ExecStartPre= wouldn't work either
    # because BindPaths= needs these directories before.
    systemd.services.transmission-setup = {
      before = [ "transmission.service" ];
      partOf = [ "transmission.service" ];

      script = ''
        install -d -m 700 -o '${cfg.user}' -g '${cfg.group}' '${cfg.home}/${settingsDir}'
      ''
      + optionalString (cfg.downloadDirPermissions != null) ''
        install -d -m '${cfg.downloadDirPermissions}' -o '${cfg.user}' -g '${cfg.group}' '${cfg.settings.download-dir}'

        ${optionalString cfg.settings.incomplete-dir-enabled ''
          install -d -m '${cfg.downloadDirPermissions}' -o '${cfg.user}' -g '${cfg.group}' '${cfg.settings.incomplete-dir}'
        ''}
        ${optionalString cfg.settings.watch-dir-enabled ''
          install -d -m '${cfg.downloadDirPermissions}' -o '${cfg.user}' -g '${cfg.group}' '${cfg.settings.watch-dir}'
        ''}
      '';

      serviceConfig = {
        RemainAfterExit = true;
        Type = "oneshot";
      };
    };

    users.groups = optionalAttrs (cfg.group == "transmission") {
      transmission = {
        gid = config.ids.gids.transmission;
      };
    };

    users.users = optionalAttrs (cfg.user == "transmission") {
      transmission = {
        description = "Transmission BitTorrent user";
        group = cfg.group;
        home = cfg.home;
        uid = config.ids.uids.transmission;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ julm ];
}
