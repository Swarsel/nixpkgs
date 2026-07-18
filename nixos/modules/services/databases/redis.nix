{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.redis;

  mkValueString =
    value:
    if value == true then
      "yes"
    else if value == false then
      "no"
    else
      lib.generators.mkValueStringDefault { } value;

  redisConfig =
    settings:
    pkgs.writeText "redis.conf" (
      lib.generators.toKeyValue {
        listsAsDuplicateKeys = true;
        mkKeyValue = lib.generators.mkKeyValueDefault { inherit mkValueString; } " ";
      } settings
    );

  redisName = name: "redis" + lib.optionalString (name != "") ("-" + name);
  enabledServers = lib.filterAttrs (name: conf: conf.enable) config.services.redis.servers;

in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "services"
      "redis"
      "user"
    ] "The redis module now is hardcoded to the redis user.")
    (lib.mkRemovedOptionModule [
      "services"
      "redis"
      "dbpath"
    ] "The redis module now uses /var/lib/redis as data directory.")
    (lib.mkRemovedOptionModule [
      "services"
      "redis"
      "dbFilename"
    ] "The redis module now uses /var/lib/redis/dump.rdb as database dump location.")
    (lib.mkRemovedOptionModule [
      "services"
      "redis"
      "appendOnlyFilename"
    ] "This option was never used.")
    (lib.mkRemovedOptionModule [ "services" "redis" "pidFile" ] "This option was removed.")
    (lib.mkRemovedOptionModule [
      "services"
      "redis"
      "extraConfig"
    ] "Use services.redis.servers.*.settings instead.")
    (lib.mkRenamedOptionModule
      [ "services" "redis" "enable" ]
      [ "services" "redis" "servers" "" "enable" ]
    )
    (lib.mkRenamedOptionModule [ "services" "redis" "port" ] [ "services" "redis" "servers" "" "port" ])
    (lib.mkRenamedOptionModule
      [ "services" "redis" "openFirewall" ]
      [ "services" "redis" "servers" "" "openFirewall" ]
    )
    (lib.mkRenamedOptionModule [ "services" "redis" "bind" ] [ "services" "redis" "servers" "" "bind" ])
    (lib.mkRenamedOptionModule
      [ "services" "redis" "unixSocket" ]
      [ "services" "redis" "servers" "" "unixSocket" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "redis" "unixSocketPerm" ]
      [ "services" "redis" "servers" "" "unixSocketPerm" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "redis" "logLevel" ]
      [ "services" "redis" "servers" "" "logLevel" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "redis" "logfile" ]
      [ "services" "redis" "servers" "" "logfile" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "redis" "syslog" ]
      [ "services" "redis" "servers" "" "syslog" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "redis" "databases" ]
      [ "services" "redis" "servers" "" "databases" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "redis" "maxclients" ]
      [ "services" "redis" "servers" "" "maxclients" ]
    )
    (lib.mkRenamedOptionModule [ "services" "redis" "save" ] [ "services" "redis" "servers" "" "save" ])
    (lib.mkRenamedOptionModule
      [ "services" "redis" "slaveOf" ]
      [ "services" "redis" "servers" "" "slaveOf" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "redis" "masterAuth" ]
      [ "services" "redis" "servers" "" "masterAuth" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "redis" "requirePass" ]
      [ "services" "redis" "servers" "" "requirePass" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "redis" "requirePassFile" ]
      [ "services" "redis" "servers" "" "requirePassFile" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "redis" "appendOnly" ]
      [ "services" "redis" "servers" "" "appendOnly" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "redis" "appendFsync" ]
      [ "services" "redis" "servers" "" "appendFsync" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "redis" "slowLogLogSlowerThan" ]
      [ "services" "redis" "servers" "" "slowLogLogSlowerThan" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "redis" "slowLogMaxLen" ]
      [ "services" "redis" "servers" "" "slowLogMaxLen" ]
    )
    (lib.mkRenamedOptionModule
      [ "services" "redis" "settings" ]
      [ "services" "redis" "servers" "" "settings" ]
    )
  ];

  ###### interface
  options = {

    services.redis = {
      package = lib.mkPackageOption pkgs "redis" { };

      servers = lib.mkOption {
        default = { };
        description = "Configuration of multiple `redis-server` instances.";

        type =
          with lib.types;
          attrsOf (
            submodule (
              { config, name, ... }:
              {
                options = {
                  enable = lib.mkEnableOption "Redis server";

                  appendFsync = lib.mkOption {
                    default = "everysec"; # no, always, everysec
                    description = "How often to fsync the append-only log, options: no, always, everysec.";
                    type = types.str;
                  };

                  appendOnly = lib.mkOption {
                    default = false;
                    description = "By default data is only periodically persisted to disk, enable this option to use an append-only file for improved persistence.";
                    type = types.bool;
                  };

                  bind = lib.mkOption {
                    default = "127.0.0.1";

                    description = ''
                      The IP interface to bind to.
                      `null` means "all interfaces".
                    '';

                    example = "192.0.2.1";
                    type = with types; nullOr str;
                  };

                  databases = lib.mkOption {
                    default = 16;
                    description = "Set the number of databases.";
                    type = types.int;
                  };

                  extraParams = lib.mkOption {
                    default = [ ];
                    description = "Extra parameters to append to redis-server invocation";
                    example = [ "--sentinel" ];
                    type = with types; listOf str;
                  };

                  group = lib.mkOption {
                    default = config.user;
                    defaultText = lib.literalExpression "config.user";

                    description = ''
                      Group account under which this instance of redis-server runs.

                      ::: {.note}
                      If left as the default value this group will automatically be
                      created on system activation, otherwise you are responsible for
                      ensuring the group exists before the redis service starts.
                    '';

                    type = types.str;
                  };

                  logLevel = lib.mkOption {
                    default = "notice"; # debug, verbose, notice, warning
                    description = "Specify the server verbosity level, options: debug, verbose, notice, warning.";
                    example = "debug";
                    type = types.str;
                  };

                  logfile = lib.mkOption {
                    default = "/dev/null";
                    description = "Specify the log file name. Also 'stdout' can be used to force Redis to log on the standard output.";
                    example = "/var/log/redis.log";
                    type = types.str;
                  };

                  masterAuth = lib.mkOption {
                    default = null;

                    description = ''
                      If the master is password protected (using the requirePass configuration)
                      it is possible to tell the slave to authenticate before starting the replication synchronization
                      process, otherwise the master will refuse the slave request.
                      (STORED PLAIN TEXT, WORLD-READABLE IN NIX STORE)
                    '';

                    type = with types; nullOr str;
                  };

                  masterAuthFile = lib.mkOption {
                    default = null;
                    description = "File with password for the master user.";
                    example = "/run/keys/redis-master-password";
                    type = with types; nullOr path;
                  };

                  masterUser = lib.mkOption {
                    default = null;

                    description = ''
                      If the master is password protected via ACLs this option can be used to specify
                      the Redis user that is used by replicas.'';

                    type = with types; nullOr str;
                  };

                  maxclients = lib.mkOption {
                    default = 10000;
                    description = "Set the max number of connected clients at the same time.";
                    type = types.int;
                  };

                  openFirewall = lib.mkOption {
                    default = false;

                    description = ''
                      Whether to open ports in the firewall for the server.
                    '';

                    type = types.bool;
                  };

                  port = lib.mkOption {
                    default = if name == "" then 6379 else 0;
                    defaultText = lib.literalExpression ''if name == "" then 6379 else 0'';

                    description = ''
                      The TCP port to accept connections.
                      If port 0 is specified Redis will not listen on a TCP socket.
                    '';

                    type = types.port;
                  };

                  requirePass = lib.mkOption {
                    default = null;

                    description = ''
                      Password for database (STORED PLAIN TEXT, WORLD-READABLE IN NIX STORE).
                      Use requirePassFile to store it outside of the nix store in a dedicated file.
                    '';

                    example = "letmein!";
                    type = with types; nullOr str;
                  };

                  requirePassFile = lib.mkOption {
                    default = null;
                    description = "File with password for the database.";
                    example = "/run/keys/redis-password";
                    type = with types; nullOr path;
                  };

                  save = lib.mkOption {
                    default = [
                      [
                        900
                        1
                      ]
                      [
                        300
                        10
                      ]
                      [
                        60
                        10000
                      ]
                    ];

                    description = ''
                      The schedule in which data is persisted to disk, represented as a list of lists where the first element represent the amount of seconds and the second the number of changes.

                      If set to the empty list (`[]`) then RDB persistence will be disabled (useful if you are using AOF or don't want any persistence).
                    '';

                    type = with types; listOf (listOf int);
                  };

                  sentinelAuthPassFile = lib.mkOption {
                    default = null;
                    description = "File with password for connecting to other Sentinel instances.";
                    example = "/run/keys/sentinel-password";
                    type = with types; nullOr path;
                  };

                  sentinelAuthUser = lib.mkOption {
                    default = null;
                    description = "The username to use to monitor a master from Sentinel.";
                    type = with types; nullOr str;
                  };

                  sentinelMasterHost = lib.mkOption {
                    default = null;
                    description = "The IP address (recommended) or hostname of the Redis master that Sentinel will monitor.";
                    type = with types; nullOr str;
                  };

                  sentinelMasterName = lib.mkOption {
                    default = null;
                    description = "The master name of the Redis master that Sentinel will monitor.";
                    type = with types; nullOr str;
                  };

                  sentinelMasterPort = lib.mkOption {
                    default = null;
                    description = "The TCP port of the Redis master that Sentinel will monitor.";
                    type = with types; nullOr int;
                  };

                  sentinelMasterQuorum = lib.mkOption {
                    default = null;
                    description = "The Sentinel quorum (minimum number of Sentinel nodes online for failover)";
                    type = with types; nullOr int;
                  };

                  settings = lib.mkOption {
                    default = { };

                    description = ''
                      Redis configuration. Refer to
                      <https://redis.io/topics/config>
                      for details on supported values.
                    '';

                    example = lib.literalExpression ''
                      {
                        loadmodule = [ "/path/to/my_module.so" "/path/to/other_module.so" ];
                      }
                    '';

                    # TODO: this should be converted to freeformType
                    type =
                      with types;
                      attrsOf (oneOf [
                        bool
                        int
                        str
                        (listOf str)
                      ]);
                  };

                  slaveOf = lib.mkOption {
                    default = null;
                    description = "IP and port to which this redis instance acts as a slave.";

                    example = {
                      ip = "192.168.1.100";
                      port = 6379;
                    };

                    type =
                      with types;
                      nullOr (
                        submodule (
                          { ... }:
                          {
                            options = {
                              ip = lib.mkOption {
                                description = "IP of the Redis master";
                                example = "192.168.1.100";
                                type = str;
                              };

                              port = lib.mkOption {
                                default = 6379;
                                description = "port of the Redis master";
                                type = port;
                              };
                            };
                          }
                        )
                      );
                  };

                  slowLogLogSlowerThan = lib.mkOption {
                    default = 10000;
                    description = "Log queries whose execution take longer than X in milliseconds.";
                    example = 1000;
                    type = types.int;
                  };

                  slowLogMaxLen = lib.mkOption {
                    default = 128;
                    description = "Maximum number of items to keep in slow log.";
                    type = types.int;
                  };

                  syslog = lib.mkOption {
                    default = true;
                    description = "Enable logging to the system logger.";
                    type = types.bool;
                  };

                  unixSocket = lib.mkOption {
                    default = "/run/${redisName name}/redis.sock";

                    defaultText = lib.literalExpression ''
                      if name == "" then "/run/redis/redis.sock" else "/run/redis-''${name}/redis.sock"
                    '';

                    description = "The path to the socket to bind to.";
                    type = with types; nullOr path;
                  };

                  unixSocketPerm = lib.mkOption {
                    default = 660;
                    description = "Change permissions for the socket";
                    example = 600;
                    type = types.int;
                  };

                  user = lib.mkOption {
                    default = redisName name;

                    defaultText = lib.literalExpression ''
                      if name == "" then "redis" else "redis-''${name}"
                    '';

                    description = ''
                      User account under which this instance of redis-server runs.

                      ::: {.note}
                      If left as the default value this user will automatically be
                      created on system activation, otherwise you are responsible for
                      ensuring the user exists before the redis service starts.
                    '';

                    type = types.str;
                  };
                };

                config.settings = lib.mkMerge [
                  {
                    inherit (config)
                      port
                      logfile
                      databases
                      maxclients
                      appendOnly
                      ;

                    appendfsync = config.appendFsync;
                    daemonize = false;
                    dbfilename = "dump.rdb";
                    dir = "/var/lib/${redisName name}";
                    loglevel = config.logLevel;

                    save =
                      if config.save == [ ] then
                        ''""'' # Disable saving with `save = ""`
                      else
                        map (d: "${toString (builtins.elemAt d 0)} ${toString (builtins.elemAt d 1)}") config.save;

                    slowlog-log-slower-than = config.slowLogLogSlowerThan;
                    slowlog-max-len = config.slowLogMaxLen;
                    supervised = "systemd";
                    syslog-enabled = config.syslog;
                  }
                  (lib.mkIf (config.bind != null) { inherit (config) bind; })
                  (lib.mkIf (config.unixSocket != null) {
                    unixsocket = config.unixSocket;
                    unixsocketperm = toString config.unixSocketPerm;
                  })
                  (lib.mkIf (config.slaveOf != null) {
                    slaveof = "${config.slaveOf.ip} ${toString config.slaveOf.port}";
                  })
                  (lib.mkIf (config.masterAuth != null) { masterauth = config.masterAuth; })
                  (lib.mkIf (config.requirePass != null) { requirepass = config.requirePass; })
                ];
              }
            )
          );
      };

      vmOverCommit =
        lib.mkEnableOption ''
          set `vm.overcommit_memory` sysctl to 1
          (Suggested for Background Saving: <https://redis.io/docs/get-started/faq/>)
        ''
        // {
          default = true;
        };
    };

  };

  ###### implementation
  config = lib.mkIf (enabledServers != { }) {

    assertions = lib.concatLists (
      lib.mapAttrsToList (name: conf: [
        {
          assertion = conf.requirePass != null -> conf.requirePassFile == null;

          message = ''
            You can only set one of services.redis.servers.${name}.requirePass
            or services.redis.servers.${name}.requirePassFile
          '';
        }
        {
          assertion = conf.masterAuth != null -> conf.masterAuthFile == null;

          message = ''
            You can only set one of services.redis.servers.${name}.masterAuth
            or services.redis.servers.${name}.masterAuthFile
          '';
        }
        {
          assertion = conf.masterUser != null -> (conf.masterAuth != null || conf.masterAuthFile != null);

          message = ''
            If using services.redis.servers.${name}.masterUser, either
            services.redis.servers.${name}.masterAuthFile or
            services.redis.servers.${name}.masterAuth must be provided
          '';
        }
        {
          assertion =
            conf.sentinelMasterName != null
            -> (
              conf.sentinelMasterHost != null
              && conf.sentinelMasterPort != null
              && conf.sentinelMasterQuorum != null
            );

          message = ''
            For Sentinel,
            services.redis.servers.${name}.sentinelMasterName,
            services.redis.servers.${name}.sentinelMasterHost,
            services.redis.servers.${name}.sentinelMasterPort,
            and services.redis.servers.${name}.sentinelMasterQuorum
            must all be provided
          '';
        }
        {
          assertion = conf.sentinelAuthPassFile != null -> conf.sentinelMasterName != null;

          message = ''
            For Sentinel authentication, services.redis.servers.${name}.sentinelMasterName,
            must be provided
          '';
        }
      ]) enabledServers
    );

    boot.kernel.sysctl = lib.mkIf cfg.vmOverCommit {
      "vm.overcommit_memory" = "1";
    };

    environment.systemPackages = [ cfg.package ];

    networking.firewall.allowedTCPPorts = lib.concatMap (
      conf: lib.optional conf.openFirewall conf.port
    ) (lib.attrValues enabledServers);

    systemd.services = lib.mapAttrs' (
      name: conf:
      lib.nameValuePair (redisName name) {
        after = [ "network.target" ];
        description = "Redis Server - ${redisName name}";

        serviceConfig = {
          # Capabilities
          CapabilityBoundingSet = "";

          ExecStart = "${cfg.package}/bin/${
            cfg.package.serverBin or "redis-server"
          } /var/lib/${redisName name}/redis.conf ${lib.escapeShellArgs conf.extraParams}";

          # NOTE: Redis/Valkey Sentinel persists dynamic cluster state by rewriting its
          # configuration file at runtime (redis.conf). This includes monitors,
          # authentication credentials, and failover metadata, and this behaviour
          # cannot be disabled.
          # As a result, a fully declarative configuration is not possible for
          # Sentinel-managed options. The preStart logic below appends sentinel
          # configuration only if it is not already present, in order to avoid
          # overwriting state that is owned and maintained by Sentinel itself.
          # This is an intentional deviation from strict declarative semantics and
          # is required for correct Sentinel operation.
          ExecStartPre =
            "+"
            + pkgs.writeShellScript "${redisName name}-prep-conf" (
              let
                redisConfVar = "/var/lib/${redisName name}/redis.conf";
                redisConfRun = "/run/${redisName name}/nixos.conf";
                redisConfStore = redisConfig conf.settings;
              in
              ''
                touch "${redisConfVar}" "${redisConfRun}"
                chown '${conf.user}':'${conf.group}' "${redisConfVar}" "${redisConfRun}"
                chmod 0600 "${redisConfVar}" "${redisConfRun}"
                if [ ! -s ${redisConfVar} ]; then
                  echo 'include "${redisConfRun}"' > "${redisConfVar}"
                fi
                echo 'include "${redisConfStore}"' > "${redisConfRun}"
                ${lib.optionalString (conf.requirePassFile != null) ''
                  echo "requirepass $(cat ${lib.escapeShellArg conf.requirePassFile})" >> "${redisConfRun}"
                ''}
                ${lib.optionalString (conf.masterUser != null) ''
                  echo "masteruser ${conf.masterUser}" >> "${redisConfRun}"
                ''}
                ${lib.optionalString (conf.masterAuthFile != null) ''
                  echo "masterauth $(cat ${lib.escapeShellArg conf.masterAuthFile})" >> "${redisConfRun}"
                ''}
                ${lib.optionalString (conf.sentinelMasterHost != null) ''
                  sentinel_monitor_line="sentinel monitor ${conf.sentinelMasterName} ${conf.sentinelMasterHost} ${toString conf.sentinelMasterPort} ${toString conf.sentinelMasterQuorum}"
                  if grep -qE "^sentinel monitor ${conf.sentinelMasterName}\b" "${redisConfVar}"; then
                    sed -i \
                      "s|^sentinel monitor ${conf.sentinelMasterName}\b.*|$sentinel_monitor_line|" "${redisConfVar}"
                  else
                    echo "$sentinel_monitor_line" >> "${redisConfVar}"
                  fi
                ''}
                ${lib.optionalString (conf.sentinelAuthUser != null) ''
                  sentinel_auth_user_line="sentinel auth-user ${conf.sentinelMasterName} ${conf.sentinelAuthUser}"
                  if grep -qE "^sentinel auth-user ${conf.sentinelMasterName}\b" "${redisConfVar}"; then
                    sed -i \
                      "s|^sentinel auth-user ${conf.sentinelMasterName}\b.*|$sentinel_auth_user_line|" "${redisConfVar}"
                  else
                    echo "$sentinel_auth_user_line" >> "${redisConfVar}"
                  fi
                ''}
                ${lib.optionalString (conf.sentinelAuthPassFile != null) ''
                  sentinel_auth_pass_line="sentinel auth-pass ${conf.sentinelMasterName} $(cat ${lib.escapeShellArg conf.sentinelAuthPassFile})"
                  if grep -qE "^sentinel auth-pass ${conf.sentinelMasterName}\b" "${redisConfVar}"; then
                    sed -i \
                      "s|^sentinel auth-pass ${conf.sentinelMasterName}\b.*|$sentinel_auth_pass_line|" "${redisConfVar}"
                  else
                    echo "$sentinel_auth_pass_line" >> "${redisConfVar}"
                  fi
                ''}
              ''
            );

          Group = conf.group;
          # Process Properties
          LimitNOFILE = lib.mkDefault "${toString (conf.maxclients + 32)}";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          # Security
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          # Sandboxing
          ProtectSystem = "strict";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          # Runtime directory and mode
          RuntimeDirectory = redisName name;
          RuntimeDirectoryMode = "0750";
          # State directory and mode
          StateDirectory = redisName name;
          StateDirectoryMode = "0700";
          # System Call Filtering
          SystemCallArchitectures = "native";
          SystemCallFilter = "~@cpu-emulation @debug @keyring @memlock @mount @obsolete @privileged @resources @setuid";
          Type = "notify";
          # Access write directories
          UMask = "0077";
          # User and group
          User = conf.user;
        };

        wantedBy = [ "multi-user.target" ];
      }
    ) enabledServers;

    users.groups = lib.mapAttrs' (
      name: conf:
      lib.nameValuePair (redisName name) {
      }
    ) (lib.filterAttrs (name: conf: conf.group == redisName name) enabledServers);

    users.users = lib.mapAttrs' (
      name: conf:
      lib.nameValuePair (redisName name) {
        description = "System user for the redis-server instance ${name}";
        group = conf.group;
        isSystemUser = true;
      }
    ) (lib.filterAttrs (name: conf: conf.user == redisName name) enabledServers);

  };

  meta.teams = [ lib.teams.redis ];
}
