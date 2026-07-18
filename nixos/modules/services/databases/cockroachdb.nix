{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.cockroachdb;
  crdb = cfg.package;

  startupCommand = utils.escapeSystemdExecArgs (
    [
      # Basic startup
      "${crdb}/bin/cockroach"
      "start"
      "--logtostderr"
      "--store=/var/lib/cockroachdb"

      # WebUI settings
      "--http-addr=${cfg.http.address}:${toString cfg.http.port}"

      # Cluster listen address
      "--listen-addr=${cfg.listen.address}:${toString cfg.listen.port}"

      # Cache and memory settings.
      "--cache=${cfg.cache}"
      "--max-sql-memory=${cfg.maxSqlMemory}"

      # Certificate/security settings.
      (if cfg.insecure then "--insecure" else "--certs-dir=${cfg.certsDir}")
    ]
    ++ lib.optional (cfg.join != null) "--join=${cfg.join}"
    ++ lib.optional (cfg.locality != null) "--locality=${cfg.locality}"
    ++ cfg.extraArgs
  );

  addressOption = descr: defaultPort: {
    address = lib.mkOption {
      default = "localhost";
      description = "Address to bind to for ${descr}";
      type = lib.types.str;
    };

    port = lib.mkOption {
      default = defaultPort;
      description = "Port to bind to for ${descr}";
      type = lib.types.port;
    };
  };
in

{
  options = {
    services.cockroachdb = {
      enable = lib.mkEnableOption "CockroachDB Server";

      package = lib.mkPackageOption pkgs "cockroachdb" {
        extraDescription = ''
          This would primarily be useful to enable Enterprise Edition features
          in your own custom CockroachDB build (Nixpkgs CockroachDB binaries
          only contain open source features and open source code).
        '';
      };

      cache = lib.mkOption {
        default = "25%";

        description = ''
          The total size for caches.

          This can be a percentage, expressed with a fraction sign or as a
          decimal-point number, or any bytes-based unit. For example,
          `"25%"`, `"0.25"` both represent
          25% of the available system memory. The values
          `"1000000000"` and `"1GB"` both
          represent 1 gigabyte of memory.

        '';

        type = lib.types.str;
      };

      certsDir = lib.mkOption {
        default = null;
        description = "The path to the certificate directory.";
        type = lib.types.nullOr lib.types.path;
      };

      extraArgs = lib.mkOption {
        default = [ ];

        description = ''
          Extra CLI arguments passed to {command}`cockroach start`.
          For the full list of supported arguments, check <https://www.cockroachlabs.com/docs/stable/cockroach-start.html#flags>
        '';

        example = [
          "--advertise-addr"
          "[fe80::f6f2:::]"
        ];

        type = lib.types.listOf lib.types.str;
      };

      group = lib.mkOption {
        default = "cockroachdb";
        description = "User account under which CockroachDB runs";
        type = lib.types.str;
      };

      http = addressOption "http-based Admin UI" 8080;

      insecure = lib.mkOption {
        default = false;
        description = "Run in insecure mode.";
        type = lib.types.bool;
      };

      join = lib.mkOption {
        default = null;
        description = "The addresses for connecting the node to a cluster.";
        type = lib.types.nullOr lib.types.str;
      };

      listen = addressOption "intra-cluster communication" 26257;

      locality = lib.mkOption {
        default = null;

        description = ''
          An ordered, comma-separated list of key-value pairs that describe the
          topography of the machine. Topography might include country,
          datacenter or rack designations. Data is automatically replicated to
          maximize diversities of each tier. The order of tiers is used to
          determine the priority of the diversity, so the more inclusive
          localities like country should come before less inclusive localities
          like datacenter.  The tiers and order must be the same on all nodes.
          Including more tiers is better than including fewer. For example:

          ```
              country=us,region=us-west,datacenter=us-west-1b,rack=12
              country=ca,region=ca-east,datacenter=ca-east-2,rack=4

              planet=earth,province=manitoba,colo=secondary,power=3
          ```
        '';

        type = lib.types.nullOr lib.types.str;
      };

      maxSqlMemory = lib.mkOption {
        default = "25%";

        description = ''
          The maximum in-memory storage capacity available to store temporary
          data for SQL queries.

          This can be a percentage, expressed with a fraction sign or as a
          decimal-point number, or any bytes-based unit. For example,
          `"25%"`, `"0.25"` both represent
          25% of the available system memory. The values
          `"1000000000"` and `"1GB"` both
          represent 1 gigabyte of memory.
        '';

        type = lib.types.str;
      };

      openPorts = lib.mkOption {
        default = false;
        description = "Open firewall ports for cluster communication by default";
        type = lib.types.bool;
      };

      user = lib.mkOption {
        default = "cockroachdb";
        description = "User account under which CockroachDB runs";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf config.services.cockroachdb.enable {
    assertions = [
      {
        assertion = !cfg.insecure -> cfg.certsDir != null;
        message = "CockroachDB must have a set of SSL certificates (.certsDir), or run in Insecure Mode (.insecure = true)";
      }
    ];

    environment.systemPackages = [ crdb ];

    networking.firewall.allowedTCPPorts = lib.optionals cfg.openPorts [
      cfg.http.port
      cfg.listen.port
    ];

    systemd.services.cockroachdb = {
      after = [
        "network.target"
        "time-sync.target"
      ];

      description = "CockroachDB Server";

      documentation = [
        "man:cockroach(1)"
        "https://www.cockroachlabs.com"
      ];

      requires = [ "time-sync.target" ];

      serviceConfig = {
        ExecStart = startupCommand;
        Restart = "always";
        RestartSec = 10;
        StateDirectory = "cockroachdb";
        StateDirectoryMode = "0700";
        # A conservative-ish timeout is alright here, because for Type=notify
        # cockroach will send systemd pings during startup to keep it alive
        TimeoutStopSec = 60;
        Type = "notify";
        User = cfg.user;
      };

      unitConfig.RequiresMountsFor = "/var/lib/cockroachdb";
      wantedBy = [ "multi-user.target" ];
    };

    users.groups = lib.optionalAttrs (cfg.group == "cockroachdb") {
      cockroachdb.gid = config.ids.gids.cockroachdb;
    };

    users.users = lib.optionalAttrs (cfg.user == "cockroachdb") {
      cockroachdb = {
        description = "CockroachDB Server User";
        group = cfg.group;
        uid = config.ids.uids.cockroachdb;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ thoughtpolice ];
}
