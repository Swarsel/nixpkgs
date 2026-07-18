{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.hadoop;
  opt = options.services.hadoop;
in
{
  imports = [
    ./yarn.nix
    ./hdfs.nix
    ./hbase.nix
  ];

  options.services.hadoop = {
    package = lib.mkPackageOption pkgs "hadoop" { };

    containerExecutorCfg = lib.mkOption {
      default = {
        "feature.mount-cgroup.enabled" = 1;
        "feature.terminal.enabled" = 1;
        "min.user.id" = 1000;
        # must be the same as yarn.nodemanager.linux-container-executor.group in yarnSite
        "yarn.nodemanager.linux-container-executor.group" = "hadoop";
      };

      description = ''
        Yarn container-executor.cfg definition
        <https://hadoop.apache.org/docs/r2.7.2/hadoop-yarn/hadoop-yarn-site/SecureContainer.html>
      '';

      example = lib.literalExpression ''
        options.services.hadoop.containerExecutorCfg.default // {
          "feature.terminal.enabled" = 0;
        }
      '';

      type = lib.types.attrsOf lib.types.anything;
    };

    coreSite = lib.mkOption {
      default = { };

      description = ''
        Hadoop core-site.xml definition
        <https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/core-default.xml>
      '';

      example = lib.literalExpression ''
        {
          "fs.defaultFS" = "hdfs://localhost";
        }
      '';

      type = lib.types.attrsOf lib.types.anything;
    };

    coreSiteInternal = lib.mkOption {
      default = { };

      description = ''
        Internal option to add configs to core-site.xml based on module options
      '';

      internal = true;
      type = lib.types.attrsOf lib.types.anything;
    };

    extraConfDirs = lib.mkOption {
      default = [ ];
      description = "Directories containing additional config files to be added to HADOOP_CONF_DIR";

      example = lib.literalExpression ''
        [
          ./extraHDFSConfs
          ./extraYARNConfs
        ]
      '';

      type = lib.types.listOf lib.types.path;
    };

    gatewayRole.enable = lib.mkEnableOption "gateway role for deploying hadoop configs";

    hdfsSite = lib.mkOption {
      default = { };

      description = ''
        Additional options and overrides for hdfs-site.xml
        <https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/hdfs-default.xml>
      '';

      example = lib.literalExpression ''
        {
          "dfs.nameservices" = "namenode1";
        }
      '';

      type = lib.types.attrsOf lib.types.anything;
    };

    hdfsSiteDefault = lib.mkOption {
      default = {
        "dfs.namenode.http-address" = "0.0.0.0:9870";
        "dfs.namenode.http-bind-host" = "0.0.0.0";
        "dfs.namenode.rpc-bind-host" = "0.0.0.0";
        "dfs.namenode.servicerpc-bind-host" = "0.0.0.0";
      };

      description = ''
        Default options for hdfs-site.xml
      '';

      type = lib.types.attrsOf lib.types.anything;
    };

    hdfsSiteInternal = lib.mkOption {
      default = { };

      description = ''
        Internal option to add configs to hdfs-site.xml based on module options
      '';

      internal = true;
      type = lib.types.attrsOf lib.types.anything;
    };

    httpfsSite = lib.mkOption {
      default = { };

      description = ''
        Hadoop httpfs-site.xml definition
        <https://hadoop.apache.org/docs/current/hadoop-hdfs-httpfs/httpfs-default.html>
      '';

      example = lib.literalExpression ''
        {
          "hadoop.http.max.threads" = 500;
        }
      '';

      type = lib.types.attrsOf lib.types.anything;
    };

    log4jProperties = lib.mkOption {
      default = "${cfg.package}/etc/hadoop/log4j.properties";

      defaultText = lib.literalExpression ''
        "''${config.${opt.package}}/etc/hadoop/log4j.properties"
      '';

      description = "log4j.properties file added to HADOOP_CONF_DIR";

      example = lib.literalExpression ''
        "''${pkgs.hadoop}/etc/hadoop/log4j.properties";
      '';

      type = lib.types.path;
    };

    mapredSite = lib.mkOption {
      default = { };

      description = ''
        Additional options and overrides for mapred-site.xml
        <https://hadoop.apache.org/docs/current/hadoop-mapreduce-client/hadoop-mapreduce-client-core/mapred-default.xml>
      '';

      example = lib.literalExpression ''
        {
          "mapreduce.map.java.opts" = "-Xmx900m -XX:+UseParallelGC";
        }
      '';

      type = lib.types.attrsOf lib.types.anything;
    };

    mapredSiteDefault = lib.mkOption {
      default = {
        "mapreduce.framework.name" = "yarn";
        "mapreduce.map.env" = "HADOOP_MAPRED_HOME=${cfg.package}";
        "mapreduce.reduce.env" = "HADOOP_MAPRED_HOME=${cfg.package}";
        "yarn.app.mapreduce.am.env" = "HADOOP_MAPRED_HOME=${cfg.package}";
      };

      defaultText = lib.literalExpression ''
        {
          "mapreduce.framework.name" = "yarn";
          "yarn.app.mapreduce.am.env" = "HADOOP_MAPRED_HOME=''${config.${opt.package}}";
          "mapreduce.map.env" = "HADOOP_MAPRED_HOME=''${config.${opt.package}}";
          "mapreduce.reduce.env" = "HADOOP_MAPRED_HOME=''${config.${opt.package}}";
        }
      '';

      description = ''
        Default options for mapred-site.xml
      '';

      type = lib.types.attrsOf lib.types.anything;
    };

    yarnSite = lib.mkOption {
      default = { };

      description = ''
        Additional options and overrides for yarn-site.xml
        <https://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-common/yarn-default.xml>
      '';

      example = lib.literalExpression ''
        {
          "yarn.resourcemanager.hostname" = "''${config.networking.hostName}";
        }
      '';

      type = lib.types.attrsOf lib.types.anything;
    };

    yarnSiteDefault = lib.mkOption {
      default = {
        "yarn.nodemanager.admin-env" = "PATH=$PATH";
        "yarn.nodemanager.aux-services" = "mapreduce_shuffle";
        "yarn.nodemanager.aux-services.mapreduce_shuffle.class" = "org.apache.hadoop.mapred.ShuffleHandler";
        "yarn.nodemanager.bind-host" = "0.0.0.0";

        "yarn.nodemanager.container-executor.class" =
          "org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor";

        "yarn.nodemanager.env-whitelist" =
          "JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_HOME,LANG,TZ";

        "yarn.nodemanager.linux-container-executor.group" = "hadoop";

        "yarn.nodemanager.linux-container-executor.path" =
          "/run/wrappers/yarn-nodemanager/bin/container-executor";

        "yarn.nodemanager.log-dirs" = "/var/log/hadoop/yarn/nodemanager";
        "yarn.resourcemanager.bind-host" = "0.0.0.0";

        "yarn.resourcemanager.scheduler.class" =
          "org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler";
      };

      description = ''
        Default options for yarn-site.xml
      '';

      type = lib.types.attrsOf lib.types.anything;
    };

    yarnSiteInternal = lib.mkOption {
      default = { };

      description = ''
        Internal option to add configs to yarn-site.xml based on module options
      '';

      internal = true;
      type = lib.types.attrsOf lib.types.anything;
    };
  };

  config = lib.mkIf cfg.gatewayRole.enable {
    environment = {
      etc."hadoop-conf".source =
        let
          hadoopConf = "${import ./conf.nix { inherit cfg pkgs lib; }}/";
        in
        "${hadoopConf}";

      systemPackages = [ cfg.package ];
      variables.HADOOP_CONF_DIR = "/etc/hadoop-conf/";
    };

    users.groups.hadoop = {
      gid = config.ids.gids.hadoop;
    };
  };
}
