{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.subsonic;
  opt = options.services.subsonic;
in
{
  options = {
    services.subsonic = {
      enable = lib.mkEnableOption "Subsonic daemon";

      contextPath = lib.mkOption {
        default = "/";

        description = ''
          The context path, i.e., the last part of the Subsonic
          URL. Typically '/' or '/subsonic'. Default '/'
        '';

        type = lib.types.path;
      };

      defaultMusicFolder = lib.mkOption {
        default = "/var/music";

        description = ''
          Configure Subsonic to use this folder for music.  This option
          only has effect the first time Subsonic is started.
        '';

        type = lib.types.path;
      };

      defaultPlaylistFolder = lib.mkOption {
        default = "/var/playlists";

        description = ''
          Configure Subsonic to use this folder for playlists.  This option
          only has effect the first time Subsonic is started.
        '';

        type = lib.types.path;
      };

      defaultPodcastFolder = lib.mkOption {
        default = "/var/music/Podcast";

        description = ''
          Configure Subsonic to use this folder for Podcasts.  This option
          only has effect the first time Subsonic is started.
        '';

        type = lib.types.path;
      };

      home = lib.mkOption {
        default = "/var/lib/subsonic";

        description = ''
          The directory where Subsonic will create files.
          Make sure it is writable.
        '';

        type = lib.types.path;
      };

      httpsPort = lib.mkOption {
        default = 0;

        description = ''
          The port on which Subsonic will listen for
          incoming HTTPS traffic. Set to 0 to disable.
        '';

        type = lib.types.port;
      };

      listenAddress = lib.mkOption {
        default = "0.0.0.0";

        description = ''
          The host name or IP address on which to bind Subsonic.
          Only relevant if you have multiple network interfaces and want
          to make Subsonic available on only one of them. The default value
          will bind Subsonic to all available network interfaces.
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
          The port on which Subsonic will listen for
          incoming HTTP traffic. Set to 0 to disable.
        '';

        type = lib.types.port;
      };

      transcoders = lib.mkOption {
        default = [ "${pkgs.ffmpeg.bin}/bin/ffmpeg" ];
        defaultText = lib.literalExpression ''[ "''${pkgs.ffmpeg.bin}/bin/ffmpeg" ]'';

        description = ''
          List of paths to transcoder executables that should be accessible
          from Subsonic. Symlinks will be created to each executable inside
          ''${config.${opt.home}}/transcoders.
        '';

        type = lib.types.listOf lib.types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.subsonic = {
      after = [ "network.target" ];
      description = "Personal media streamer";

      preStart = ''
        # Formerly this module set cfg.home to /var/subsonic. Try to move
        # /var/subsonic to cfg.home.
        oldHome="/var/subsonic"
        if [ "${cfg.home}" != "$oldHome" ] &&
                ! [ -e "${cfg.home}" ] &&
                [ -d "$oldHome" ] &&
                [ $(${pkgs.coreutils}/bin/stat -c %u "$oldHome") -eq \
                    ${toString config.users.users.subsonic.uid} ]; then
            logger Moving "$oldHome" to "${cfg.home}"
            ${pkgs.coreutils}/bin/mv -T "$oldHome" "${cfg.home}"
        fi

        # Install transcoders.
        ${pkgs.coreutils}/bin/rm -rf ${cfg.home}/transcode ; \
        ${pkgs.coreutils}/bin/mkdir -p ${cfg.home}/transcode ; \
        ${pkgs.bash}/bin/bash -c ' \
          for exe in "$@"; do \
            ${pkgs.coreutils}/bin/ln -sf "$exe" ${cfg.home}/transcode; \
          done' IGNORED_FIRST_ARG ${toString cfg.transcoders}
      '';

      script = ''
        ${pkgs.jre8}/bin/java -Xmx${toString cfg.maxMemory}m \
          -Dsubsonic.home=${cfg.home} \
          -Dsubsonic.host=${cfg.listenAddress} \
          -Dsubsonic.port=${toString cfg.port} \
          -Dsubsonic.httpsPort=${toString cfg.httpsPort} \
          -Dsubsonic.contextPath=${cfg.contextPath} \
          -Dsubsonic.defaultMusicFolder=${cfg.defaultMusicFolder} \
          -Dsubsonic.defaultPodcastFolder=${cfg.defaultPodcastFolder} \
          -Dsubsonic.defaultPlaylistFolder=${cfg.defaultPlaylistFolder} \
          -Djava.awt.headless=true \
          -verbose:gc \
          -jar ${pkgs.subsonic}/subsonic-booter-jar-with-dependencies.jar
      '';

      serviceConfig = {
        Restart = "always";
        UMask = "0022";
        User = "subsonic";
        # Needed for Subsonic to find subsonic.war.
        WorkingDirectory = "${pkgs.subsonic}";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.subsonic.gid = config.ids.gids.subsonic;

    users.users.subsonic = {
      createHome = true;
      description = "Subsonic daemon user";
      group = "subsonic";
      home = cfg.home;
      uid = config.ids.uids.subsonic;
    };
  };
}
