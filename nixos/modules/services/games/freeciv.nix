{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.freeciv;
  inherit (config.users) groups;
  rootDir = "/run/freeciv";
  argsFormat = {
    generate =
      name: value:
      let
        mkParam =
          k: v:
          if v == null then
            [ ]
          else if lib.isBool v then
            lib.optional v ("--" + k)
          else
            [
              ("--" + k)
              v
            ];
        mkParams = k: v: map (mkParam k) (if lib.isList v then v else [ v ]);
      in
      lib.escapeShellArgs (lib.concatLists (lib.concatLists (lib.mapAttrsToList mkParams value)));

    type =
      with lib.types;
      let
        valueType =
          nullOr (oneOf [
            bool
            int
            float
            str
            (listOf valueType)
          ])
          // {
            description = "freeciv-server params";
          };
      in
      valueType;
  };
in
{
  options = {
    services.freeciv = {
      enable = lib.mkEnableOption "freeciv";
      openFirewall = lib.mkEnableOption "opening the firewall for the port listening for clients";

      settings = lib.mkOption {
        default = { };

        description = ''
          Parameters of freeciv-server.
        '';

        type = lib.types.submodule {
          options.Announce = lib.mkOption {
            default = "none";
            description = "Announce game in LAN using given protocol.";

            type = lib.types.enum [
              "IPv4"
              "IPv6"
              "none"
            ];
          };

          options.Database = lib.mkOption {
            apply = pkgs.writeText "auth.conf";

            default = ''
              [fcdb]
                backend="sqlite"
                database="/var/lib/freeciv/auth.sqlite"
            '';

            description = "Enable database connection with given configuration.";
            type = lib.types.nullOr lib.types.str;
          };

          options.Guests = lib.mkEnableOption "guests to login if auth is enabled";
          options.Newusers = lib.mkEnableOption "new users to login if auth is enabled";
          options.auth = lib.mkEnableOption "server authentication";

          options.debug = lib.mkOption {
            default = 0;
            description = "Set debug log level.";
            type = lib.types.ints.between 0 3;
          };

          options.exit-on-end = lib.mkEnableOption "exit instead of restarting when a game ends";

          options.port = lib.mkOption {
            default = 5556;
            description = "Listen for clients on given port";
            type = lib.types.port;
          };

          options.quitidle = lib.mkOption {
            default = null;
            description = "Quit if no players for given time in seconds.";
            type = lib.types.nullOr lib.types.int;
          };

          options.read = lib.mkOption {
            apply = v: pkgs.writeTextDir "read.serv" v + "/read";

            default = ''
              /fcdb lua sqlite_createdb()
            '';

            description = "Startup script.";
            type = lib.types.lines;
          };

          options.saves = lib.mkOption {
            default = "/var/lib/freeciv/saves/";

            description = ''
              Save games to given directory,
              a sub-directory named after the starting date of the service
              will me inserted to preserve older saves.
            '';

            type = lib.types.nullOr lib.types.str;
          };

          freeformType = argsFormat.type;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.settings.port ]; };

    systemd.services.freeciv = {
      after = [ "network.target" ];
      description = "Freeciv Service";
      environment.HOME = "/var/lib/freeciv";

      serviceConfig = {
        # The following options are only for optimizing:
        # systemd-analyze security freeciv
        AmbientCapabilities = "";

        BindReadOnlyPaths = [
          builtins.storeDir
          "/etc"
          "/run"
        ];

        CapabilityBoundingSet = "";
        # ProtectClock= adds DeviceAllow=char-rtc r
        DeviceAllow = "";
        DynamicUser = true;

        ExecStart = pkgs.writeShellScript "freeciv-server" (
          ''
            set -eux
            savedir=$(date +%Y-%m-%d_%H-%M-%S)
          ''
          + "${pkgs.freeciv}/bin/freeciv-server"
          + " "
          + lib.optionalString (cfg.settings.saves != null) (
            lib.concatStringsSep " " [
              "--saves"
              "${lib.escapeShellArg cfg.settings.saves}/$savedir"
            ]
          )
          + " "
          + argsFormat.generate "freeciv-server" (cfg.settings // { saves = null; })
        );

        # Avoid mounting rootDir in the own rootDir of ExecStart='s mount namespace.
        InaccessiblePaths = [ "-+${rootDir}" ];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        MountAPIVFS = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateNetwork = lib.mkDefault false;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "on-failure";
        RestartSec = "5s";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RootDirectory = rootDir;
        RootDirectoryStartOnly = true;
        # Create rootDir in the host's mount namespace.
        RuntimeDirectory = [ (baseNameOf rootDir) ];
        RuntimeDirectoryMode = "755";
        StandardError = "journal";
        StandardInput = "fd:freeciv.socket";
        StandardOutput = "journal";
        StateDirectory = [ "freeciv" ];
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";

        SystemCallFilter = [
          "@system-service"
          # Groups in @system-service which do not contain a syscall listed by:
          # perf stat -x, 2>perf.log -e 'syscalls:sys_enter_*' freeciv-server
          # in tests, and seem likely not necessary for freeciv-server.
          "~@aio"
          "~@chown"
          "~@ipc"
          "~@keyring"
          "~@memlock"
          "~@resources"
          "~@setuid"
          "~@sync"
          "~@timer"
        ];

        # This is for BindPaths= and BindReadOnlyPaths=
        # to allow traversal of directories they create in RootDirectory=.
        UMask = "0066";
        WorkingDirectory = "/var/lib/freeciv";
      };

      wantedBy = [ "multi-user.target" ];
    };

    # Use with:
    #   journalctl -u freeciv.service -f -o cat &
    #   cat >/run/freeciv.stdin
    #   load saves/2020-11-14_05-22-27/freeciv-T0005-Y-3750-interrupted.sav.bz2
    systemd.sockets.freeciv = {
      socketConfig = {
        ListenFIFO = "/run/freeciv.stdin";
        RemoveOnStop = true;
        SocketGroup = groups.freeciv.name;
        SocketMode = "660";
      };

      wantedBy = [ "sockets.target" ];
    };

    users.groups.freeciv = { };
  };

  meta.maintainers = with lib.maintainers; [ julm ];
}
