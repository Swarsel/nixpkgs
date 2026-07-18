{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hadoop;

  # Config files for hadoop services
  hadoopConf = "${import ./conf.nix { inherit cfg pkgs lib; }}/";

  # Generator for HDFS service options
  hadoopServiceOption =
    {
      serviceName,
      extraOpts ? null,
      firewallOption ? true,
    }:
    {
      enable = lib.mkEnableOption serviceName;

      extraEnv = lib.mkOption {
        default = { };
        description = "Extra environment variables for ${serviceName}";
        type = with lib.types; attrsOf str;
      };

      extraFlags = lib.mkOption {
        default = [ ];
        description = "Extra command line flags to pass to ${serviceName}";

        example = [
          "-Dcom.sun.management.jmxremote"
          "-Dcom.sun.management.jmxremote.port=8010"
        ];

        type = with lib.types; listOf str;
      };

      restartIfChanged = lib.mkOption {
        default = false;

        description = ''
          Automatically restart the service on config change.
          This can be set to false to defer restarts on clusters running critical applications.
          Please consider the security implications of inadvertently running an older version,
          and the possibility of unexpected behavior caused by inconsistent versions across a cluster when disabling this option.
        '';

        type = lib.types.bool;
      };
    }
    // (lib.optionalAttrs firewallOption {
      openFirewall = lib.mkOption {
        default = false;
        description = "Open firewall ports for ${serviceName}.";
        type = lib.types.bool;
      };
    })
    // (lib.optionalAttrs (extraOpts != null) extraOpts);

  # Generator for HDFS service configs
  hadoopServiceConfig =
    {
      name,
      User ? "hdfs",
      allowedTCPPorts ? [ ],
      description ? "Hadoop HDFS ${name}",
      environment ? { },
      extraConfig ? { },
      preStart ? "",
      serviceOptions ? cfg.hdfs."${lib.toLower name}",
    }:
    (

      lib.mkIf serviceOptions.enable (
        lib.mkMerge [
          {
            networking.firewall.allowedTCPPorts = lib.mkIf (
              (builtins.hasAttr "openFirewall" serviceOptions) && serviceOptions.openFirewall
            ) allowedTCPPorts;

            services.hadoop.gatewayRole.enable = true;

            systemd.services."hdfs-${lib.toLower name}" = {
              inherit description preStart;
              inherit (serviceOptions) restartIfChanged;
              environment = environment // serviceOptions.extraEnv;

              serviceConfig = {
                inherit User;
                ExecStart = "${cfg.package}/bin/hdfs --config ${hadoopConf} ${lib.toLower name} ${lib.escapeShellArgs serviceOptions.extraFlags}";
                Restart = "always";
                SyslogIdentifier = "hdfs-${lib.toLower name}";
              };

              wantedBy = [ "multi-user.target" ];
            };
          }
          extraConfig
        ]
      )
    );

in
{
  options.services.hadoop.hdfs = {

    datanode = hadoopServiceOption { serviceName = "HDFS DataNode"; } // {
      dataDirs = lib.mkOption {
        default = null;
        description = "Tier and path definitions for datanode storage.";

        type =
          with lib.types;
          nullOr (
            listOf (submodule {
              options = {
                path = lib.mkOption {
                  description = "Determines where on the local filesystem a data node should store its blocks.";
                  example = [ "/var/lib/hadoop/hdfs/dn" ];
                  type = path;
                };

                type = lib.mkOption {
                  description = ''
                    Storage types ([SSD]/[DISK]/[ARCHIVE]/[RAM_DISK]) for HDFS storage policies.
                  '';

                  type = enum [
                    "SSD"
                    "DISK"
                    "ARCHIVE"
                    "RAM_DISK"
                  ];
                };
              };
            })
          );
      };
    };

    httpfs = hadoopServiceOption { serviceName = "HDFS JournalNode"; } // {
      tempPath = lib.mkOption {
        default = "/tmp/hadoop/httpfs";
        description = "HTTPFS_TEMP path used by HTTPFS";
        type = lib.types.path;
      };
    };

    journalnode = hadoopServiceOption { serviceName = "HDFS JournalNode"; };

    namenode = hadoopServiceOption { serviceName = "HDFS NameNode"; } // {
      formatOnInit = lib.mkOption {
        default = false;

        description = ''
          Format HDFS namenode on first start. This is useful for quickly spinning up
          ephemeral HDFS clusters with a single namenode.
          For HA clusters, initialization involves multiple steps across multiple nodes.
          Follow this guide to initialize an HA cluster manually:
          <https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HDFSHighAvailabilityWithQJM.html>
        '';

        type = lib.types.bool;
      };
    };

    zkfc = hadoopServiceOption {
      firewallOption = false;
      serviceName = "HDFS ZooKeeper failover controller";
    };

  };

  config = lib.mkMerge [
    (hadoopServiceConfig {
      allowedTCPPorts = [
        9870 # namenode.http-address
        8020 # namenode.rpc-address
        8022 # namenode.servicerpc-address
        8019 # dfs.ha.zkfc.port
      ];

      name = "NameNode";

      preStart = (
        lib.mkIf cfg.hdfs.namenode.formatOnInit "${cfg.package}/bin/hdfs --config ${hadoopConf} namenode -format -nonInteractive || true"
      );
    })

    (hadoopServiceConfig {
      # port numbers for datanode changed between hadoop 2 and 3
      allowedTCPPorts =
        if lib.versionAtLeast cfg.package.version "3" then
          [
            9864 # datanode.http.address
            9866 # datanode.address
            9867 # datanode.ipc.address
          ]
        else
          [
            50075 # datanode.http.address
            50010 # datanode.address
            50020 # datanode.ipc.address
          ];

      extraConfig.services.hadoop.hdfsSiteInternal."dfs.datanode.data.dir" = lib.mkIf (
        cfg.hdfs.datanode.dataDirs != null
      ) (lib.concatMapStringsSep "," (x: "[" + x.type + "]file://" + x.path) cfg.hdfs.datanode.dataDirs);

      name = "DataNode";
    })

    (hadoopServiceConfig {
      allowedTCPPorts = [
        8480 # dfs.journalnode.http-address
        8485 # dfs.journalnode.rpc-address
      ];

      name = "JournalNode";
    })

    (hadoopServiceConfig {
      description = "Hadoop HDFS ZooKeeper failover controller";
      name = "zkfc";
    })

    (hadoopServiceConfig {
      User = "httpfs";

      allowedTCPPorts = [
        14000 # httpfs.http.port
      ];

      environment.HTTPFS_TEMP = cfg.hdfs.httpfs.tempPath;
      name = "HTTPFS";
      preStart = "mkdir -p $HTTPFS_TEMP";
    })

    (lib.mkIf cfg.gatewayRole.enable {
      users.users.hdfs = {
        description = "Hadoop HDFS user";
        group = "hadoop";
        uid = config.ids.uids.hdfs;
      };
    })
    (lib.mkIf cfg.hdfs.httpfs.enable {
      users.users.httpfs = {
        description = "Hadoop HTTPFS user";
        group = "hadoop";
        isSystemUser = true;
      };
    })

  ];
}
