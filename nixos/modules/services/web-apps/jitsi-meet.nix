{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.jitsi-meet;

  # The configuration files are JS of format "var <<string>> = <<JSON>>;". In order to
  # override only some settings, we need to extract the JSON, use jq to merge it with
  # the config provided by user, and then reconstruct the file.
  overrideJs =
    source: varName: userCfg: appendExtra:
    let
      extractor = pkgs.writeText "extractor.js" ''
        var fs = require("fs");
        eval(fs.readFileSync(process.argv[2], 'utf8'));
        process.stdout.write(JSON.stringify(eval(process.argv[3])));
      '';
      userJson = pkgs.writeText "user.json" (builtins.toJSON userCfg);
    in
    (pkgs.runCommand "${varName}.js" { } ''
      ${pkgs.lib.getExe pkgs.nodejs-slim} ${extractor} ${source} ${varName} > default.json
      (
        echo "var ${varName} = "
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' default.json ${userJson}
        echo ";"
        echo ${escapeShellArg appendExtra}
      ) > $out
    '');

  # Essential config - it's probably not good to have these as option default because
  # types.attrs doesn't do merging. Let's merge explicitly, can still be overridden if
  # user desires.
  defaultCfg = {
    bosh = "//${cfg.hostName}/http-bind";
    fileRecordingsEnabled = true;
    hiddenDomain = "recorder.${cfg.hostName}";

    hosts = {
      domain = cfg.hostName;
      focus = "focus.${cfg.hostName}";
      jigasi = "jigasi.${cfg.hostName}";
      muc = "conference.${cfg.hostName}";
    };

    liveStreamingEnabled = true;
    websocket = "wss://${cfg.hostName}/xmpp-websocket";
  };
in
{
  options.services.jitsi-meet = with types; {
    config = mkOption {
      default = { };

      description = ''
        Client-side web application settings that override the defaults in {file}`config.js`.

        See <https://github.com/jitsi/jitsi-meet/blob/master/config.js> for default
        configuration with comments.
      '';

      example = literalExpression ''
        {
          enableWelcomePage = false;
          defaultLang = "fi";
        }
      '';

      type = attrs;
    };

    enable = mkEnableOption "Jitsi Meet - Secure, Simple and Scalable Video Conferences";
    caddy.enable = mkEnableOption "caddy reverse proxy to expose jitsi-meet";
    excalidraw.enable = mkEnableOption "Excalidraw collaboration backend for Jitsi";

    excalidraw.port = mkOption {
      default = 3002;
      description = "The port which the Excalidraw backend for Jitsi should listen to.";
      type = types.port;
    };

    extraConfig = mkOption {
      default = "";

      description = ''
        Text to append to {file}`config.js` web application config file.

        Can be used to insert JavaScript logic to determine user's region in cascading bridges setup.
      '';

      type = lines;
    };

    hostName = mkOption {
      description = ''
        FQDN of the Jitsi Meet instance.
      '';

      example = "meet.example.org";
      type = str;
    };

    interfaceConfig = mkOption {
      default = { };

      description = ''
        Client-side web-app interface settings that override the defaults in {file}`interface_config.js`.

        See <https://github.com/jitsi/jitsi-meet/blob/master/interface_config.js> for
        default configuration with comments.
      '';

      example = literalExpression ''
        {
          SHOW_JITSI_WATERMARK = false;
          SHOW_WATERMARK_FOR_GUESTS = false;
        }
      '';

      type = attrs;
    };

    jibri.enable = mkOption {
      default = false;

      description = ''
        Whether to enable a Jibri instance and configure it to connect to Prosody.

        Additional configuration is possible with {option}`services.jibri`, and
        {option}`services.jibri.finalizeScript` is especially useful.
      '';

      type = bool;
    };

    jicofo.enable = mkOption {
      default = true;

      description = ''
        Whether to enable JiCoFo instance and configure it to connect to Prosody.

        Additional configuration is possible with {option}`services.jicofo`.
      '';

      type = bool;
    };

    jigasi.enable = mkOption {
      default = false;

      description = ''
        Whether to enable jigasi instance and configure it to connect to Prosody.

        Additional configuration is possible with <option>services.jigasi</option>.
      '';

      type = bool;
    };

    nginx.enable = mkOption {
      default = true;

      description = ''
        Whether to enable nginx virtual host that will serve the javascript application and act as
        a proxy for the XMPP server. Further nginx configuration can be done by adapting
        {option}`services.nginx.virtualHosts.<hostName>`.
        When this is enabled, ACME will be used to retrieve a TLS certificate by default. To disable
        this, set the {option}`services.nginx.virtualHosts.<hostName>.enableACME` to
        `false` and if appropriate do the same for
        {option}`services.nginx.virtualHosts.<hostName>.forceSSL`.
      '';

      type = bool;
    };

    prosody.allowners_muc = mkOption {
      default = false;

      description = ''
        Add module allowners, any user in chat is able to
        kick other. Usefull in jitsi-meet to kick ghosts.
      '';

      type = bool;
    };

    prosody.enable = mkOption {
      default = true;

      description = ''
        Whether to configure Prosody to relay XMPP messages between Jitsi Meet components. Turn this
        off if you want to configure it manually.
      '';

      example = false;
      type = bool;
    };

    prosody.lockdown = mkOption {
      default = false;

      description = ''
        Whether to disable Prosody features not needed by Jitsi Meet.

        The default Prosody configuration assumes that it will be used as a
        general-purpose XMPP server rather than as a companion service for
        Jitsi Meet. This option reconfigures Prosody to only listen on
        localhost without support for TLS termination, XMPP federation or
        the file transfer proxy.
      '';

      example = true;
      type = bool;
    };

    secureDomain = {
      enable = mkEnableOption "Authenticated room creation";

      authentication = mkOption {
        default = "internal_hashed";
        description = "The authentication type to be used by jitsi";
        type = types.str;
      };
    };

    videobridge = {
      enable = mkOption {
        default = true;

        description = ''
          Jitsi Videobridge instance and configure it to connect to Prosody.

          Additional configuration is possible with {option}`services.jitsi-videobridge`
        '';

        type = bool;
      };

      passwordFile = mkOption {
        default = null;

        description = ''
          File containing password to the Prosody account for videobridge.

          If `null`, a file with password will be generated automatically. Setting
          this option is useful if you plan to connect additional videobridges to the XMPP server.
        '';

        example = "/run/keys/videobridge";
        type = nullOr str;
      };
    };
  };

  config = mkIf cfg.enable {
    services.caddy = mkIf cfg.caddy.enable {
      enable = mkDefault true;

      virtualHosts.${cfg.hostName} = {
        extraConfig =
          let
            templatedJitsiMeet = pkgs.runCommand "templated-jitsi-meet" { } ''
              cp -R --no-preserve=all ${pkgs.jitsi-meet}/* .
              for file in *.html **/*.html ; do
                ${pkgs.sd}/bin/sd '<!--#include virtual="(.*)" -->' '{{ include "$1" }}' $file
              done
              rm config.js
              rm interface_config.js
              cp -R . $out
              cp ${
                overrideJs "${pkgs.jitsi-meet}/config.js" "config" (recursiveUpdate defaultCfg cfg.config)
                  cfg.extraConfig
              } $out/config.js
              cp ${
                overrideJs "${pkgs.jitsi-meet}/interface_config.js" "interfaceConfig" cfg.interfaceConfig ""
              } $out/interface_config.js
              cp ./libs/external_api.min.js $out/external_api.js
            '';
          in
          (optionalString cfg.excalidraw.enable ''
            handle /socket.io/ {
              reverse_proxy 127.0.0.1:${toString cfg.excalidraw.port}
            }
          '')
          + ''
            handle /http-bind {
              header Host ${cfg.hostName}
              reverse_proxy 127.0.0.1:5280
            }
            handle /xmpp-websocket {
              reverse_proxy 127.0.0.1:5280
            }
            handle {
              templates
              root * ${templatedJitsiMeet}
              try_files {path} {path}
              try_files {path} /index.html
              file_server
            }
          '';
      };
    };

    services.jibri = mkIf cfg.jibri.enable {
      enable = true;

      xmppEnvironments."jitsi-meet" = {
        call.login = {
          domain = "recorder.${cfg.hostName}";
          passwordFile = "/var/lib/jitsi-meet/jibri-recorder-secret";
          username = "recorder";
        };

        control.login = {
          domain = "auth.${cfg.hostName}";
          passwordFile = "/var/lib/jitsi-meet/jibri-auth-secret";
          username = "jibri";
        };

        control.muc = {
          domain = "internal.auth.${cfg.hostName}";
          nickname = "jibri";
          roomName = "JibriBrewery";
        };

        disableCertificateVerification = true;
        stripFromRoomDomain = "conference.";
        usageTimeout = "0";
        xmppDomain = cfg.hostName;
        xmppServerHosts = [ "localhost" ];
      };
    };

    services.jicofo = mkIf cfg.jicofo.enable {
      config = mkMerge [
        {
          jicofo.xmpp.client.disable-certificate-verification = true;
          jicofo.xmpp.service.disable-certificate-verification = true;
        }
        (lib.mkIf (config.services.jibri.enable || cfg.jibri.enable) {
          jicofo.jibri = {
            brewery-jid = "JibriBrewery@internal.auth.${cfg.hostName}";
            pending-timeout = "90";
          };
        })
        (lib.mkIf cfg.secureDomain.enable {
          jicofo = {
            authentication = {
              enabled = "true";
              login-url = cfg.hostName;
              type = "XMPP";
            };

            xmpp.client.client-proxy = "focus.${cfg.hostName}";
          };
        })
      ];

      enable = true;
      bridgeMuc = "jvbbrewery@internal.auth.${cfg.hostName}";
      componentPasswordFile = "/var/lib/jitsi-meet/jicofo-component-secret";
      userDomain = "auth.${cfg.hostName}";
      userName = "focus";
      userPasswordFile = "/var/lib/jitsi-meet/jicofo-user-secret";
      xmppDomain = cfg.hostName;
      xmppHost = "localhost";
    };

    services.jigasi = mkIf cfg.jigasi.enable {
      config = {
        "org.jitsi.jigasi.ALWAYS_TRUST_MODE_ENABLED" = "true";
      };

      enable = true;
      bridgeMuc = "jigasibrewery@internal.${cfg.hostName}";
      componentPasswordFile = "/var/lib/jitsi-meet/jigasi-component-secret";
      userDomain = "auth.${cfg.hostName}";
      userName = "jigasi";
      userPasswordFile = "/var/lib/jitsi-meet/jigasi-user-secret";
      xmppDomain = cfg.hostName;
      xmppHost = "localhost";
    };

    services.jitsi-meet.config = mkMerge [
      (mkIf cfg.excalidraw.enable {
        whiteboard = {
          collabServerBaseUrl = "https://${cfg.hostName}";
          enabled = true;
        };
      })
      (mkIf cfg.secureDomain.enable {
        hosts.anonymousdomain = "guest.${cfg.hostName}";
      })
    ];

    services.jitsi-videobridge = mkIf cfg.videobridge.enable {
      enable = true;

      xmppConfigs."localhost" = {
        disableCertificateVerification = true;
        domain = "auth.${cfg.hostName}";
        mucJids = "jvbbrewery@internal.auth.${cfg.hostName}";
        passwordFile = "/var/lib/jitsi-meet/videobridge-secret";
        userName = "jvb";
      };
    };

    services.nginx = mkIf cfg.nginx.enable {
      enable = mkDefault true;

      virtualHosts.${cfg.hostName} = {
        enableACME = mkDefault true;

        extraConfig = ''
          ssi on;
        '';

        forceSSL = mkDefault true;

        locations."/socket.io/" = mkIf cfg.excalidraw.enable {
          proxyPass = "http://127.0.0.1:${toString cfg.excalidraw.port}";
          proxyWebsockets = true;
        };

        locations."=/_api/room-info" = {
          extraConfig = ''
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $host;
          '';

          proxyPass = "http://localhost:5280/room-info";
        };

        locations."=/config.js" = mkDefault {
          alias =
            overrideJs "${pkgs.jitsi-meet}/config.js" "config" (recursiveUpdate defaultCfg cfg.config)
              cfg.extraConfig;
        };

        locations."=/external_api.js" = mkDefault {
          alias = "${pkgs.jitsi-meet}/libs/external_api.min.js";
        };

        locations."=/http-bind" = {
          extraConfig = ''
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $host;
          '';

          proxyPass = "http://localhost:5280/http-bind";
        };

        locations."=/interface_config.js" = mkDefault {
          alias =
            overrideJs "${pkgs.jitsi-meet}/interface_config.js" "interfaceConfig" cfg.interfaceConfig
              "";
        };

        locations."@root_path".extraConfig = ''
          rewrite ^/(.*)$ / break;
        '';

        locations."^~ /xmpp-websocket" = {
          priority = 100;
          proxyPass = "http://localhost:5280/xmpp-websocket";
          proxyWebsockets = true;
        };

        locations."~ ^/([^/\\?&:'\"]+)$".tryFiles = "$uri @root_path";
        root = pkgs.jitsi-meet;
      };
    };

    services.prosody = mkIf cfg.prosody.enable {

      enable = mkDefault true;

      # required for muc_breakout_rooms
      package = lib.mkDefault (
        pkgs.prosody.override {
          withExtraLuaPackages = p: with p; [ cjson ];
        }
      );

      extraConfig = lib.mkMerge [
        (mkAfter ''
          Component "focus.${cfg.hostName}" "client_proxy"
            target_address = "focus@auth.${cfg.hostName}"

          Component "jigasi.${cfg.hostName}" "client_proxy"
            target_address = "jigasi@auth.${cfg.hostName}"

          Component "speakerstats.${cfg.hostName}" "speakerstats_component"
            muc_component = "conference.${cfg.hostName}"

          Component "conferenceduration.${cfg.hostName}" "conference_duration_component"
            muc_component = "conference.${cfg.hostName}"

          Component "endconference.${cfg.hostName}" "end_conference"
            muc_component = "conference.${cfg.hostName}"

          Component "avmoderation.${cfg.hostName}" "av_moderation_component"
            muc_component = "conference.${cfg.hostName}"

          Component "metadata.${cfg.hostName}" "room_metadata_component"
            muc_component = "conference.${cfg.hostName}"
            breakout_rooms_component = "breakout.${cfg.hostName}"
        '')
        (mkBefore (
          ''
            muc_mapper_domain_base = "${cfg.hostName}"

            http_cors_override = {
              websocket = { enabled = true }
            }
            consider_websocket_secure = true;

            unlimited_jids = {
              "focus@auth.${cfg.hostName}",
              "jvb@auth.${cfg.hostName}"
            }
          ''
          + optionalString cfg.prosody.lockdown ''
            c2s_interfaces = { "127.0.0.1" };
            modules_disabled = { "s2s" };
          ''
        ))
      ];

      extraModules = [
        "pubsub"
        "smacks"
        "speakerstats"
        "external_services"
        "conference_duration"
        "muc_lobby_rooms"
        "muc_breakout_rooms"
        "av_moderation"
        "muc_hide_all"
        "muc_meeting_id"
        "muc_domain_mapper"
        "muc_rate_limit"
        "limits_exception"
        "persistent_lobby"
        "room_metadata"
      ];

      extraPluginPaths = [ "${pkgs.jitsi-meet-prosody}/share/prosody-plugins" ];
      httpInterfaces = mkIf cfg.prosody.lockdown (mkDefault [ "127.0.0.1" ]);
      httpsPorts = mkIf cfg.prosody.lockdown (mkDefault [ ]);

      modules = {
        admin_adhoc = mkDefault false;
        bosh = mkDefault true;
        ping = mkDefault true;
        proxy65 = mkIf cfg.prosody.lockdown (mkDefault false);
        roster = mkDefault true;
        saslauth = mkDefault true;
        smacks = mkDefault true;
        tls = mkDefault true;
        websocket = mkDefault true;
      };

      muc = [
        {
          allowners_muc = cfg.prosody.allowners_muc;
          domain = "conference.${cfg.hostName}";

          extraConfig = ''
            restrict_room_creation = true
            storage = "memory"
            admins = { "focus@auth.${cfg.hostName}" }
          '';

          name = "Jitsi Meet MUC";
          roomDefaultPublicJids = true;
          roomLocking = false;
        }
        {
          domain = "breakout.${cfg.hostName}";

          extraConfig = ''
            restrict_room_creation = true
            storage = "memory"
            admins = { "focus@auth.${cfg.hostName}", "jvb@auth.${cfg.hostName}" }
          '';

          name = "Jitsi Meet Breakout MUC";
          roomDefaultPublicJids = true;
          roomLocking = false;
        }
        {
          domain = "internal.auth.${cfg.hostName}";

          extraConfig = ''
            storage = "memory"
            admins = { "focus@auth.${cfg.hostName}", "jvb@auth.${cfg.hostName}", "jigasi@auth.${cfg.hostName}" }
          '';

          name = "Jitsi Meet Videobridge MUC";
          roomDefaultPublicJids = true;
          roomLocking = false;
          #-- muc_room_cache_size = 1000
        }
        {
          domain = "lobby.${cfg.hostName}";

          extraConfig = ''
            restrict_room_creation = true
            storage = "memory"
          '';

          name = "Jitsi Meet Lobby MUC";
          roomDefaultPublicJids = true;
          roomLocking = false;
        }
      ];

      virtualHosts.${cfg.hostName} = {
        domain = cfg.hostName;
        enabled = true;

        extraConfig = ''
          authentication = ${
            if cfg.secureDomain.enable then "\"${cfg.secureDomain.authentication}\"" else "\"jitsi-anonymous\""
          }
          c2s_require_encryption = false
          admins = { "focus@auth.${cfg.hostName}" }
          smacks_max_unacked_stanzas = 5
          smacks_hibernation_time = 60
          smacks_max_hibernated_sessions = 1
          smacks_max_old_sessions = 1

          av_moderation_component = "avmoderation.${cfg.hostName}"
          speakerstats_component = "speakerstats.${cfg.hostName}"
          conference_duration_component = "conferenceduration.${cfg.hostName}"
          end_conference_component = "endconference.${cfg.hostName}"

          lobby_muc = "lobby.${cfg.hostName}"
          breakout_rooms_muc = "breakout.${cfg.hostName}"
          room_metadata_component = "metadata.${cfg.hostName}"
          main_muc = "conference.${cfg.hostName}"
        '';

        ssl = {
          cert = "/var/lib/jitsi-meet/jitsi-meet.crt";
          key = "/var/lib/jitsi-meet/jitsi-meet.key";
        };
      };

      virtualHosts."auth.${cfg.hostName}" = {
        domain = "auth.${cfg.hostName}";
        enabled = true;

        extraConfig = ''
          authentication = "internal_hashed"
        '';

        ssl = {
          cert = "/var/lib/jitsi-meet/jitsi-meet.crt";
          key = "/var/lib/jitsi-meet/jitsi-meet.key";
        };
      };

      virtualHosts."guest.${cfg.hostName}" = {
        domain = "guest.${cfg.hostName}";
        enabled = true;

        extraConfig = ''
          authentication = "anonymous"
          c2s_require_encryption = false
        '';
      };

      virtualHosts."recorder.${cfg.hostName}" = {
        domain = "recorder.${cfg.hostName}";
        enabled = true;

        extraConfig = ''
          authentication = "internal_plain"
          c2s_require_encryption = false
        '';
      };

      xmppComplianceSuite = mkDefault false;
    };

    systemd.services.jitsi-excalidraw = mkIf cfg.excalidraw.enable {
      after = [ "network.target" ];
      description = "Excalidraw collaboration backend for Jitsi";
      environment.PORT = toString cfg.excalidraw.port;

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;
        ExecStart = "${pkgs.jitsi-excalidraw}/bin/jitsi-excalidraw-backend";
        Group = "jitsi-meet";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "noaccess";
        ProtectSystem = "strict";
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        SystemCallFilter = [
          "@system-service @pkey"
          "~@privileged"
        ];

        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.jitsi-meet-init-secrets = {
      before = [
        "jicofo.service"
        "jitsi-videobridge2.service"
      ]
      ++ (optional cfg.prosody.enable "prosody.service")
      ++ (optional cfg.jigasi.enable "jigasi.service");

      script =
        let
          secrets = [
            "jicofo-component-secret"
            "jicofo-user-secret"
            "jibri-auth-secret"
            "jibri-recorder-secret"
          ]
          ++ (optionals cfg.jigasi.enable [
            "jigasi-user-secret"
            "jigasi-component-secret"
          ])
          ++ (optional (cfg.videobridge.passwordFile == null) "videobridge-secret");
        in
        ''
          ${concatMapStringsSep "\n" (s: ''
            if [ ! -f ${s} ]; then
              tr -dc a-zA-Z0-9 </dev/urandom | head -c 64 > ${s}
            fi
          '') secrets}

          # for easy access in prosody
          echo "JICOFO_COMPONENT_SECRET=$(cat jicofo-component-secret)" > secrets-env
          echo "JIGASI_COMPONENT_SECRET=$(cat jigasi-component-secret)" >> secrets-env
        ''
        + optionalString cfg.prosody.enable ''
          # generate self-signed certificates
          if [ ! -f /var/lib/jitsi-meet/jitsi-meet.crt ]; then
            ${getBin pkgs.openssl}/bin/openssl req \
              -x509 \
              -newkey rsa:4096 \
              -keyout /var/lib/jitsi-meet/jitsi-meet.key \
              -out /var/lib/jitsi-meet/jitsi-meet.crt \
              -days 36500 \
              -nodes \
              -subj '/CN=${cfg.hostName}/CN=auth.${cfg.hostName}'
            chmod 640 /var/lib/jitsi-meet/jitsi-meet.key
          fi
        '';

      serviceConfig = {
        Group = "jitsi-meet";
        Type = "oneshot";
        UMask = "027";
        User = "root";
        WorkingDirectory = "/var/lib/jitsi-meet";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.prosody = mkIf cfg.prosody.enable {
      preStart =
        let
          videobridgeSecret =
            if cfg.videobridge.passwordFile != null then
              cfg.videobridge.passwordFile
            else
              "/var/lib/jitsi-meet/videobridge-secret";

        in
        ''
          ${config.services.prosody.package}/bin/prosodyctl register focus auth.${cfg.hostName} "$(cat /var/lib/jitsi-meet/jicofo-user-secret)"
          ${config.services.prosody.package}/bin/prosodyctl register jvb auth.${cfg.hostName} "$(cat ${videobridgeSecret})"
          ${config.services.prosody.package}/bin/prosodyctl mod_roster_command subscribe focus.${cfg.hostName} focus@auth.${cfg.hostName}
          ${config.services.prosody.package}/bin/prosodyctl register jibri auth.${cfg.hostName} "$(cat /var/lib/jitsi-meet/jibri-auth-secret)"
          ${config.services.prosody.package}/bin/prosodyctl register recorder recorder.${cfg.hostName} "$(cat /var/lib/jitsi-meet/jibri-recorder-secret)"
        ''
        + optionalString cfg.jigasi.enable ''
          ${config.services.prosody.package}/bin/prosodyctl register jigasi auth.${cfg.hostName} "$(cat /var/lib/jitsi-meet/jigasi-user-secret)"
        '';

      reloadIfChanged = true;

      serviceConfig = {
        EnvironmentFile = [ "/var/lib/jitsi-meet/secrets-env" ];
        SupplementaryGroups = [ "jitsi-meet" ];
      };
    };

    systemd.tmpfiles.rules = [
      "d '/var/lib/jitsi-meet' 0750 root jitsi-meet - -"
    ];

    users.groups.jitsi-meet = { };
  };

  meta.doc = ./jitsi-meet.md;
  meta.teams = [ lib.teams.jitsi ];
}
