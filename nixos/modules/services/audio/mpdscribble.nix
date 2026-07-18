{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.services.mpdscribble;
  mpdCfg = config.services.mpd;

  endpointUrls = {
    "jamendo" = "http://postaudioscrobbler.jamendo.com";
    "last.fm" = "http://post.audioscrobbler.com";
    "libre.fm" = "http://turtle.libre.fm";
    "listenbrainz" = "http://proxy.listenbrainz.org";
  };

  mkSection = secname: secCfg: ''
    [${secname}]
    url      = ${secCfg.url}
    username = ${secCfg.username}
    password = {{${secname}_PASSWORD}}
    journal  = /var/lib/mpdscribble/${secname}.journal
  '';

  endpoints = lib.concatStringsSep "\n" (lib.mapAttrsToList mkSection cfg.endpoints);
  cfgTemplate = pkgs.writeText "mpdscribble.conf" ''
    ## This file was automatically genenrated by NixOS and will be overwritten.
    ## Do not edit. Edit your NixOS configuration instead.

    ## mpdscribble - an audioscrobbler for the Music Player Daemon.
    ## http://mpd.wikia.com/wiki/Client:mpdscribble

    # HTTP proxy URL.
    ${lib.optionalString (cfg.proxy != null) "proxy = ${cfg.proxy}"}

    # The location of the mpdscribble log file.  The special value
    # "syslog" makes mpdscribble use the local syslog daemon.  On most
    # systems, log messages will appear in /var/log/daemon.log then.
    # "-" means log to stderr (the current terminal).
    log = -

    # How verbose mpdscribble's logging should be.  Default is 1.
    verbose = ${toString cfg.verbose}

    # How often should mpdscribble save the journal file? [seconds]
    journal_interval = ${toString cfg.journalInterval}

    # The host running MPD, possibly protected by a password
    # ([PASSWORD@]HOSTNAME).
    host = ${(lib.optionalString (cfg.passwordFile != null) "{{MPD_PASSWORD}}@") + cfg.host}

    # The port that the MPD listens on and mpdscribble should try to
    # connect to.
    port = ${toString cfg.port}

    ${endpoints}
  '';

  cfgFile = "/run/mpdscribble/mpdscribble.conf";

  replaceSecret =
    secretFile: placeholder: targetFile:
    lib.optionalString (
      secretFile != null
    ) "${pkgs.replace-secret}/bin/replace-secret '${placeholder}' '${secretFile}' '${targetFile}' ";

  preStart = pkgs.writeShellScript "mpdscribble-pre-start" ''
    cp -f "${cfgTemplate}" "${cfgFile}"
    ${replaceSecret cfg.passwordFile "{{MPD_PASSWORD}}" cfgFile}
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        secname: cfg: replaceSecret cfg.passwordFile "{{${secname}_PASSWORD}}" cfgFile
      ) cfg.endpoints
    )}
  '';

  localMpd = (cfg.host == "localhost" || cfg.host == "127.0.0.1");

in
{
  ###### interface

  options.services.mpdscribble = {

    enable = lib.mkEnableOption "mpdscribble, an MPD client which submits info about tracks being played to Last.fm (formerly AudioScrobbler)";

    endpoints = lib.mkOption {
      default = { };

      description = ''
        Endpoints to scrobble to.
        If the endpoint is one of "${lib.concatStringsSep "\", \"" (lib.attrNames endpointUrls)}" the url is set automatically.
      '';

      example = {
        "last.fm" = {
          passwordFile = "/run/secrets/lastfm_password";
          username = "foo";
        };
      };

      type = (
        let
          endpoint =
            { name, ... }:
            {
              options = {
                passwordFile = lib.mkOption {
                  description = "File containing the password, either as MD5SUM or cleartext.";
                  type = lib.types.nullOr lib.types.str;
                };

                url = lib.mkOption {
                  default = endpointUrls.${name} or "";
                  description = "The url endpoint where the scrobble API is listening.";
                  type = lib.types.str;
                };

                username = lib.mkOption {
                  description = ''
                    Username for the scrobble service.
                  '';

                  type = lib.types.str;
                };
              };
            };
        in
        lib.types.attrsOf (lib.types.submodule endpoint)
      );
    };

    host = lib.mkOption {
      default = (
        if mpdCfg.settings.bind_to_address != "any" then mpdCfg.settings.bind_to_address else "localhost"
      );

      defaultText = lib.literalExpression ''
        if config.services.mpd.settings.bind_to_address != "any"
        then config.services.mpd.settings.bind_to_address
        else "localhost"
      '';

      description = ''
        Host for the mpdscribble daemon to search for a mpd daemon on.
      '';

      type = lib.types.str;
    };

    journalInterval = lib.mkOption {
      default = 600;

      description = ''
        How often should mpdscribble save the journal file? [seconds]
      '';

      example = 60;
      type = lib.types.int;
    };

    passwordFile = lib.mkOption {
      default =
        if localMpd then
          (lib.findFirst (c: lib.elem "read" c.permissions) {
            passwordFile = null;
          } mpdCfg.credentials).passwordFile
        else
          null;

      defaultText = lib.literalMD ''
        The first password file with read access configured for MPD when using a local instance,
        otherwise `null`.
      '';

      description = ''
        File containing the password for the mpd daemon.
        If there is a local mpd configured using {option}`services.mpd.credentials`
        the default is automatically set to a matching passwordFile of the local mpd.
      '';

      type = lib.types.nullOr lib.types.str;
    };

    port = lib.mkOption {
      default = mpdCfg.settings.port;
      defaultText = lib.literalExpression "config.services.mpd.settings.port";

      description = ''
        Port for the mpdscribble daemon to search for a mpd daemon on.
      '';

      type = lib.types.port;
    };

    proxy = lib.mkOption {
      default = null;

      description = ''
        HTTP proxy URL.
      '';

      type = lib.types.nullOr lib.types.str;
    };

    verbose = lib.mkOption {
      default = 1;

      description = ''
        Log level for the mpdscribble daemon.
      '';

      type = lib.types.int;
    };

  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    systemd.services.mpdscribble = {
      after = [ "network.target" ] ++ (lib.optional localMpd "mpd.service");
      description = "mpdscribble mpd scrobble client";

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.mpdscribble}/bin/mpdscribble --no-daemon --conf ${cfgFile}";
        # TODO use LoadCredential= instead of running preStart with full privileges?
        ExecStartPre = "+${preStart}";
        RuntimeDirectory = "mpdscribble";
        RuntimeDirectoryMode = "700";
        StateDirectory = "mpdscribble";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

}
