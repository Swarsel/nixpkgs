{
  config,
  lib,
  pkgs,
  ...
}:

let

  cfg = config.services.tomcat;
  tomcat = cfg.package;
in

{
  ###### interface
  options = {
    services.tomcat = {
      enable = lib.mkEnableOption "Apache Tomcat";

      package = lib.mkPackageOption pkgs "tomcat9" {
        example = "tomcat10";
      };

      axis2 = {
        enable = lib.mkEnableOption "Apache Axis2 container";

        services = lib.mkOption {
          default = [ ];
          description = "List containing AAR files or directories with AAR files which are web services to be deployed on Axis2";
          type = lib.types.listOf lib.types.str;
        };
      };

      baseDir = lib.mkOption {
        default = "/var/tomcat";

        description = ''
          Location where Tomcat stores configuration files, web applications
          and logfiles. Note that it is partially cleared on each service startup
          if `purifyOnStart` is enabled.
        '';

        type = lib.types.path;
      };

      catalinaOpts = lib.mkOption {
        default = "";
        description = "Parameters to pass to the Java Virtual Machine which spawns the Catalina servlet container";
        type = lib.types.either (lib.types.listOf lib.types.str) lib.types.str;
      };

      commonLibs = lib.mkOption {
        default = [ ];
        description = "List containing JAR files or directories with JAR files which are libraries shared by the web applications and the servlet container";
        type = lib.types.listOf lib.types.str;
      };

      extraConfigFiles = lib.mkOption {
        default = [ ];
        description = "Extra configuration files to pull into the tomcat conf directory";
        type = lib.types.listOf lib.types.path;
      };

      extraEnvironment = lib.mkOption {
        default = [ ];
        description = "Environment Variables to pass to the tomcat service";
        example = [ "ENVIRONMENT=production" ];
        type = lib.types.listOf lib.types.str;
      };

      extraGroups = lib.mkOption {
        default = [ ];
        description = "Defines extra groups to which the tomcat user belongs.";
        example = [ "users" ];
        type = lib.types.listOf lib.types.str;
      };

      group = lib.mkOption {
        default = "tomcat";
        description = "Group account under which Apache Tomcat runs.";
        type = lib.types.str;
      };

      javaOpts = lib.mkOption {
        default = "";
        description = "Parameters to pass to the Java Virtual Machine which spawns Apache Tomcat";
        type = lib.types.either (lib.types.listOf lib.types.str) lib.types.str;
      };

      jdk = lib.mkPackageOption pkgs "jdk" { };

      logDirs = lib.mkOption {
        default = [ ];
        description = "Directories to create in baseDir/logs/";
        type = lib.types.listOf lib.types.path;
      };

      logPerVirtualHost = lib.mkOption {
        default = false;
        description = "Whether to enable logging per virtual host.";
        type = lib.types.bool;
      };

      port = lib.mkOption {
        default = 8080;

        description = ''
          The TCP port Tomcat should listen on.
        '';

        type = lib.types.port;
      };

      purifyOnStart = lib.mkOption {
        default = false;

        description = ''
          On startup, the `baseDir` directory is populated with various files,
          subdirectories and symlinks. If this option is enabled, these items
          (except for the `logs` and `work` subdirectories) are first removed.
          This prevents interference from remainders of an old configuration
          (libraries, webapps, etc.), so it's recommended to enable this option.
        '';

        type = lib.types.bool;
      };

      serverXml = lib.mkOption {
        default = "";

        description = ''
          Verbatim server.xml configuration.
          This is mutually exclusive with the virtualHosts options.
        '';

        type = lib.types.lines;
      };

      sharedLibs = lib.mkOption {
        default = [ ];
        description = "List containing JAR files or directories with JAR files which are libraries shared by the web applications";
        type = lib.types.listOf lib.types.str;
      };

      user = lib.mkOption {
        default = "tomcat";
        description = "User account under which Apache Tomcat runs.";
        type = lib.types.str;
      };

      virtualHosts = lib.mkOption {
        default = [ ];
        description = "List consisting of a virtual host name and a list of web applications to deploy on each virtual host";

        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              aliases = lib.mkOption {
                default = [ ];
                description = "aliases of the virtualhost";
                type = lib.types.listOf lib.types.str;
              };

              name = lib.mkOption {
                description = "name of the virtualhost";
                type = lib.types.str;
              };

              webapps = lib.mkOption {
                default = [ ];

                description = ''
                  List containing web application WAR files and/or directories containing
                  web applications and configuration files for the virtual host.
                '';

                type = lib.types.listOf lib.types.path;
              };
            };
          }
        );
      };

      webapps = lib.mkOption {
        default = [ tomcat.webapps ];
        defaultText = lib.literalExpression "[ config.services.tomcat.package.webapps ]";
        description = "List containing WAR files or directories with WAR files which are web applications to be deployed on Tomcat";
        type = lib.types.listOf lib.types.path;
      };
    };
  };

  ###### implementation
  config = lib.mkIf config.services.tomcat.enable {

    systemd.services.tomcat = {
      after = [ "network.target" ];
      description = "Apache Tomcat server";

      preStart = ''
        ${lib.optionalString cfg.purifyOnStart ''
          # Delete most directories/symlinks we create from the existing base directory,
          # to get rid of remainders of an old configuration.
          # The list of directories to delete is taken from the "mkdir" command below,
          # excluding "logs" (because logs are valuable) and "work" (because normally
          # session files are there), and additionally including "bin".
          rm -rf ${cfg.baseDir}/{conf,virtualhosts,temp,lib,shared/lib,webapps,bin}
        ''}

        # Create the base directory
        mkdir -p \
          ${cfg.baseDir}/{conf,virtualhosts,logs,temp,lib,shared/lib,webapps,work}
        chown ${cfg.user}:${cfg.group} \
          ${cfg.baseDir}/{conf,virtualhosts,logs,temp,lib,shared/lib,webapps,work}

        # Create a symlink to the bin directory of the tomcat component
        ln -sfn ${tomcat}/bin ${cfg.baseDir}/bin

        # Symlink the config files in the conf/ directory (except for catalina.properties and server.xml)
        for i in $(ls ${tomcat}/conf | grep -v catalina.properties | grep -v server.xml); do
          ln -sfn ${tomcat}/conf/$i ${cfg.baseDir}/conf/`basename $i`
        done

        ${lib.optionalString (cfg.extraConfigFiles != [ ]) ''
          for i in ${toString cfg.extraConfigFiles}; do
            ln -sfn $i ${cfg.baseDir}/conf/`basename $i`
          done
        ''}

        # Create a modified catalina.properties file
        # Change all references from CATALINA_HOME to CATALINA_BASE and add support for shared libraries
        sed -e 's|''${catalina.home}|''${catalina.base}|g' \
          -e 's|shared.loader=|shared.loader=''${catalina.base}/shared/lib/*.jar|' \
          ${tomcat}/conf/catalina.properties > ${cfg.baseDir}/conf/catalina.properties

        ${
          if cfg.serverXml != "" then
            ''
              cp -f ${pkgs.writeTextDir "server.xml" cfg.serverXml}/* ${cfg.baseDir}/conf/
            ''
          else
            let
              hostElementForVirtualHost =
                virtualHost:
                ''
                  <Host name="${virtualHost.name}" appBase="virtualhosts/${virtualHost.name}/webapps"
                        unpackWARs="true" autoDeploy="true" xmlValidation="false" xmlNamespaceAware="false">
                ''
                + lib.concatStrings (innerElementsForVirtualHost virtualHost)
                + ''
                  </Host>
                '';
              innerElementsForVirtualHost =
                virtualHost:
                (map (alias: ''
                  <Alias>${alias}</Alias>
                '') virtualHost.aliases)
                ++ (lib.optional cfg.logPerVirtualHost ''
                  <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs/${virtualHost.name}"
                         prefix="${virtualHost.name}_access_log." pattern="combined" resolveHosts="false"/>
                '');
              hostElementsString = lib.concatMapStringsSep "\n" hostElementForVirtualHost cfg.virtualHosts;
              hostElementsSedString = lib.replaceStrings [ "\n" ] [ "\\\n" ] hostElementsString;
            in
            ''
              # Create a modified server.xml which listens on the given port,
              # and also includes all virtual hosts.
              # The host modification must be last here,
              # else if hostElementsSedString is empty sed gets confused as to what to append
              sed -e 's/<Connector port="8080"/<Connector port="${toString cfg.port}"/' \
                  -e "/<Engine name=\"Catalina\" defaultHost=\"localhost\">/a\\"${lib.escapeShellArg hostElementsSedString} \
                    ${tomcat}/conf/server.xml > ${cfg.baseDir}/conf/server.xml
            ''
        }
        ${lib.optionalString (cfg.logDirs != [ ]) ''
          for i in ${toString cfg.logDirs}; do
            mkdir -p ${cfg.baseDir}/logs/$i
            chown ${cfg.user}:${cfg.group} ${cfg.baseDir}/logs/$i
          done
        ''}
        ${lib.optionalString cfg.logPerVirtualHost (
          toString (
            map (h: ''
              mkdir -p ${cfg.baseDir}/logs/${h.name}
              chown ${cfg.user}:${cfg.group} ${cfg.baseDir}/logs/${h.name}
            '') cfg.virtualHosts
          )
        )}

        # Symlink all the given common libs files or paths into the lib/ directory
        for i in ${tomcat} ${toString cfg.commonLibs}; do
          if [ -f $i ]; then
            # If the given web application is a file, symlink it into the common/lib/ directory
            ln -sfn $i ${cfg.baseDir}/lib/`basename $i`
          elif [ -d $i ]; then
            # If the given web application is a directory, then iterate over the files
            # in the special purpose directories and symlink them into the tomcat tree

            for j in $i/lib/*; do
              ln -sfn $j ${cfg.baseDir}/lib/`basename $j`
            done
          fi
        done

        # Symlink all the given shared libs files or paths into the shared/lib/ directory
        for i in ${toString cfg.sharedLibs}; do
          if [ -f $i ]; then
            # If the given web application is a file, symlink it into the common/lib/ directory
            ln -sfn $i ${cfg.baseDir}/shared/lib/`basename $i`
          elif [ -d $i ]; then
            # If the given web application is a directory, then iterate over the files
            # in the special purpose directories and symlink them into the tomcat tree

            for j in $i/shared/lib/*; do
              ln -sfn $j ${cfg.baseDir}/shared/lib/`basename $j`
            done
          fi
        done

        # Symlink all the given web applications files or paths into the webapps/ directory
        for i in ${toString cfg.webapps}; do
          if [ -f $i ]; then
            # If the given web application is a file, symlink it into the webapps/ directory
            ln -sfn $i ${cfg.baseDir}/webapps/`basename $i`
          elif [ -d $i ]; then
            # If the given web application is a directory, then iterate over the files
            # in the special purpose directories and symlink them into the tomcat tree

            for j in $i/webapps/*; do
              ln -sfn $j ${cfg.baseDir}/webapps/`basename $j`
            done

            # Also symlink the configuration files if they are included
            if [ -d $i/conf/Catalina ]; then
              for j in $i/conf/Catalina/*; do
                mkdir -p ${cfg.baseDir}/conf/Catalina/localhost
                ln -sfn $j ${cfg.baseDir}/conf/Catalina/localhost/`basename $j`
              done
            fi
          fi
        done

        ${toString (
          map (virtualHost: ''
            # Create webapps directory for the virtual host
            mkdir -p ${cfg.baseDir}/virtualhosts/${virtualHost.name}/webapps

            # Modify ownership
            chown ${cfg.user}:${cfg.group} ${cfg.baseDir}/virtualhosts/${virtualHost.name}/webapps

            # Symlink all the given web applications files or paths into the webapps/ directory
            # of this virtual host
            for i in "${lib.optionalString (virtualHost ? webapps) (toString virtualHost.webapps)}"; do
              if [ -f $i ]; then
                # If the given web application is a file, symlink it into the webapps/ directory
                ln -sfn $i ${cfg.baseDir}/virtualhosts/${virtualHost.name}/webapps/`basename $i`
              elif [ -d $i ]; then
                # If the given web application is a directory, then iterate over the files
                # in the special purpose directories and symlink them into the tomcat tree

                for j in $i/webapps/*; do
                  ln -sfn $j ${cfg.baseDir}/virtualhosts/${virtualHost.name}/webapps/`basename $j`
                done

                # Also symlink the configuration files if they are included
                if [ -d $i/conf/Catalina ]; then
                  for j in $i/conf/Catalina/*; do
                    mkdir -p ${cfg.baseDir}/conf/Catalina/${virtualHost.name}
                    ln -sfn $j ${cfg.baseDir}/conf/Catalina/${virtualHost.name}/`basename $j`
                  done
                fi
              fi
            done
          '') cfg.virtualHosts
        )}

        ${lib.optionalString cfg.axis2.enable ''
          # Copy the Axis2 web application
          cp -av ${pkgs.axis2}/webapps/axis2 ${cfg.baseDir}/webapps

          # Turn off addressing, which causes many errors
          sed -i -e 's%<module ref="addressing"/>%<!-- <module ref="addressing"/> -->%' ${cfg.baseDir}/webapps/axis2/WEB-INF/conf/axis2.xml

          # Modify permissions on the Axis2 application
          chown -R ${cfg.user}:${cfg.group} ${cfg.baseDir}/webapps/axis2

          # Symlink all the given web service files or paths into the webapps/axis2/WEB-INF/services directory
          for i in ${toString cfg.axis2.services}; do
            if [ -f $i ]; then
              # If the given web service is a file, symlink it into the webapps/axis2/WEB-INF/services
              ln -sfn $i ${cfg.baseDir}/webapps/axis2/WEB-INF/services/`basename $i`
            elif [ -d $i ]; then
              # If the given web application is a directory, then iterate over the files
              # in the special purpose directories and symlink them into the tomcat tree

              for j in $i/webapps/axis2/WEB-INF/services/*; do
                ln -sfn $j ${cfg.baseDir}/webapps/axis2/WEB-INF/services/`basename $j`
              done

              # Also symlink the configuration files if they are included
              if [ -d $i/conf/Catalina ]; then
                for j in $i/conf/Catalina/*; do
                  ln -sfn $j ${cfg.baseDir}/conf/Catalina/localhost/`basename $j`
                done
              fi
            fi
          done
        ''}
      '';

      serviceConfig = {
        Environment = [
          "CATALINA_BASE=${cfg.baseDir}"
          "CATALINA_PID=/run/tomcat/tomcat.pid"
          "JAVA_HOME='${cfg.jdk}'"
          "JAVA_OPTS='${toString cfg.javaOpts}'"
          "CATALINA_OPTS='${toString cfg.catalinaOpts}'"
        ]
        ++ cfg.extraEnvironment;

        ExecStart = "${tomcat}/bin/startup.sh";
        ExecStop = "${tomcat}/bin/shutdown.sh";
        PIDFile = "/run/tomcat/tomcat.pid";
        PermissionsStartOnly = true;
        RuntimeDirectory = "tomcat";
        Type = "forking";
        User = cfg.user;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.tomcat.gid = config.ids.gids.tomcat;

    users.users.tomcat = {
      description = "Tomcat user";
      extraGroups = cfg.extraGroups;
      group = "tomcat";
      home = "/homeless-shelter";
      uid = config.ids.uids.tomcat;
    };
  };

  meta = {
    maintainers = with lib.maintainers; [
      anthonyroussel
    ];
  };
}
