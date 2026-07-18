{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.patroni;
  defaultUser = "patroni";
  defaultGroup = "patroni";
  format = pkgs.formats.yaml { };

  configFileName = "patroni-${cfg.scope}-${cfg.name}.yaml";
  configFile = format.generate configFileName cfg.settings;
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "patroni" "raft" ] ''
      Raft has been deprecated by upstream.
    '')
    (lib.mkRemovedOptionModule [ "services" "patroni" "raftPort" ] ''
      Raft has been deprecated by upstream.
    '')
  ];

  options.services.patroni = {

    enable = lib.mkEnableOption "Patroni";

    dataDir = lib.mkOption {
      default = "/var/lib/patroni";

      description = ''
        Folder where Patroni data will be written, this is where the pgpass password file will be written.
      '';

      type = lib.types.path;
    };

    environmentFiles = lib.mkOption {
      default = { };
      description = "Environment variables made available to Patroni as files content, useful for providing secrets from files.";

      example = {
        PATRONI_REPLICATION_PASSWORD = "/secret/file";
        PATRONI_SUPERUSER_PASSWORD = "/secret/file";
      };

      type =
        with lib.types;
        attrsOf (
          nullOr (oneOf [
            str
            path
            package
          ])
        );
    };

    group = lib.mkOption {
      default = defaultGroup;

      description = ''
        The group for the service. If left as the default value this group will automatically be created,
        otherwise the sysadmin is responsible for ensuring the group exists.
      '';

      example = "postgres";
      type = lib.types.str;
    };

    name = lib.mkOption {
      description = ''
        The name of the host. Must be unique for the cluster.
      '';

      example = "node1";
      type = lib.types.str;
    };

    namespace = lib.mkOption {
      default = "/service";

      description = ''
        Path within the configuration store where Patroni will keep information about the cluster.
      '';

      type = lib.types.str;
    };

    nodeIp = lib.mkOption {
      description = ''
        IP address of this node.
      '';

      example = "192.168.1.1";
      type = lib.types.str;
    };

    otherNodesIps = lib.mkOption {
      description = ''
        IP addresses of the other nodes.
      '';

      example = [
        "192.168.1.2"
        "192.168.1.3"
      ];

      type = lib.types.listOf lib.types.str;
    };

    postgresqlDataDir = lib.mkOption {
      default = "/var/lib/postgresql/${cfg.postgresqlPackage.psqlSchema}";
      defaultText = lib.literalExpression ''"/var/lib/postgresql/''${config.services.patroni.postgresqlPackage.psqlSchema}"'';

      description = ''
        The data directory for PostgreSQL. If left as the default value
        this directory will automatically be created before the PostgreSQL server starts, otherwise
        the sysadmin is responsible for ensuring the directory exists with appropriate ownership
        and permissions.
      '';

      example = "/var/lib/postgresql/14";
      type = lib.types.path;
    };

    postgresqlPackage = lib.mkOption {
      description = ''
        PostgreSQL package to use.
        Plugins can be enabled like this `pkgs.postgresql_14.withPackages (p: [ p.pg_safeupdate p.postgis ])`.
      '';

      example = lib.literalExpression "pkgs.postgresql_14";
      type = lib.types.package;
    };

    postgresqlPort = lib.mkOption {
      default = 5432;

      description = ''
        The port on which PostgreSQL listens.
      '';

      type = lib.types.port;
    };

    restApiPort = lib.mkOption {
      default = 8008;

      description = ''
        The port on Patroni's REST api listens.
      '';

      type = lib.types.port;
    };

    scope = lib.mkOption {
      description = ''
        Cluster name.
      '';

      example = "cluster1";
      type = lib.types.str;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        The primary patroni configuration. See the [documentation](https://patroni.readthedocs.io/en/latest/yaml_configuration.html)
        for possible values.
        Secrets should be passed in by using the `environmentFiles` option.
      '';

      example = {
        bootstrap = {
          initdb = [
            "encoding=UTF-8"
            "data-checksums"
          ];
        };

        postgresql = {
          parameters = {
            unix_socket_directories = "/tmp";
          };
        };
      };

      type = format.type;
    };

    softwareWatchdog = lib.mkOption {
      default = false;

      description = ''
        This will configure Patroni to use the software watchdog built into the Linux kernel
        as described in the [documentation](https://patroni.readthedocs.io/en/latest/watchdog.html#setting-up-software-watchdog-on-linux).
      '';

      type = lib.types.bool;
    };

    user = lib.mkOption {
      default = defaultUser;

      description = ''
        The user for the service. If left as the default value this user will automatically be created,
        otherwise the sysadmin is responsible for ensuring the user exists.
      '';

      example = "postgres";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          !(
            cfg.enable
            && config.services.postgresql.enable
            && cfg.postgresqlDataDir == config.services.postgresql.dataDir
          );

        message = ''
          Both services.patroni and services.postgresql are enabled and
          services.patroni.postgresqlDataDir == services.postgresql.dataDir
          Disable one or the other, or configure them to use different directories.
        '';
      }
    ];

    boot.kernelModules = lib.mkIf cfg.softwareWatchdog [ "softdog" ];
    environment.etc."${configFileName}".source = configFile;

    environment.sessionVariables = {
      PATRONICTL_CONFIG_FILE = "/etc/${configFileName}";
    };

    environment.systemPackages = [
      pkgs.patroni
      cfg.postgresqlPackage
    ];

    services.patroni.settings = {
      name = cfg.name;
      namespace = cfg.namespace;

      postgresql = {
        bin_dir = "${cfg.postgresqlPackage}/bin";
        connect_address = "${cfg.nodeIp}:${toString cfg.postgresqlPort}";
        data_dir = cfg.postgresqlDataDir;
        listen = "${cfg.nodeIp}:${toString cfg.postgresqlPort}";
        pgpass = "${cfg.dataDir}/pgpass";
      };

      restapi = {
        connect_address = "${cfg.nodeIp}:${toString cfg.restApiPort}";
        listen = "${cfg.nodeIp}:${toString cfg.restApiPort}";
      };

      scope = cfg.scope;

      watchdog = lib.mkIf cfg.softwareWatchdog {
        device = "/dev/watchdog";
        mode = "required";
        safety_margin = 5;
      };
    };

    services.udev.extraRules = lib.mkIf cfg.softwareWatchdog ''
      KERNEL=="watchdog", OWNER="${cfg.user}", GROUP="${cfg.group}", MODE="0600"
    '';

    systemd.services = {
      patroni = {
        after = [ "network.target" ];
        description = "Runners to orchestrate a high-availability PostgreSQL";

        script = ''
          ${lib.concatStringsSep "\n" (
            lib.attrValues (
              lib.mapAttrs (name: path: ''export ${name}="$(< ${lib.escapeShellArg path})"'') cfg.environmentFiles
            )
          )}
          exec ${lib.getExe pkgs.patroni} ${configFile}
        '';

        serviceConfig = lib.mkMerge [
          {
            ExecReload = "${pkgs.coreutils}/bin/kill -s HUP $MAINPID";
            Group = cfg.group;
            KillMode = "process";
            Restart = "on-failure";
            TimeoutSec = 30;
            Type = "simple";
            User = cfg.user;
          }
          (lib.mkIf
            (
              cfg.postgresqlDataDir == "/var/lib/postgresql/${cfg.postgresqlPackage.psqlSchema}"
              && cfg.dataDir == "/var/lib/patroni"
            )
            {
              StateDirectory = "patroni postgresql postgresql/${cfg.postgresqlPackage.psqlSchema}";
              StateDirectoryMode = "0750";
            }
          )
        ];

        wantedBy = [ "multi-user.target" ];
      };
    };

    users = {
      groups = lib.mkIf (cfg.group == defaultGroup) {
        patroni = { };
      };

      users = lib.mkIf (cfg.user == defaultUser) {
        patroni = {
          group = cfg.group;
          isSystemUser = true;
        };
      };
    };
  };

  meta.maintainers = [ lib.maintainers.phfroidmont ];
}
