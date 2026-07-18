{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.elasticsearch;

  es7 = builtins.compareVersions cfg.package.version "7" >= 0;

  esConfig = ''
    network.host: ${cfg.listenAddress}
    cluster.name: ${cfg.cluster_name}
    ${lib.optionalString cfg.single_node "discovery.type: single-node"}
    ${lib.optionalString (cfg.single_node && es7) "gateway.auto_import_dangling_indices: true"}

    http.port: ${toString cfg.port}
    transport.port: ${toString cfg.tcp_port}

    ${cfg.extraConf}
  '';

  configDir = cfg.dataDir + "/config";

  elasticsearchYml = pkgs.writeTextFile {
    name = "elasticsearch.yml";
    text = esConfig;
  };

  loggingConfigFilename = "log4j2.properties";
  loggingConfigFile = pkgs.writeTextFile {
    name = loggingConfigFilename;
    text = cfg.logging;
  };

  esPlugins = pkgs.buildEnv {
    name = "elasticsearch-plugins";
    paths = cfg.plugins;
    postBuild = "${pkgs.coreutils}/bin/mkdir -p $out/plugins";
  };

in
{

  ###### interface

  options.services.elasticsearch = {
    enable = mkOption {
      default = false;
      description = "Whether to enable elasticsearch.";
      type = types.bool;
    };

    package = mkPackageOption pkgs "elasticsearch" { };

    cluster_name = mkOption {
      default = "elasticsearch";
      description = "Elasticsearch name that identifies your cluster for auto-discovery.";
      type = types.str;
    };

    dataDir = mkOption {
      default = "/var/lib/elasticsearch";

      description = ''
        Data directory for elasticsearch.
      '';

      type = types.path;
    };

    extraCmdLineOptions = mkOption {
      default = [ ];
      description = "Extra command line options for the elasticsearch launcher.";
      type = types.listOf types.str;
    };

    extraConf = mkOption {
      default = "";
      description = "Extra configuration for elasticsearch.";

      example = ''
        node.name: "elasticsearch"
        node.master: true
        node.data: false
      '';

      type = types.str;
    };

    extraJavaOptions = mkOption {
      default = [ ];
      description = "Extra command line options for Java.";
      example = [ "-Djava.net.preferIPv4Stack=true" ];
      type = types.listOf types.str;
    };

    listenAddress = mkOption {
      default = "127.0.0.1";
      description = "Elasticsearch listen address.";
      type = types.str;
    };

    logging = mkOption {
      default = ''
        logger.action.name = org.elasticsearch.action
        logger.action.level = info

        appender.console.type = Console
        appender.console.name = console
        appender.console.layout.type = PatternLayout
        appender.console.layout.pattern = [%d{ISO8601}][%-5p][%-25c{1.}] %marker%m%n

        rootLogger.level = info
        rootLogger.appenderRef.console.ref = console
      '';

      description = "Elasticsearch logging configuration.";
      type = types.str;
    };

    plugins = mkOption {
      default = [ ];
      description = "Extra elasticsearch plugins";
      example = lib.literalExpression "[ pkgs.elasticsearchPlugins.discovery-ec2 ]";
      type = types.listOf types.package;
    };

    port = mkOption {
      default = 9200;
      description = "Elasticsearch port to listen for HTTP traffic.";
      type = types.port;
    };

    restartIfChanged = mkOption {
      default = true;

      description = ''
        Automatically restart the service on config change.
        This can be set to false to defer restarts on a server or cluster.
        Please consider the security implications of inadvertently running an older version,
        and the possibility of unexpected behavior caused by inconsistent versions across a cluster when disabling this option.
      '';

      type = types.bool;
    };

    single_node = mkOption {
      default = true;
      description = "Start a single-node cluster";
      type = types.bool;
    };

    tcp_port = mkOption {
      default = 9300;
      description = "Elasticsearch port for the node to node communication.";
      type = types.port;
    };

  };

  ###### implementation

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.elasticsearch = {
      inherit (cfg) restartIfChanged;
      after = [ "network.target" ];
      description = "Elasticsearch Daemon";

      environment = {
        ES_HOME = cfg.dataDir;
        ES_JAVA_OPTS = toString cfg.extraJavaOptions;
        ES_PATH_CONF = configDir;
      };

      path = [ pkgs.inetutils ];

      postStart = ''
        # Make sure elasticsearch is up and running before dependents
        # are started
        while ! ${pkgs.curl}/bin/curl -sS -f http://${cfg.listenAddress}:${toString cfg.port} 2>/dev/null; do
          sleep 1
        done
      '';

      preStart = ''
        ${optionalString (!config.boot.isContainer) ''
          # Only set vm.max_map_count if lower than ES required minimum
          # This avoids conflict if configured via boot.kernel.sysctl
          if [ `${pkgs.procps}/bin/sysctl -n vm.max_map_count` -lt 262144 ]; then
            ${pkgs.procps}/bin/sysctl -w vm.max_map_count=262144
          fi
        ''}

        mkdir -m 0700 -p ${cfg.dataDir}

        # Install plugins
        ln -sfT ${esPlugins}/plugins ${cfg.dataDir}/plugins
        ln -sfT ${cfg.package}/lib ${cfg.dataDir}/lib
        ln -sfT ${cfg.package}/modules ${cfg.dataDir}/modules

        # elasticsearch needs to create the elasticsearch.keystore in the config directory
        # so this directory needs to be writable.
        mkdir -m 0700 -p ${configDir}

        # Note that we copy config files from the nix store instead of symbolically linking them
        # because otherwise X-Pack Security will raise the following exception:
        # java.security.AccessControlException:
        # access denied ("java.io.FilePermission" "/var/lib/elasticsearch/config/elasticsearch.yml" "read")

        cp ${elasticsearchYml} ${configDir}/elasticsearch.yml
        # Make sure the logging configuration for old elasticsearch versions is removed:
        rm -f "${configDir}/logging.yml"
        cp ${loggingConfigFile} ${configDir}/${loggingConfigFilename}
        mkdir -p ${configDir}/scripts
        cp ${cfg.package}/config/jvm.options ${configDir}/jvm.options
        # redirect jvm logs to the data directory
        mkdir -m 0700 -p ${cfg.dataDir}/logs
        ${pkgs.sd}/bin/sd 'logs/gc.log' '${cfg.dataDir}/logs/gc.log' ${configDir}/jvm.options \

        if [ "$(id -u)" = 0 ]; then chown -R elasticsearch:elasticsearch ${cfg.dataDir}; fi
      '';

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/elasticsearch ${toString cfg.extraCmdLineOptions}";
        LimitNOFILE = "1024000";
        PermissionsStartOnly = true;
        Restart = "always";
        TimeoutStartSec = "infinity";
        User = "elasticsearch";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users = {
      groups.elasticsearch.gid = config.ids.gids.elasticsearch;

      users.elasticsearch = {
        description = "Elasticsearch daemon user";
        group = "elasticsearch";
        home = cfg.dataDir;
        uid = config.ids.uids.elasticsearch;
      };
    };
  };
}
