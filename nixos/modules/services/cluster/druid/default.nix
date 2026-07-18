{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.druid;
  inherit (lib)
    concatStrings
    concatStringsSep
    mapAttrsToList
    concatMap
    attrByPath
    mkIf
    mkMerge
    mkEnableOption
    mkOption
    types
    mkPackageOption
    ;

  druidServiceOption = serviceName: {
    config = mkOption {
      default = { };

      description = ''
        (key=value) Configuration to be written to runtime.properties of the druid ${serviceName}
        <https://druid.apache.org/docs/latest/configuration/index.html>
      '';

      example = {
        "druid.plainTextPort" = "8082";
        "druid.service" = "servicename";
      };

      type = types.attrsOf types.anything;
    };

    enable = mkEnableOption serviceName;

    internalConfig = mkOption {
      default = { };
      description = "Internal Option to add to runtime.properties for ${serviceName}.";
      internal = true;
      type = types.attrsOf types.anything;
    };

    jdk = mkPackageOption pkgs "JDK" { default = [ "jdk17_headless" ]; };

    jvmArgs = mkOption {
      default = "";
      description = "Arguments to pass to the JVM";
      type = types.str;
    };

    openFirewall = mkOption {
      default = false;
      description = "Open firewall ports for ${serviceName}.";
      type = types.bool;
    };

    restartIfChanged = mkOption {
      default = false;

      description = ''
        Automatically restart the service on config change.
        This can be set to false to defer restarts on clusters running critical applications.
        Please consider the security implications of inadvertently running an older version,
        and the possibility of unexpected behavior caused by inconsistent versions across a cluster when disabling this option.
      '';

      type = types.bool;
    };
  };

  druidServiceConfig =
    {
      name,
      allowedTCPPorts ? [ ],
      extraConfig ? { },
      serviceOptions ? cfg."${name}",
      tmpDirs ? [ ],
    }:
    (mkIf serviceOptions.enable (mkMerge [
      {
        networking.firewall.allowedTCPPorts = mkIf (attrByPath [
          "openFirewall"
        ] false serviceOptions) allowedTCPPorts;

        systemd = {
          services."druid-${name}" = {
            inherit (serviceOptions) restartIfChanged;
            after = [ "network.target" ];
            description = "Druid ${name}";

            path = [
              cfg.package
              serviceOptions.jdk
            ];

            script =
              let
                cfgFile =
                  fileName: properties:
                  pkgs.writeTextDir fileName (
                    concatStringsSep "\n" (mapAttrsToList (n: v: "${n}=${toString v}") properties)
                  );

                commonConfigFile = cfgFile "common.runtime.properties" cfg.commonConfig;

                configFile = cfgFile "runtime.properties" (serviceOptions.config // serviceOptions.internalConfig);

                extraClassPath = concatStrings (map (path: ":" + path) cfg.extraClassPaths);

                extraConfDir = concatStrings (map (dir: ":" + dir + "/*") cfg.extraConfDirs);
              in
              ''
                run-java -Dlog4j.configurationFile=file:${cfg.log4j} \
                  -Ddruid.extensions.directory=${cfg.package}/extensions \
                  -Ddruid.extensions.hadoopDependenciesDir=${cfg.package}/hadoop-dependencies \
                  -classpath  ${commonConfigFile}:${configFile}:${cfg.package}/lib/\*${extraClassPath}${extraConfDir} \
                  ${serviceOptions.jvmArgs} \
                  org.apache.druid.cli.Main server ${name}
              '';

            serviceConfig = {
              Restart = "always";
              SyslogIdentifier = "druid-${name}";
              User = "druid";
            };

            wantedBy = [ "multi-user.target" ];
          };

          tmpfiles.rules = concatMap (x: [ "d ${x} 0755 druid druid" ]) (cfg.commonTmpDirs ++ tmpDirs);
        };

        users = {
          groups.druid = { };

          users.druid = {
            description = "Druid user";
            group = "druid";
            isNormalUser = true;
          };
        };
      }
      extraConfig
    ]));
in
{
  options.services.druid = {
    package = mkPackageOption pkgs "apache-druid" { default = [ "druid" ]; };
    broker = druidServiceOption "Druid Broker";

    commonConfig = mkOption {
      default = { };
      description = "(key=value) Configuration to be written to common.runtime.properties";

      example = {
        "druid.extensions.loadList" = ''[ "mysql-metadata-storage" ]'';
        "druid.metadata.storage.connector.connectURI" = "jdbc:mysql://localhost:3306/druid";
        "druid.metadata.storage.type" = "mysql";
        "druid.zk.service.host" = "localhost:2181";
      };

      type = types.attrsOf types.anything;
    };

    commonTmpDirs = mkOption {
      default = [ "/var/log/druid/requests" ];
      description = "Common List of directories used by druid processes";
      type = types.listOf types.str;
    };

    coordinator = druidServiceOption "Druid Coordinator";

    extraClassPaths = mkOption {
      default = [ ];
      description = "Extra classpath to include in the jvm";
      type = types.listOf types.str;
    };

    extraConfDirs = mkOption {
      default = [ ];
      description = "Extra Conf Dirs to include in the jvm";
      type = types.listOf types.path;
    };

    historical = (druidServiceOption "Druid Historical") // {
      segmentLocations = mkOption {

        default = null;
        description = "Locations where the historical will store its data.";

        type =
          with types;
          nullOr (
            listOf (submodule {
              options = {
                freeSpacePercent = mkOption {
                  default = 1.0;
                  description = "Druid Historical will fail to write if it exceeds this value";
                  type = float;
                };

                maxSize = mkOption {
                  description = "Max size the druid historical can occupy";
                  type = str;
                };

                path = mkOption {
                  description = "the path to store the segments";
                  type = path;
                };
              };
            })
          );

      };
    };

    log4j = mkOption {
      description = "Log4j Configuration for the druid process";
      type = types.path;
    };

    middleManager = druidServiceOption "Druid middleManager";
    overlord = druidServiceOption "Druid Overlord";
    router = druidServiceOption "Druid Router";
  };

  config = mkMerge [
    (druidServiceConfig rec {
      allowedTCPPorts = [ (attrByPath [ "druid.plaintextPort" ] 8090 cfg."${name}".config) ];
      name = "overlord";
    })

    (druidServiceConfig rec {
      allowedTCPPorts = [ (attrByPath [ "druid.plaintextPort" ] 8081 cfg."${name}".config) ];
      name = "coordinator";
    })

    (druidServiceConfig rec {
      allowedTCPPorts = [ (attrByPath [ "druid.plaintextPort" ] 8082 cfg."${name}".config) ];
      name = "broker";
      tmpDirs = [ (attrByPath [ "druid.lookup.snapshotWorkingDir" ] "" cfg."${name}".config) ];
    })

    (druidServiceConfig rec {
      allowedTCPPorts = [ (attrByPath [ "druid.plaintextPort" ] 8083 cfg."${name}".config) ];

      extraConfig.services.druid.historical.internalConfig."druid.segmentCache.locations" =
        builtins.toJSON cfg.historical.segmentLocations;

      name = "historical";

      tmpDirs = [
        (attrByPath [ "druid.lookup.snapshotWorkingDir" ] "" cfg."${name}".config)
      ]
      ++ (map (x: x.path) cfg."${name}".segmentLocations);
    })

    (druidServiceConfig rec {
      allowedTCPPorts = [ (attrByPath [ "druid.plaintextPort" ] 8091 cfg."${name}".config) ];

      extraConfig = {
        networking.firewall.allowedTCPPortRanges = mkIf cfg.middleManager.openFirewall [
          {
            from = attrByPath [ "druid.indexer.runner.startPort" ] 8100 cfg.middleManager.config;
            to = attrByPath [ "druid.indexer.runner.endPort" ] 65535 cfg.middleManager.config;
          }
        ];

        services.druid.middleManager.internalConfig = {
          "druid.indexer.runner.javaCommand" = "${cfg.middleManager.jdk}/bin/java";

          "druid.indexer.runner.javaOpts" =
            (attrByPath [ "druid.indexer.runner.javaOpts" ] "" cfg.middleManager.config)
            + " -Dlog4j.configurationFile=file:${cfg.log4j}";
        };
      };

      name = "middleManager";

      tmpDirs = [
        "/var/log/druid/indexer"
      ]
      ++ [ (attrByPath [ "druid.indexer.task.baseTaskDir" ] "" cfg."${name}".config) ];
    })

    (druidServiceConfig rec {
      allowedTCPPorts = [ (attrByPath [ "druid.plaintextPort" ] 8888 cfg."${name}".config) ];
      name = "router";
    })
  ];

}
