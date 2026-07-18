{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.serviio;

  serviioStart = pkgs.writeScript "serviio.sh" ''
    #!${pkgs.bash}/bin/sh

    SERVIIO_HOME=${pkgs.serviio}

    # Setup the classpath
    SERVIIO_CLASS_PATH="$SERVIIO_HOME/lib/*:$SERVIIO_HOME/config"

    # Setup Serviio specific properties
    JAVA_OPTS="-Djava.net.preferIPv4Stack=true -Djava.awt.headless=true -Dorg.restlet.engine.loggerFacadeClass=org.restlet.ext.slf4j.Slf4jLoggerFacade
               -Dderby.system.home=${cfg.dataDir}/library -Dserviio.home=${cfg.dataDir} -Dffmpeg.location=${pkgs.ffmpeg}/bin/ffmpeg -Ddcraw.location=${pkgs.dcraw}/bin/dcraw"

    # Execute the JVM in the foreground
    exec ${pkgs.jre}/bin/java -Xmx512M -Xms20M -XX:+UseG1GC -XX:GCTimeRatio=1 -XX:MinHeapFreeRatio=10 -XX:MaxHeapFreeRatio=20 $JAVA_OPTS -classpath "$SERVIIO_CLASS_PATH" org.serviio.MediaServer "$@"
  '';

in
{

  ###### interface
  options = {
    services.serviio = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the Serviio Media Server.
        '';

        type = lib.types.bool;
      };

      dataDir = lib.mkOption {
        default = "/var/lib/serviio";

        description = ''
          The directory where serviio stores its state, data, etc.
        '';

        type = lib.types.path;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Open ports in the firewall for the Serviio Media Server.
        '';

        type = lib.types.bool;
      };

    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        8895 # serve UPnP responses
        23423 # console
        23424 # mediabrowser
      ];

      allowedUDPPorts = [
        1900 # UPnP service discovery
      ];
    };

    systemd.services.serviio = {
      after = [ "network.target" ];
      description = "Serviio Media Server";
      path = [ pkgs.serviio ];

      serviceConfig = {
        ExecStart = "${serviioStart}";
        ExecStop = "${serviioStart} -stop";
        Group = "serviio";
        User = "serviio";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.serviio = { };

    users.users.serviio = {
      createHome = true;
      description = "Serviio Media Server User";
      group = "serviio";
      home = cfg.dataDir;
      isSystemUser = true;
    };
  };
}
