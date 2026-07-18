{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let

  gid = config.ids.gids.mediatomb;
  cfg = config.services.mediatomb;
  opt = options.services.mediatomb;
  name = cfg.package.pname;
  pkg = cfg.package;
  # configuration on media directory
  mediaDirectory = {
    options = {
      hidden-files = lib.mkOption {
        default = true;
        description = "Whether to index the hidden files or not.";
        type = lib.types.bool;
      };

      path = lib.mkOption {
        description = ''
          Absolute directory path to the media directory to index.
        '';

        type = lib.types.str;
      };

      recursive = lib.mkOption {
        default = false;
        description = "Whether the indexation must take place recursively or not.";
        type = lib.types.bool;
      };
    };
  };
  toMediaDirectory =
    d:
    "<directory location=\"${d.path}\" mode=\"inotify\" recursive=\"${lib.boolToYesNo d.recursive}\" hidden-files=\"${lib.boolToYesNo d.hidden-files}\" />\n";

  transcodingConfig =
    if cfg.transcoding then
      with pkgs;
      ''
        <transcoding enabled="yes">
          <mimetype-profile-mappings>
            <transcode mimetype="video/x-flv" using="vlcmpeg" />
            <transcode mimetype="application/ogg" using="vlcmpeg" />
            <transcode mimetype="audio/ogg" using="ogg2mp3" />
          </mimetype-profile-mappings>
          <profiles>
            <profile name="ogg2mp3" enabled="no" type="external">
              <mimetype>audio/mpeg</mimetype>
              <accept-url>no</accept-url>
              <first-resource>yes</first-resource>
              <accept-ogg-theora>no</accept-ogg-theora>
              <agent command="${ffmpeg}/bin/ffmpeg" arguments="-y -i %in -f mp3 %out" />
              <buffer size="1048576" chunk-size="131072" fill-size="262144" />
            </profile>
            <profile name="vlcmpeg" enabled="no" type="external">
              <mimetype>video/mpeg</mimetype>
              <accept-url>yes</accept-url>
              <first-resource>yes</first-resource>
              <accept-ogg-theora>yes</accept-ogg-theora>
              <agent command="${lib.getExe vlc}"
                arguments="-I dummy %in --sout #transcode{venc=ffmpeg,vcodec=mp2v,vb=4096,fps=25,aenc=ffmpeg,acodec=mpga,ab=192,samplerate=44100,channels=2}:standard{access=file,mux=ps,dst=%out} vlc:quit" />
              <buffer size="14400000" chunk-size="512000" fill-size="120000" />
            </profile>
          </profiles>
        </transcoding>
      ''
    else
      ''
        <transcoding enabled="no">
        </transcoding>
      '';

  configText = lib.optionalString (!cfg.customCfg) ''
    <?xml version="1.0" encoding="UTF-8"?>
    <config version="2" xmlns="http://mediatomb.cc/config/2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://mediatomb.cc/config/2 http://mediatomb.cc/config/2.xsd">
        <server>
          <ui enabled="yes" show-tooltips="yes">
            <accounts enabled="no" session-timeout="30">
              <account user="${name}" password="${name}"/>
            </accounts>
          </ui>
          <name>${cfg.serverName}</name>
          <udn>uuid:${cfg.uuid}</udn>
          <home>${cfg.dataDir}</home>
          <interface>${cfg.interface}</interface>
          <webroot>${pkg}/share/${name}/web</webroot>
          <pc-directory upnp-hide="${lib.boolToYesNo cfg.pcDirectoryHide}"/>
          <storage>
            <sqlite3 enabled="yes">
              <database-file>${name}.db</database-file>
            </sqlite3>
          </storage>
          <protocolInfo extend="${lib.boolToYesNo cfg.ps3Support}"/>
          ${lib.optionalString cfg.dsmSupport ''
            <custom-http-headers>
              <add header="X-User-Agent: redsonic"/>
            </custom-http-headers>

            <manufacturerURL>redsonic.com</manufacturerURL>
            <modelNumber>105</modelNumber>
          ''}
            ${lib.optionalString cfg.tg100Support ''
              <upnp-string-limit>101</upnp-string-limit>
            ''}
          <extended-runtime-options>
            <mark-played-items enabled="yes" suppress-cds-updates="yes">
              <string mode="prepend">*</string>
              <mark>
                <content>video</content>
              </mark>
            </mark-played-items>
          </extended-runtime-options>
        </server>
        <import hidden-files="no">
          <autoscan use-inotify="auto">
          ${lib.concatMapStrings toMediaDirectory cfg.mediaDirectories}
          </autoscan>
          <scripting script-charset="UTF-8">
            <common-script>${pkg}/share/${name}/js/common.js</common-script>
            <playlist-script>${pkg}/share/${name}/js/playlists.js</playlist-script>
            <virtual-layout type="builtin">
              <import-script>${pkg}/share/${name}/js/import.js</import-script>
            </virtual-layout>
          </scripting>
          <mappings>
            <extension-mimetype ignore-unknown="no">
              <map from="mp3" to="audio/mpeg"/>
              <map from="ogx" to="application/ogg"/>
              <map from="ogv" to="video/ogg"/>
              <map from="oga" to="audio/ogg"/>
              <map from="ogg" to="audio/ogg"/>
              <map from="ogm" to="video/ogg"/>
              <map from="asf" to="video/x-ms-asf"/>
              <map from="asx" to="video/x-ms-asf"/>
              <map from="wma" to="audio/x-ms-wma"/>
              <map from="wax" to="audio/x-ms-wax"/>
              <map from="wmv" to="video/x-ms-wmv"/>
              <map from="wvx" to="video/x-ms-wvx"/>
              <map from="wm" to="video/x-ms-wm"/>
              <map from="wmx" to="video/x-ms-wmx"/>
              <map from="m3u" to="audio/x-mpegurl"/>
              <map from="pls" to="audio/x-scpls"/>
              <map from="flv" to="video/x-flv"/>
              <map from="mkv" to="video/x-matroska"/>
              <map from="mka" to="audio/x-matroska"/>
              ${lib.optionalString cfg.ps3Support ''
                <map from="avi" to="video/divx"/>
              ''}
              ${lib.optionalString cfg.dsmSupport ''
                <map from="avi" to="video/avi"/>
              ''}
            </extension-mimetype>
            <mimetype-upnpclass>
              <map from="audio/*" to="object.item.audioItem.musicTrack"/>
              <map from="video/*" to="object.item.videoItem"/>
              <map from="image/*" to="object.item.imageItem"/>
            </mimetype-upnpclass>
            <mimetype-contenttype>
              <treat mimetype="audio/mpeg" as="mp3"/>
              <treat mimetype="application/ogg" as="ogg"/>
              <treat mimetype="audio/ogg" as="ogg"/>
              <treat mimetype="audio/x-flac" as="flac"/>
              <treat mimetype="audio/x-ms-wma" as="wma"/>
              <treat mimetype="audio/x-wavpack" as="wv"/>
              <treat mimetype="image/jpeg" as="jpg"/>
              <treat mimetype="audio/x-mpegurl" as="playlist"/>
              <treat mimetype="audio/x-scpls" as="playlist"/>
              <treat mimetype="audio/x-wav" as="pcm"/>
              <treat mimetype="audio/L16" as="pcm"/>
              <treat mimetype="video/x-msvideo" as="avi"/>
              <treat mimetype="video/mp4" as="mp4"/>
              <treat mimetype="audio/mp4" as="mp4"/>
              <treat mimetype="application/x-iso9660" as="dvd"/>
              <treat mimetype="application/x-iso9660-image" as="dvd"/>
            </mimetype-contenttype>
          </mappings>
          <online-content>
            <YouTube enabled="no" refresh="28800" update-at-start="no" purge-after="604800" racy-content="exclude" format="mp4" hd="no">
              <favorites user="${name}"/>
              <standardfeed feed="most_viewed" time-range="today"/>
              <playlists user="${name}"/>
              <uploads user="${name}"/>
              <standardfeed feed="recently_featured" time-range="today"/>
            </YouTube>
          </online-content>
        </import>
        ${transcodingConfig}
      </config>
  '';
  defaultFirewallRules = {
    allowedTCPPorts = [ cfg.port ];

    # udp 1900 port needs to be opened for SSDP (not configurable within
    # mediatomb/gerbera) cf.
    # https://docs.gerbera.io/en/latest/run.html?highlight=udp%20port#network-setup
    allowedUDPPorts = [
      1900
      cfg.port
    ];
  };

in
{

  ###### interface

  options = {

    services.mediatomb = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the Gerbera/Mediatomb DLNA server.
        '';

        type = lib.types.bool;
      };

      package = lib.mkPackageOption pkgs "gerbera" { };

      customCfg = lib.mkOption {
        default = false;

        description = ''
          Allow the service to create and use its own config file inside the `dataDir` as
          configured by {option}`services.mediatomb.dataDir`.
          Deactivated by default, the service then runs with the configuration generated from this module.
          Otherwise, when enabled, no service configuration is generated. Gerbera/Mediatomb then starts using
          config.xml within the configured `dataDir`. It's up to the user to make a correct
          configuration file.
        '';

        type = lib.types.bool;
      };

      dataDir = lib.mkOption {
        default = "/var/lib/${name}";
        defaultText = lib.literalExpression ''"/var/lib/''${config.${opt.package}.pname}"'';

        description = ''
          The directory where Gerbera/Mediatomb stores its state, data, etc.
        '';

        type = lib.types.path;
      };

      dsmSupport = lib.mkOption {
        default = false;

        description = ''
          Whether to enable D-Link DSM 320 specific tweaks.
          WARNING: incompatible with ps3 support.
        '';

        type = lib.types.bool;
      };

      group = lib.mkOption {
        default = "mediatomb";
        description = "Group account under which the service runs.";
        type = lib.types.str;
      };

      interface = lib.mkOption {
        default = "";

        description = ''
          A specific interface to bind to.
        '';

        type = lib.types.str;
      };

      mediaDirectories = lib.mkOption {
        default = [ ];

        description = ''
          Declare media directories to index.
        '';

        example = [
          {
            hidden-files = false;
            path = "/data/pictures";
            recursive = false;
          }
          {
            hidden-files = false;
            path = "/data/audio";
            recursive = true;
          }
        ];

        type = with lib.types; listOf (submodule mediaDirectory);
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          If false (the default), this is up to the user to declare the firewall rules.
          If true, this opens port 1900 (tcp and udp) and the port specified by
          {option}`sercvices.mediatomb.port`.

          If the option {option}`services.mediatomb.interface` is set,
          the firewall rules opened are dedicated to that interface. Otherwise,
          those rules are opened globally.
        '';

        type = lib.types.bool;
      };

      pcDirectoryHide = lib.mkOption {
        default = true;

        description = ''
          Whether to list the top-level directory or not (from upnp client standpoint).
        '';

        type = lib.types.bool;
      };

      port = lib.mkOption {
        default = 49152;

        description = ''
          The network port to listen on.
        '';

        type = lib.types.port;
      };

      ps3Support = lib.mkOption {
        default = false;

        description = ''
          Whether to enable ps3 specific tweaks.
          WARNING: incompatible with DSM 320 support.
        '';

        type = lib.types.bool;
      };

      serverName = lib.mkOption {
        default = "Gerbera (Mediatomb)";

        description = ''
          How to identify the server on the network.
        '';

        type = lib.types.str;
      };

      tg100Support = lib.mkOption {
        default = false;

        description = ''
          Whether to enable Telegent TG100 specific tweaks.
        '';

        type = lib.types.bool;
      };

      transcoding = lib.mkOption {
        default = false;

        description = ''
          Whether to enable transcoding.
        '';

        type = lib.types.bool;
      };

      user = lib.mkOption {
        default = "mediatomb";
        description = "User account under which the service runs.";
        type = lib.types.str;
      };

      uuid = lib.mkOption {
        default = "fdfc8a4e-a3ad-4c1d-b43d-a2eedb03a687";

        description = ''
          A unique (on your network) to identify the server by.
        '';

        type = lib.types.str;
      };

    };
  };

  ###### implementation

  config =
    let
      binaryCommand = "${pkg}/bin/${name}";
      interfaceFlag = lib.optionalString (cfg.interface != "") "--interface ${cfg.interface}";
      configFlag = lib.optionalString (
        !cfg.customCfg
      ) "--config ${pkgs.writeText "config.xml" configText}";
    in
    lib.mkIf cfg.enable {
      # Open firewall only if users enable it
      networking.firewall = lib.mkMerge [
        (lib.mkIf (cfg.openFirewall && cfg.interface != "") {
          interfaces."${cfg.interface}" = defaultFirewallRules;
        })
        (lib.mkIf (cfg.openFirewall && cfg.interface == "") defaultFirewallRules)
      ];

      systemd.services.mediatomb = {
        after = [
          "network.target"
          "network-online.target"
        ];

        description = "${cfg.serverName} media Server";
        serviceConfig.ExecStart = "${binaryCommand} --port ${toString cfg.port} ${interfaceFlag} ${configFlag} --home ${cfg.dataDir}";
        serviceConfig.Group = cfg.group;
        serviceConfig.User = cfg.user;
        wantedBy = [ "multi-user.target" ];
        # Gerbera might fail if the network interface is not available on startup
        # https://github.com/gerbera/gerbera/issues/1324
        wants = [ "network-online.target" ];
      };

      users.groups = lib.optionalAttrs (cfg.group == "mediatomb") {
        mediatomb.gid = gid;
      };

      users.users = lib.optionalAttrs (cfg.user == "mediatomb") {
        mediatomb = {
          createHome = true;
          description = "${name} DLNA Server User";
          group = cfg.group;
          home = cfg.dataDir;
          isSystemUser = true;
        };
      };
    };
}
