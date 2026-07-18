{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.foundationdb;
  pkg = cfg.package;

  # used for initial cluster configuration
  initialIpAddr = if (cfg.publicAddress != "auto") then cfg.publicAddress else "127.0.0.1";

  fdbServers =
    n:
    lib.concatStringsSep "\n" (
      map (x: "[fdbserver.${toString (x + cfg.listenPortStart)}]") (lib.range 0 (n - 1))
    );

  backupAgents =
    n: lib.concatStringsSep "\n" (map (x: "[backup_agent.${toString x}]") (lib.range 1 n));

  configFile = pkgs.writeText "foundationdb.conf" ''
    [general]
    cluster_file  = /etc/foundationdb/fdb.cluster

    [fdbmonitor]
    restart_delay = ${toString cfg.restartDelay}
    user          = ${cfg.user}
    group         = ${cfg.group}

    [fdbserver]
    command        = ${pkg}/bin/fdbserver
    public_address = ${cfg.publicAddress}:$ID
    listen_address = ${cfg.listenAddress}
    datadir        = ${cfg.dataDir}/$ID
    logdir         = ${cfg.logDir}
    logsize        = ${cfg.logSize}
    maxlogssize    = ${cfg.maxLogSize}
    ${lib.optionalString (cfg.class != null) "class = ${cfg.class}"}
    memory         = ${cfg.memory}
    storage_memory = ${cfg.storageMemory}

    ${lib.optionalString (lib.versionAtLeast cfg.package.version "6.1") ''
      trace_format   = ${cfg.traceFormat}
    ''}

    ${lib.optionalString (cfg.tls != null) ''
      tls_plugin           = ${pkg}/libexec/plugins/FDBLibTLS.so
      tls_certificate_file = ${cfg.tls.certificate}
      tls_key_file         = ${cfg.tls.key}
      tls_verify_peers     = ${cfg.tls.allowedPeers}
    ''}

    ${lib.optionalString (
      cfg.locality.machineId != null
    ) "locality_machineid=${cfg.locality.machineId}"}
    ${lib.optionalString (cfg.locality.zoneId != null) "locality_zoneid=${cfg.locality.zoneId}"}
    ${lib.optionalString (
      cfg.locality.datacenterId != null
    ) "locality_dcid=${cfg.locality.datacenterId}"}
    ${lib.optionalString (cfg.locality.dataHall != null) "locality_data_hall=${cfg.locality.dataHall}"}

    ${fdbServers cfg.serverProcesses}

    [backup_agent]
    command = ${pkg}/libexec/backup_agent
    ${backupAgents cfg.backupProcesses}
  '';
in
{
  options.services.foundationdb = {

    enable = lib.mkEnableOption "FoundationDB Server";

    package = lib.mkOption {
      description = ''
        The FoundationDB package to use for this server. This must be specified by the user
        in order to ensure migrations and upgrades are controlled appropriately.
      '';

      type = lib.types.package;
    };

    backupProcesses = lib.mkOption {
      default = 1;
      description = "Number of backup_agent processes to run for snapshots.";
      type = lib.types.int;
    };

    class = lib.mkOption {
      default = null;
      description = "Process class";

      type = lib.types.nullOr (
        lib.types.enum [
          "storage"
          "transaction"
          "stateless"
        ]
      );
    };

    dataDir = lib.mkOption {
      default = "/var/lib/foundationdb";
      description = "Data directory. All cluster data will be put under here.";
      type = lib.types.path;
    };

    extraReadWritePaths = lib.mkOption {
      default = [ ];

      description = ''
        An extra set of filesystem paths that FoundationDB can read to
        and write from. By default, FoundationDB runs under a heavily
        namespaced systemd environment without write access to most of
        the filesystem outside of its data and log directories. By
        adding paths to this list, the set of writeable paths will be
        expanded. This is useful for allowing e.g. backups to local files,
        which must be performed on behalf of the foundationdb service.
      '';

      type = lib.types.listOf lib.types.path;
    };

    group = lib.mkOption {
      default = "foundationdb";
      description = "Group account under which FoundationDB runs.";
      type = lib.types.str;
    };

    listenAddress = lib.mkOption {
      default = "public";
      description = "Publicly visible IP address of the process. Port is determined by process ID";
      type = lib.types.str;
    };

    listenPortStart = lib.mkOption {
      default = 4500;

      description = ''
        Starting port number for database listening sockets. Every FDB process binds to a
        subsequent port, to this number reflects the start of the overall range. e.g. having
        8 server processes will use all ports between 4500 and 4507.
      '';

      type = lib.types.port;
    };

    locality = lib.mkOption {
      default = {
        dataHall = null;
        datacenterId = null;
        machineId = null;
        zoneId = null;
      };

      description = ''
        FoundationDB locality settings.
      '';

      type = lib.types.submodule {
        options = {
          dataHall = lib.mkOption {
            default = null;

            description = ''
              Data hall identifier key. All processes physically located in a
              data hall should share the id. If you are depending on data
              hall based replication this must be set on all processes.
            '';

            type = lib.types.nullOr lib.types.str;
          };

          datacenterId = lib.mkOption {
            default = null;

            description = ''
              Data center identifier key. All processes physically located in a
              data center should share the id. If you are depending on data
              center based replication this must be set on all processes.
            '';

            type = lib.types.nullOr lib.types.str;
          };

          machineId = lib.mkOption {
            default = null;

            description = ''
              Machine identifier key. All processes on a machine should share a
              unique id. By default, processes on a machine determine a unique id to share.
              This does not generally need to be set.
            '';

            type = lib.types.nullOr lib.types.str;
          };

          zoneId = lib.mkOption {
            default = null;

            description = ''
              Zone identifier key. Processes that share a zone id are
              considered non-unique for the purposes of data replication.
              If unset, defaults to machine id.
            '';

            type = lib.types.nullOr lib.types.str;
          };
        };
      };
    };

    logDir = lib.mkOption {
      default = "/var/log/foundationdb";
      description = "Log directory.";
      type = lib.types.path;
    };

    logSize = lib.mkOption {
      default = "10MiB";

      description = ''
        Roll over to a new log file after the current log file
        reaches the specified size.
      '';

      type = lib.types.str;
    };

    maxLogSize = lib.mkOption {
      default = "100MiB";

      description = ''
        Delete the oldest log file when the total size of all log
        files exceeds the specified size. If set to 0, old log files
        will not be deleted.
      '';

      type = lib.types.str;
    };

    memory = lib.mkOption {
      default = "8GiB";

      description = ''
        Maximum memory used by the process. The default value is
        `8GiB`. When specified without a unit,
        `MiB` is assumed. This parameter does not
        change the memory allocation of the program. Rather, it sets
        a hard limit beyond which the process will kill itself and
        be restarted. The default value of `8GiB`
        is double the intended memory usage in the default
        configuration (providing an emergency buffer to deal with
        memory leaks or similar problems). It is not recommended to
        decrease the value of this parameter below its default
        value. It may be increased if you wish to allocate a very
        large amount of storage engine memory or cache. In
        particular, when the `storageMemory`
        parameter is increased, the `memory`
        parameter should be increased by an equal amount.
      '';

      type = lib.types.str;
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Open the firewall ports corresponding to FoundationDB processes and coordinators
        using {option}`config.networking.firewall.*`.
      '';

      type = lib.types.bool;
    };

    pidfile = lib.mkOption {
      default = "/run/foundationdb.pid";
      description = "Path to pidfile for fdbmonitor.";
      type = lib.types.path;
    };

    publicAddress = lib.mkOption {
      default = "auto";
      description = "Publicly visible IP address of the process. Port is determined by process ID";
      type = lib.types.str;
    };

    restartDelay = lib.mkOption {
      default = 10;
      description = "Number of seconds to wait before restarting servers.";
      type = lib.types.int;
    };

    serverProcesses = lib.mkOption {
      default = 1;
      description = "Number of fdbserver processes to run.";
      type = lib.types.int;
    };

    storageMemory = lib.mkOption {
      default = "1GiB";

      description = ''
        Maximum memory used for data storage. The default value is
        `1GiB`. When specified without a unit,
        `MB` is assumed. Clusters using the memory
        storage engine will be restricted to using this amount of
        memory per process for purposes of data storage. Memory
        overhead associated with storing the data is counted against
        this total. If you increase the
        `storageMemory`, you should also increase
        the `memory` parameter by the same amount.
      '';

      type = lib.types.str;
    };

    tls = lib.mkOption {
      default = null;

      description = ''
        FoundationDB Transport Security Layer (TLS) settings.
      '';

      type = lib.types.nullOr (
        lib.types.submodule {
          options = {
            allowedPeers = lib.mkOption {
              default = "Check.Valid=1,Check.Unexpired=1";

              description = ''
                "Peer verification string". This may be used to adjust which TLS
                client certificates a server will accept, as a form of user
                authorization; for example, it may only accept TLS clients who
                offer a certificate abiding by some locality or organization name.

                For more information, please see the FoundationDB documentation.
              '';

              type = lib.types.str;
            };

            certificate = lib.mkOption {
              description = ''
                Path to the TLS certificate file. This certificate will
                be offered to, and may be verified by, clients.
              '';

              type = lib.types.str;
            };

            key = lib.mkOption {
              description = "Private key file for the certificate.";
              type = lib.types.str;
            };
          };
        }
      );
    };

    traceFormat = lib.mkOption {
      default = "xml";
      description = "Trace logging format.";

      type = lib.types.enum [
        "xml"
        "json"
      ];
    };

    user = lib.mkOption {
      default = "foundationdb";
      description = "User account under which FoundationDB runs.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.versionOlder cfg.package.version "6.1" -> cfg.traceFormat == "xml";

        message = ''
          Versions of FoundationDB before 6.1 do not support configurable trace formats (only XML is supported).
          This option has no effect for version ''
        + cfg.package.version
        + ''
          , and enabling it is an error.
        '';
      }
    ];

    environment.systemPackages = [ pkg ];

    networking.firewall.allowedTCPPortRanges = lib.mkIf cfg.openFirewall [
      {
        from = cfg.listenPortStart;
        to = (cfg.listenPortStart + cfg.serverProcesses) - 1;
      }
    ];

    systemd.services.foundationdb = {
      after = [ "network.target" ];
      description = "FoundationDB Service";

      path = [
        pkg
        pkgs.coreutils
      ];

      postStart = ''
        if [ -e "${cfg.dataDir}/.first_startup" ]; then
          fdbcli --exec "configure new single ssd"
          rm -f "${cfg.dataDir}/.first_startup";
        fi
      '';

      preStart = ''
        if [ ! -f /etc/foundationdb/fdb.cluster ]; then
            cf=/etc/foundationdb/fdb.cluster
            desc=$(tr -dc A-Za-z0-9 </dev/urandom 2>/dev/null | head -c8)
            rand=$(tr -dc A-Za-z0-9 </dev/urandom 2>/dev/null | head -c8)
            echo ''${desc}:''${rand}@${initialIpAddr}:${toString cfg.listenPortStart} > $cf
            chmod 0664 $cf
            touch "${cfg.dataDir}/.first_startup"
        fi
      '';

      script = "exec fdbmonitor --lockfile ${cfg.pidfile} --conffile ${configFile}";

      serviceConfig =
        let
          rwpaths = [
            cfg.dataDir
            cfg.logDir
            cfg.pidfile
            "/etc/foundationdb"
          ]
          ++ cfg.extraReadWritePaths;
        in
        {
          Group = cfg.group;
          # Security options
          NoNewPrivileges = true;
          PIDFile = "${cfg.pidfile}";
          PermissionsStartOnly = true; # setup needs root perms
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          ReadWritePaths = lib.concatStringsSep " " (map (x: "-" + x) rwpaths);
          Restart = "always";
          RestartSec = 5;
          TimeoutSec = 120; # give reasonable time to shut down
          Type = "simple";
          User = cfg.user;
        };

      unitConfig = {
        RequiresMountsFor = "${cfg.dataDir} ${cfg.logDir}";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d /etc/foundationdb 0755 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.dataDir}' 0770 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.logDir}' 0770 ${cfg.user} ${cfg.group} - -"
      "F '${cfg.pidfile}' - ${cfg.user} ${cfg.group} - -"
    ];

    users.groups = lib.optionalAttrs (cfg.group == "foundationdb") {
      foundationdb.gid = config.ids.gids.foundationdb;
    };

    users.users = lib.optionalAttrs (cfg.user == "foundationdb") {
      foundationdb = {
        description = "FoundationDB User";
        group = cfg.group;
        uid = config.ids.uids.foundationdb;
      };
    };
  };

  meta.doc = ./foundationdb.md;
  meta.maintainers = with lib.maintainers; [ thoughtpolice ];
}
