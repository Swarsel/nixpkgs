{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.dysnomia;

  printProperties =
    properties:
    lib.concatMapStrings (
      propertyName:
      let
        property = properties.${propertyName};
      in
      if lib.isList property then
        "${propertyName}=(${
          lib.concatMapStrings (elem: "\"${toString elem}\" ") (properties.${propertyName})
        })\n"
      else
        "${propertyName}=\"${toString property}\"\n"
    ) (builtins.attrNames properties);

  properties = pkgs.stdenv.mkDerivation {
    buildCommand = ''
      cat > $out << "EOF"
      ${printProperties cfg.properties}
      EOF
    '';

    name = "dysnomia-properties";
  };

  containersDir = pkgs.stdenv.mkDerivation {
    buildCommand = ''
      mkdir -p $out
      cd $out

      ${lib.concatMapStrings (
        containerName:
        let
          containerProperties = cfg.containers.${containerName};
        in
        ''
          cat > ${containerName} <<EOF
          ${printProperties containerProperties}
          type=${containerName}
          EOF
        ''
      ) (builtins.attrNames cfg.containers)}
    '';

    name = "dysnomia-containers";
  };

  linkMutableComponents =
    { containerName }:
    ''
      mkdir ${containerName}

      ${lib.concatMapStrings (
        componentName:
        let
          component = cfg.components.${containerName}.${componentName};
        in
        "ln -s ${component} ${containerName}/${componentName}\n"
      ) (builtins.attrNames (cfg.components.${containerName} or { }))}
    '';

  componentsDir = pkgs.stdenv.mkDerivation {
    buildCommand = ''
      mkdir -p $out
      cd $out

      ${lib.concatMapStrings (containerName: linkMutableComponents { inherit containerName; }) (
        builtins.attrNames cfg.components
      )}
    '';

    name = "dysnomia-components";
  };

  dysnomiaFlags = {
    enableApacheWebApplication = config.services.httpd.enable;
    enableAxis2WebService = config.services.tomcat.axis2.enable;
    enableDockerContainer = config.virtualisation.docker.enable;
    enableEjabberdDump = config.services.ejabberd.enable;
    enableInfluxDatabase = config.services.influxdb.enable;
    enableMongoDatabase = config.services.mongodb.enable;
    enableMySQLDatabase = config.services.mysql.enable;
    enablePostgreSQLDatabase = config.services.postgresql.enable;
    enableSubversionRepository = config.services.svnserve.enable;
    enableTomcatWebApplication = config.services.tomcat.enable;
  };
