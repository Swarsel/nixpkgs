{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.activemq;

  activemqBroker =
    pkgs.runCommand "activemq-broker"
      {
        nativeBuildInputs = [ pkgs.jdk ];
      }
      ''
        mkdir -p $out/lib
        source ${pkgs.activemq}/lib/classpath.env
        export CLASSPATH
        ln -s "${./ActiveMQBroker.java}" ActiveMQBroker.java
        javac -d $out/lib ActiveMQBroker.java
      '';

in
{

  options = {
    services.activemq = {
      enable = lib.mkOption {
        default = false;

        description = ''
          Enable the Apache ActiveMQ message broker service.
        '';

        type = lib.types.bool;
      };

      baseDir = lib.mkOption {
        default = "/var/activemq";

        description = ''
          The base directory where ActiveMQ stores its persistent data and logs.
          This will be overridden if you set "activemq.base" and "activemq.data"
          in the `javaProperties` option. You can also override
          this in activemq.xml.
        '';

        type = lib.types.str;
      };

      configurationDir = lib.mkOption {
        default = "${pkgs.activemq}/conf";
        defaultText = lib.literalExpression ''"''${pkgs.activemq}/conf"'';

        description = ''
          The base directory for ActiveMQ's configuration.
          By default, this directory is searched for a file named activemq.xml,
          which should contain the configuration for the broker service.
        '';

        type = lib.types.str;
      };

      configurationURI = lib.mkOption {
        default = "xbean:activemq.xml";

        description = ''
          The URI that is passed along to the BrokerFactory to
          set up the configuration of the ActiveMQ broker service.
          You should not need to change this. For custom configuration,
          set the `configurationDir` instead, and create
          an activemq.xml configuration file in it.
        '';

        type = lib.types.str;
      };

      extraJavaOptions = lib.mkOption {
        default = "";

        description = ''
          Add extra options here that you want to be sent to the
          Java runtime when the broker service is started.
        '';

        example = "-Xmx2G -Xms2G -XX:MaxPermSize=512M";
        type = lib.types.separatedString " ";
      };

      javaProperties = lib.mkOption {
        apply =
          attrs:
          {
            "activemq.base" = "${cfg.baseDir}";
            "activemq.conf" = "${cfg.configurationDir}";
            "activemq.data" = "${cfg.baseDir}/data";
            "activemq.home" = "${pkgs.activemq}";
          }
          // attrs;

        default = { };

        description = ''
          Specifies Java properties that are sent to the ActiveMQ
          broker service with the "-D" option. You can set properties
          here to change the behaviour and configuration of the broker.
          All essential properties that are not set here are automatically
          given reasonable defaults.
        '';

        example = lib.literalExpression ''
          {
            "java.net.preferIPv4Stack" = "true";
          }
        '';

        type = lib.types.attrs;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.activemq = {
      after = [ "network.target" ];
      path = [ pkgs.jre ];

      script = ''
        source ${pkgs.activemq}/lib/classpath.env
        export CLASSPATH=${activemqBroker}/lib:${cfg.configurationDir}:$CLASSPATH
        exec java \
          ${
            lib.concatStringsSep " \\\n" (
              lib.mapAttrsToList (name: value: "-D${name}=${value}") cfg.javaProperties
            )
          } \
          ${cfg.extraJavaOptions} ActiveMQBroker "${cfg.configurationURI}"
      '';

      serviceConfig.User = "activemq";
      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.activemq_init = {
      before = [ "activemq.service" ];
      partOf = [ "activemq.service" ];

      script = ''
        mkdir -p "${cfg.javaProperties."activemq.data"}"
        chown -R activemq "${cfg.javaProperties."activemq.data"}"
      '';

      serviceConfig.Type = "oneshot";
      wantedBy = [ "activemq.service" ];
    };

    users.groups.activemq.gid = config.ids.gids.activemq;

    users.users.activemq = {
      description = "ActiveMQ server user";
      group = "activemq";
      uid = config.ids.uids.activemq;
    };

  };

}
