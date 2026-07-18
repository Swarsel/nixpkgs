{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hadoop;
  hadoopConf = "${import ./conf.nix { inherit cfg pkgs lib; }}/";
  mkIfNotNull = x: lib.mkIf (x != null) x;
  # generic hbase role options
  hbaseRoleOption =
    name: extraOpts:
    {
      enable = lib.mkEnableOption "HBase ${name}";

      environment = lib.mkOption {
        default = { };
        description = "Environment variables passed to ${name}.";

        example = lib.literalExpression ''
          {
            HBASE_MASTER_OPTS = "-Dcom.sun.management.jmxremote.ssl=true";
          }
        '';

        type = with lib.types; attrsOf str;
      };

      extraFlags = lib.mkOption {
        default = [ ];
        description = "Extra flags for the ${name} service.";
        example = lib.literalExpression ''[ "--backup" ]'';
        type = with lib.types; listOf str;
      };

      openFirewall = lib.mkOption {
        default = false;
        description = "Open firewall ports for HBase ${name}.";
        type = lib.types.bool;
      };

      restartIfChanged = lib.mkOption {
        default = false;
        description = "Restart ${name} con config change.";
        type = lib.types.bool;
      };
    }
    // extraOpts;
  # generic hbase role configs
  hbaseRoleConfig =
    name: ports:
    (lib.mkIf cfg.hbase."${name}".enable {
      networking = {
        firewall.allowedTCPPorts = lib.mkIf cfg.hbase."${name}".openFirewall ports;

        hosts = lib.mkIf (with cfg.hbase.regionServer; enable && overrideHosts) {
          "127.0.0.2" = lib.mkForce [ ];
          "::1" = lib.mkForce [ ];
        };
      };

      services.hadoop.gatewayRole = {
        enable = true;
        enableHbaseCli = lib.mkDefault true;
      };

      services.hadoop.hbaseSiteInternal."hbase.rootdir" = cfg.hbase.rootdir;

      systemd.services."hbase-${lib.toLower name}" = {
        inherit (cfg.hbase."${name}") environment;
        description = "HBase ${name}";

        path =
          with cfg;
          [ hbase.package ] ++ lib.optional (with cfg.hbase.master; enable && initHDFS) package;

        preStart = lib.mkIf (with cfg.hbase.master; enable && initHDFS) (
          lib.concatStringsSep "\n" (
            map (x: "HADOOP_USER_NAME=hdfs hdfs --config /etc/hadoop-conf ${x}") [
              "dfsadmin -safemode wait"
              "dfs -mkdir -p ${cfg.hbase.rootdir}"
              "dfs -chown hbase ${cfg.hbase.rootdir}"
            ]
          )
        );

        script = lib.concatStringsSep " " (
          [
            "hbase --config /etc/hadoop-conf/"
            "${lib.toLower name} start"
          ]
          ++ cfg.hbase."${name}".extraFlags
          ++ map (x: "--${lib.toLower x} ${toString cfg.hbase.${name}.${x}}") (
            lib.filter (x: lib.hasAttr x cfg.hbase.${name}) [
              "port"
              "infoPort"
            ]
          )
        );

        serviceConfig = {
          Restart = "always";
          SyslogIdentifier = "hbase-${lib.toLower name}";
          User = "hbase";
        };

        wantedBy = [ "multi-user.target" ];
      };

    });
in
{
  options.services.hadoop = {

    gatewayRole.enableHbaseCli = lib.mkEnableOption "HBase CLI tools";

    hbase = {

      package = lib.mkPackageOption pkgs "hbase" { };

      rootdir = lib.mkOption {
        default = "/hbase";

        description = ''
          This option will set "hbase.rootdir" in hbase-site.xml and determine
          the directory shared by region servers and into which HBase persists.
          The URL should be 'fully-qualified' to include the filesystem scheme.
          If a core-site.xml is provided, the FS scheme defaults to the value
          of "fs.defaultFS".

          Filesystems other than HDFS (like S3, QFS, Swift) are also supported.
        '';

        example = "hdfs://nameservice1/hbase";
        type = lib.types.str;
      };

      zookeeperQuorum = lib.mkOption {
        default = null;

        description = ''
          This option will set "hbase.zookeeper.quorum" in hbase-site.xml.
          Comma separated list of servers in the ZooKeeper ensemble.
        '';

        example = "zk1.internal,zk2.internal,zk3.internal";
        type = with lib.types; nullOr commas;
      };
    }
    // (
      let
        ports = port: infoPort: {
          infoPort = lib.mkOption {
            default = infoPort;
            description = "web UI port";
            type = lib.types.port;
          };

          port = lib.mkOption {
            default = port;
            description = "RPC port";
            type = lib.types.port;
          };
        };
      in
      lib.mapAttrs hbaseRoleOption {
        master.initHDFS = lib.mkEnableOption "initialization of the hbase directory on HDFS";

        regionServer.overrideHosts = lib.mkOption {
          default = true;

          description = ''
            Remove /etc/hosts entries for "127.0.0.2" and "::1" defined in nixos/modules/config/networking.nix
            Regionservers must be able to resolve their hostnames to their IP addresses, through PTR records
            or /etc/hosts entries.
          '';

          type = lib.types.bool;
        };

        rest = ports 8080 8085;
        thrift = ports 9090 9095;
      }
    );

    hbaseSite = lib.mkOption {
      default = { };

      description = ''
        Additional options and overrides for hbase-site.xml
        <https://github.com/apache/hbase/blob/rel/2.4.11/hbase-common/src/main/resources/hbase-default.xml>
      '';

      example = lib.literalExpression ''
        {
          "hbase.hregion.max.filesize" = 20*1024*1024*1024;
          "hbase.table.normalization.enabled" = "true";
        }
      '';

      type = with lib.types; attrsOf anything;
    };

    hbaseSiteDefault = lib.mkOption {
      default = {
        "hbase.cluster.distributed" = "true";
        "hbase.master.info.bindAddress" = "0.0.0.0";
        "hbase.master.ipc.address" = "0.0.0.0";
        "hbase.regionserver.info.bindAddress" = "0.0.0.0";
        "hbase.regionserver.ipc.address" = "0.0.0.0";
      };

      description = ''
        Default options for hbase-site.xml
      '';

      type = lib.types.attrsOf lib.types.anything;
    };

    hbaseSiteInternal = lib.mkOption {
      default = { };

      description = ''
        Internal option to add configs to hbase-site.xml based on module options
      '';

      internal = true;
      type = with lib.types; attrsOf anything;
    };
  };

  config = lib.mkMerge (
    [

      (lib.mkIf cfg.gatewayRole.enable {

        environment.systemPackages = lib.mkIf cfg.gatewayRole.enableHbaseCli [ cfg.hbase.package ];

        services.hadoop.hbaseSiteInternal = with cfg.hbase; {
          "hbase.zookeeper.quorum" = mkIfNotNull zookeeperQuorum;
        };

        users.users.hbase = {
          description = "Hadoop HBase user";
          group = "hadoop";
          isSystemUser = true;
        };
      })
    ]
    ++ (lib.mapAttrsToList hbaseRoleConfig {
      master = [
        16000
        16010
      ];

      regionServer = [
        16020
        16030
      ];

      rest = with cfg.hbase.rest; [
        port
        infoPort
      ];

      thrift = with cfg.hbase.thrift; [
        port
        infoPort
      ];
    })
  );
}
