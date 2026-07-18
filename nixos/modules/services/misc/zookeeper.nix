{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.zookeeper;

  zookeeperConfig = ''
    dataDir=${cfg.dataDir}
    clientPort=${toString cfg.port}
    autopurge.purgeInterval=${toString cfg.purgeInterval}
    ${cfg.extraConf}
    ${cfg.servers}
  '';

  configDir = pkgs.buildEnv {
    name = "zookeeper-conf";

    paths = [
      (pkgs.writeTextDir "zoo.cfg" zookeeperConfig)
      (pkgs.writeTextDir "logback.xml" cfg.logging)
    ];
  };

in
{

  options.services.zookeeper = {
    enable = lib.mkEnableOption "Zookeeper";
    package = lib.mkPackageOption pkgs "zookeeper" { };

    dataDir = lib.mkOption {
      default = "/var/lib/zookeeper";

      description = ''
        Data directory for Zookeeper
      '';

      type = lib.types.path;
    };

    extraCmdLineOptions = lib.mkOption {
      default = [
        "-Dcom.sun.management.jmxremote"
        "-Dcom.sun.management.jmxremote.local.only=true"
      ];

      description = "Extra command line options for the Zookeeper launcher.";

      example = [
        "-Djava.net.preferIPv4Stack=true"
        "-Dcom.sun.management.jmxremote"
        "-Dcom.sun.management.jmxremote.local.only=true"
      ];

      type = lib.types.listOf lib.types.str;
    };

    extraConf = lib.mkOption {
      default = ''
        initLimit=5
        syncLimit=2
        tickTime=2000
      '';

      description = "Extra configuration for Zookeeper.";
      type = lib.types.lines;
    };

    id = lib.mkOption {
      default = 0;
      description = "Zookeeper ID.";
      type = lib.types.int;
    };

    jre = lib.mkOption {
      default = cfg.package.jre;
      defaultText = lib.literalExpression "pkgs.zookeeper.jre";
      description = "The JRE with which to run Zookeeper";
      example = lib.literalExpression "pkgs.jre";
      type = lib.types.package;
    };

    logging = lib.mkOption {
      default = ''
        <configuration>
          <property name="zookeeper.console.threshold" value="INFO" />
          <property name="zookeeper.log.dir" value="." />
          <property name="zookeeper.log.file" value="zookeeper.log" />
          <property name="zookeeper.log.threshold" value="INFO" />
          <property name="zookeeper.log.maxfilesize" value="256MB" />
          <property name="zookeeper.log.maxbackupindex" value="20" />
          <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
            <encoder>
              <pattern>%d{ISO8601} [myid:%X{myid}] - %-5p [%t:%C{1}@%L] - %m%n</pattern>
            </encoder>
            <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
              <level>''${zookeeper.console.threshold}</level>
            </filter>
          </appender>
          <root level="INFO">
            <appender-ref ref="CONSOLE" />
          </root>
        </configuration>
      '';

      description = "Zookeeper logging configuration, logback.xml.";
      type = lib.types.lines;
    };

    port = lib.mkOption {
      default = 2181;
      description = "Zookeeper Client port.";
      type = lib.types.port;
    };

    preferIPv4 = lib.mkOption {
      default = true;

      description = ''
        Add the -Djava.net.preferIPv4Stack=true flag to the Zookeeper server.
      '';

      type = lib.types.bool;
    };

    purgeInterval = lib.mkOption {
      default = 1;

      description = ''
        The time interval in hours for which the purge task has to be triggered. Set to a positive integer (1 and above) to enable the auto purging.
      '';

      type = lib.types.int;
    };

    servers = lib.mkOption {
      default = "";
      description = "All Zookeeper Servers.";

      example = ''
        server.0=host0:2888:3888
        server.1=host1:2888:3888
        server.2=host2:2888:3888
      '';

      type = lib.types.lines;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.zookeeper = {
      after = [ "network.target" ];
      description = "Zookeeper Daemon";

      preStart = ''
        echo "${toString cfg.id}" > ${cfg.dataDir}/myid
        mkdir -p ${cfg.dataDir}/version-2
      '';

      serviceConfig = {
        ExecStart = ''
          ${cfg.jre}/bin/java \
            -cp "${cfg.package}/lib/*:${configDir}" \
            ${lib.escapeShellArgs cfg.extraCmdLineOptions} \
            -Dzookeeper.datadir.autocreate=false \
            ${lib.optionalString cfg.preferIPv4 "-Djava.net.preferIPv4Stack=true"} \
            org.apache.zookeeper.server.quorum.QuorumPeerMain \
            ${configDir}/zoo.cfg
        '';

        User = "zookeeper";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0700 zookeeper - - -"
      "Z '${cfg.dataDir}' 0700 zookeeper - - -"
    ];

    users.groups.zookeeper = { };

    users.users.zookeeper = {
      description = "Zookeeper daemon user";
      group = "zookeeper";
      home = cfg.dataDir;
      isSystemUser = true;
    };
  };
}