in
{
  imports = [
    (lib.mkRenamedOptionModule [ "dysnomia" ] [ "services" "dysnomia" ])
  ];

  options = {
    services.dysnomia = {

      enable = lib.mkOption {
        default = false;
        description = "Whether to enable Dysnomia";
        type = lib.types.bool;
      };

      package = lib.mkOption {
        description = "The Dysnomia package";
        type = lib.types.path;
      };

      components = lib.mkOption {
        default = { };
        description = "An attribute set in which each key represents a container and each value an attribute set in which each key represents a component and each value a derivation constructing its initial state";
        type = lib.types.attrsOf lib.types.attrs;
      };

      containers = lib.mkOption {
        default = { };
        description = "An attribute set in which each key represents a container and each value an attribute set providing its configuration properties";
        type = lib.types.attrsOf lib.types.attrs;
      };

      enableAuthentication = lib.mkOption {
        default = false;
        description = "Whether to publish privacy-sensitive authentication credentials";
        type = lib.types.bool;
      };

      enableLegacyModules = lib.mkOption {
        default = true;
        description = "Whether to enable Dysnomia legacy process and wrapper modules";
        type = lib.types.bool;
      };

      extraContainerPaths = lib.mkOption {
        default = [ ];
        description = "A list of paths containing additional container configurations that are added to the search folders";
        type = lib.types.listOf lib.types.path;
      };

      extraContainerProperties = lib.mkOption {
        default = { };
        description = "An attribute set providing additional container settings in addition to the default properties";
        type = lib.types.attrs;
      };

      extraModulePaths = lib.mkOption {
        default = [ ];
        description = "A list of paths containing additional modules that are added to the search folders";
        type = lib.types.listOf lib.types.path;
      };

      properties = lib.mkOption {
        default = { };
        description = "An attribute set in which each attribute represents a machine property. Optionally, these values can be shell substitutions.";
        type = lib.types.attrs;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    boot.extraSystemdUnitPaths = [ "/etc/systemd-mutable/system" ];

    environment.etc = {
      "dysnomia/components" = {
        source = componentsDir;
      };

      "dysnomia/containers" = {
        source = containersDir;
      };

      "dysnomia/properties" = {
        source = properties;
      };
    };

    environment.systemPackages = [ cfg.package ];

    environment.variables = {
      DYSNOMIA_CONTAINERS_PATH = "${
        lib.concatMapStrings (containerPath: "${containerPath}:") cfg.extraContainerPaths
      }/etc/dysnomia/containers";

      DYSNOMIA_MODULES_PATH = "${
        lib.concatMapStrings (modulePath: "${modulePath}:") cfg.extraModulePaths
      }/etc/dysnomia/modules";

      DYSNOMIA_STATEDIR = "/var/state/dysnomia-nixos";
    };

    services.dysnomia.containers = lib.recursiveUpdate (
      {
        process = { };
        wrapper = { };
      }
      // lib.optionalAttrs (config.services.httpd.enable) {
        apache-webapplication = {
          documentRoot = config.services.httpd.virtualHosts.localhost.documentRoot;
        };
      }
      // lib.optionalAttrs (config.services.tomcat.axis2.enable) { axis2-webservice = { }; }
      // lib.optionalAttrs (config.services.ejabberd.enable) {
        ejabberd-dump = {
          ejabberdUser = config.services.ejabberd.user;
        };
      }
      // lib.optionalAttrs (config.services.mysql.enable) {
        mysql-database = {
          mysqlPort = config.services.mysql.settings.mysqld.port;
          mysqlSocket = "/run/mysqld/mysqld.sock";
        }
        // lib.optionalAttrs cfg.enableAuthentication {
          mysqlUsername = "root";
        };
      }
      // lib.optionalAttrs (config.services.postgresql.enable) {
        postgresql-database = {
        }
        // lib.optionalAttrs (cfg.enableAuthentication) {
          postgresqlUsername = "postgres";
        };
      }
      // lib.optionalAttrs (config.services.tomcat.enable) {
        tomcat-webapplication = {
          tomcatPort = 8080;
        };
      }
      // lib.optionalAttrs (config.services.mongodb.enable) { mongo-database = { }; }
      // lib.optionalAttrs (config.services.influxdb.enable) {
        influx-database = {
          influxdbDataDir = "${config.services.influxdb.dataDir}/data";
          influxdbMetaDir = "${config.services.influxdb.dataDir}/meta";
          influxdbUsername = config.services.influxdb.user;
        };
      }
      // lib.optionalAttrs (config.services.svnserve.enable) {
        subversion-repository = {
          svnBaseDir = config.services.svnserve.svnBaseDir;
        };
      }
    ) cfg.extraContainerProperties;

    services.dysnomia.package = pkgs.dysnomia.override (
      origArgs:
      dysnomiaFlags
      // lib.optionalAttrs (cfg.enableLegacyModules) {
        enableLegacy = builtins.trace ''
          WARNING: Dysnomia has been configured to use the legacy 'process' and 'wrapper'
          modules for compatibility reasons! If you rely on these modules, consider
          migrating to better alternatives.

          More information: <https://raw.githubusercontent.com/svanderburg/dysnomia/f65a9a84827bcc4024d6b16527098b33b02e4054/README-legacy.md>

          If you have migrated already or don't rely on these Dysnomia modules, you can
          disable legacy mode with the following NixOS configuration option:

          dysnomia.enableLegacyModules = false;

          In a future version of Dysnomia (and NixOS) the legacy option will go away!
        '' true;
      }
    );

    services.dysnomia.properties = {
      inherit (pkgs.stdenv.hostPlatform) system;
      hostname = config.networking.hostName;

      supportedTypes = [
        "echo"
        "fileset"
        "process"
        "wrapper"

        # These are not base modules, but they are still enabled because they work with technology that are always enabled in NixOS
        "systemd-unit"
        "sysvinit-script"
        "nixos-configuration"
      ]
      ++ lib.optional (dysnomiaFlags.enableApacheWebApplication) "apache-webapplication"
      ++ lib.optional (dysnomiaFlags.enableAxis2WebService) "axis2-webservice"
      ++ lib.optional (dysnomiaFlags.enableDockerContainer) "docker-container"
      ++ lib.optional (dysnomiaFlags.enableEjabberdDump) "ejabberd-dump"
      ++ lib.optional (dysnomiaFlags.enableInfluxDatabase) "influx-database"
      ++ lib.optional (dysnomiaFlags.enableMySQLDatabase) "mysql-database"
      ++ lib.optional (dysnomiaFlags.enablePostgreSQLDatabase) "postgresql-database"
      ++ lib.optional (dysnomiaFlags.enableTomcatWebApplication) "tomcat-webapplication"
      ++ lib.optional (dysnomiaFlags.enableMongoDatabase) "mongo-database"
      ++ lib.optional (dysnomiaFlags.enableSubversionRepository) "subversion-repository";
    };

    systemd.targets.dysnomia = {
      after = "final.target";
      description = "Services that are activated and deactivated by Dysnomia";
    };
  };
}
