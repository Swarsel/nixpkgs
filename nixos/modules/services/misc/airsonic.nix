{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.airsonic;
  opt = options.services.airsonic;
in
{
  options = {

    services.airsonic = {
      enable = lib.mkEnableOption "Airsonic, the Free and Open Source media streaming server (fork of Subsonic and Libresonic)";

      contextPath = lib.mkOption {
        default = "/";

        description = ''
          The context path, i.e., the last part of the Airsonic
          URL. Typically '/' or '/airsonic'. Default '/'
        '';

        type = lib.types.path;
      };

      home = lib.mkOption {
        default = "/var/lib/airsonic";

        description = ''
          The directory where Airsonic will create files.
          Make sure it is writable.
        '';

        type = lib.types.path;
      };

      jre = lib.mkPackageOption pkgs "jre8" {
        extraDescription = ''
          ::: {.note}
          Airsonic only supports Java 8, airsonic-advanced requires at least
          Java 11.
          :::
        '';
      };

      jvmOptions = lib.mkOption {
        default = [
        ];

        description = ''
          Extra command line options for the JVM running AirSonic.
          Useful for sending jukebox output to non-default alsa
          devices.
        '';

        example = [
          "-Djavax.sound.sampled.Clip='#CODEC [plughw:1,0]'"
          "-Djavax.sound.sampled.Port='#Port CODEC [hw:1]'"
          "-Djavax.sound.sampled.SourceDataLine='#CODEC [plughw:1,0]'"
          "-Djavax.sound.sampled.TargetDataLine='#CODEC [plughw:1,0]'"
        ];

        type = lib.types.listOf lib.types.str;
      };

      listenAddress = lib.mkOption {
        default = "127.0.0.1";

        description = ''
          The host name or IP address on which to bind Airsonic.
          The default value is appropriate for first launch, when the
          default credentials are easy to guess. It is also appropriate
          if you intend to use the virtualhost option in the service
          module. In other cases, you may want to change this to a
          specific IP or 0.0.0.0 to listen on all interfaces.
        '';

        type = lib.types.str;
      };

      maxMemory = lib.mkOption {
        default = 100;

        description = ''
          The memory limit (max Java heap size) in megabytes.
          Default: 100
        '';

        type = lib.types.int;
      };

      port = lib.mkOption {
        default = 4040;

        description = ''
          The port on which Airsonic will listen for
          incoming HTTP traffic. Set to 0 to disable.
        '';

        type = lib.types.port;
      };

      transcoders = lib.mkOption {
        default = [ "${pkgs.ffmpeg.bin}/bin/ffmpeg" ];
        defaultText = lib.literalExpression ''[ "''${pkgs.ffmpeg.bin}/bin/ffmpeg" ]'';

        description = ''
          List of paths to transcoder executables that should be accessible
          from Airsonic. Symlinks will be created to each executable inside
          ''${config.${opt.home}}/transcoders.
        '';

        type = lib.types.listOf lib.types.path;
      };

      user = lib.mkOption {
        default = "airsonic";
        description = "User account under which airsonic runs.";
        type = lib.types.str;
      };

      virtualHost = lib.mkOption {
        default = null;

        description = ''
          Name of the nginx virtualhost to use and setup. If null, do not setup any virtualhost.
        '';

        type = lib.types.nullOr lib.types.str;
      };

      war = lib.mkOption {
        default = "${pkgs.airsonic}/webapps/airsonic.war";
        defaultText = lib.literalExpression ''"''${pkgs.airsonic}/webapps/airsonic.war"'';
        description = "Airsonic war file to use.";
        type = lib.types.path;
      };

    };
  };

  config = lib.mkIf cfg.enable {
    services.nginx = lib.mkIf (cfg.virtualHost != null) {
      enable = true;
      recommendedProxySettings = true;

      virtualHosts.${cfg.virtualHost} = {
        locations.${cfg.contextPath}.proxyPass = "http://${cfg.listenAddress}:${toString cfg.port}";
      };
    };

    systemd.services.airsonic = {
      after = [ "network.target" ];
      description = "Airsonic Media Server";

      preStart = ''
        # Install transcoders.
        rm -rf ${cfg.home}/transcode
        mkdir -p ${cfg.home}/transcode
        for exe in ${toString cfg.transcoders}; do
          ln -sf "$exe" ${cfg.home}/transcode
        done
      '';

      serviceConfig = {
        ExecStart = ''
          ${cfg.jre}/bin/java -Xmx${toString cfg.maxMemory}m \
          -Dairsonic.home=${cfg.home} \
          -Dserver.address=${cfg.listenAddress} \
          -Dserver.port=${toString cfg.port} \
          -Dserver.context-path=${cfg.contextPath} \
          -Djava.awt.headless=true \
          ${lib.optionalString (cfg.virtualHost != null) "-Dserver.use-forward-headers=true"} \
          ${toString cfg.jvmOptions} \
          -verbose:gc \
          -jar ${cfg.war}
        '';

        Restart = "always";
        UMask = "0022";
        User = "airsonic";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.airsonic = { };

    users.users.airsonic = {
      createHome = true;
      description = "Airsonic service user";
      group = "airsonic";
      home = cfg.home;
      isSystemUser = true;
      name = cfg.user;
    };
  };
}
