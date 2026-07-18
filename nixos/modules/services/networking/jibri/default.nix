{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.jibri;

  format = pkgs.formats.hocon { };

  # We're passing passwords in environment variables that have names generated
  # from an attribute name, which may not be a valid bash identifier.
  toVarName =
    s:
    "XMPP_PASSWORD_" + stringAsChars (c: if builtins.match "[A-Za-z0-9]" c != null then c else "_") s;

  defaultJibriConfig = {
    api = {
      http.external-api-port = 2222;
      http.internal-api-port = 3333;

      xmpp.environments = flip mapAttrsToList cfg.xmppEnvironments (
        name: env: {
          inherit name;

          call-login = {
            domain = env.call.login.domain;
            password = format.lib.mkSubstitution (toVarName "${name}_call");
            username = env.call.login.username;
          };

          control-login = {
            domain = env.control.login.domain;
            password = format.lib.mkSubstitution (toVarName "${name}_control");
            username = env.control.login.username;
          };

          control-muc = {
            domain = env.control.muc.domain;
            nickname = env.control.muc.nickname;
            room-name = env.control.muc.roomName;
          };

          strip-from-room-domain = env.stripFromRoomDomain;
          trust-all-xmpp-certs = env.disableCertificateVerification;
          usage-timeout = env.usageTimeout;
          xmpp-domain = env.xmppDomain;
          xmpp-server-hosts = env.xmppServerHosts;
        }
      );
    };

    call-status-checks = {
      all-muted-timeout = "10 minutes";
      default-call-empty-timout = "30 seconds";
      no-media-timout = "30 seconds";
    };

    chrome.flags = [
      "--use-fake-ui-for-media-stream"
      "--start-maximized"
      "--kiosk"
      "--enabled"
      "--disable-infobars"
      "--autoplay-policy=no-user-gesture-required"
    ]
    ++ lists.optional cfg.ignoreCert "--ignore-certificate-errors";

    id = "";
    jwt-info = { };

    recording = {
      finalize-script = "${cfg.finalizeScript}";
      recordings-directory = "/tmp/recordings";
    };

    single-use-mode = false;
    stats.enable-stats-d = true;
    streaming.rtmp-allow-list = [ ".*" ];
    webhook.subscribers = [ ];
  };
  # Allow overriding leaves of the default config despite types.attrs not doing any merging.
  jibriConfig = recursiveUpdate defaultJibriConfig cfg.config;
  configFile = format.generate "jibri.conf" { jibri = jibriConfig; };
in
{
  options.services.jibri = with types; {
    config = mkOption {
      default = { };

      description = ''
        Jibri configuration.
        See <https://github.com/jitsi/jibri/blob/master/src/main/resources/reference.conf>
        for default configuration with comments.
      '';

      type = format.type;
    };

    enable = mkEnableOption "Jitsi BRoadcasting Infrastructure. Currently Jibri must be run on a host that is also running {option}`services.jitsi-meet.enable`, so for most use cases it will be simpler to run {option}`services.jitsi-meet.jibri.enable`";

    finalizeScript = mkOption {
      default = pkgs.writeScript "finalize_recording.sh" ''
        #!/bin/sh

        RECORDINGS_DIR=$1

        echo "This is a dummy finalize script" > /tmp/finalize.out
        echo "The script was invoked with recordings directory $RECORDINGS_DIR." >> /tmp/finalize.out
        echo "You should put any finalize logic (renaming, uploading to a service" >> /tmp/finalize.out
        echo "or storage provider, etc.) in this script" >> /tmp/finalize.out

        exit 0
      '';

      defaultText = literalExpression ''
        pkgs.writeScript "finalize_recording.sh" ''''''
        #!/bin/sh

        RECORDINGS_DIR=$1

        echo "This is a dummy finalize script" > /tmp/finalize.out
        echo "The script was invoked with recordings directory $RECORDINGS_DIR." >> /tmp/finalize.out
        echo "You should put any finalize logic (renaming, uploading to a service" >> /tmp/finalize.out
        echo "or storage provider, etc.) in this script" >> /tmp/finalize.out

        exit 0
        '''''';
      '';

      description = ''
        This script runs when jibri finishes recording a video of a conference.
      '';

      example = literalExpression ''
        pkgs.writeScript "finalize_recording.sh" ''''''
        #!/bin/sh
        RECORDINGS_DIR=$1
        ''${pkgs.rclone}/bin/rclone copy $RECORDINGS_DIR RCLONE_REMOTE:jibri-recordings/ -v --log-file=/var/log/jitsi/jibri/recording-upload.txt
        exit 0
        '''''';
      '';

      type = types.path;
    };

    ignoreCert = mkOption {
      default = false;

      description = ''
        Whether to enable the flag "--ignore-certificate-errors" for the Chromium browser opened by Jibri.
        Intended for use in automated tests or anywhere else where using a verified cert for Jitsi-Meet is not possible.
      '';

      example = true;
      type = bool;
    };

    xmppEnvironments = mkOption {
      default = { };

      description = ''
        XMPP servers to connect to.
      '';

      example = literalExpression ''
        "jitsi-meet" = {
          xmppServerHosts = [ "localhost" ];
          xmppDomain = config.services.jitsi-meet.hostName;

          control.muc = {
            domain = "internal.''${config.services.jitsi-meet.hostName}";
            roomName = "JibriBrewery";
            nickname = "jibri";
          };

          control.login = {
            domain = "auth.''${config.services.jitsi-meet.hostName}";
            username = "jibri";
            passwordFile = "/var/lib/jitsi-meet/jibri-auth-secret";
          };

          call.login = {
            domain = "recorder.''${config.services.jitsi-meet.hostName}";
            username = "recorder";
            passwordFile = "/var/lib/jitsi-meet/jibri-recorder-secret";
          };

          usageTimeout = "0";
          disableCertificateVerification = true;
          stripFromRoomDomain = "conference.";
        };
      '';

      type = attrsOf (
        submodule (
          { name, ... }:
          {
            options = {
              call.login.domain = mkOption {
                description = ''
                  The domain part of the JID for the recorder.
                '';

                example = "recorder.xmpp.example.org";
                type = str;
              };

              call.login.passwordFile = mkOption {
                description = ''
                  File containing the password for the user.
                '';

                example = "/run/keys/jibri-recorder-xmpp1";
                type = str;
              };

              call.login.username = mkOption {
                default = "recorder";

                description = ''
                  User part of the JID for the recorder.
                '';

                type = str;
              };

              control.login.domain = mkOption {
                description = ''
                  The domain part of the JID for this Jibri instance.
                '';

                type = str;
              };

              control.login.passwordFile = mkOption {
                description = ''
                  File containing the password for the user.
                '';

                example = "/run/keys/jibri-xmpp1";
                type = str;
              };

              control.login.username = mkOption {
                default = "jvb";

                description = ''
                  User part of the JID.
                '';

                type = str;
              };

              control.muc.domain = mkOption {
                description = ''
                  The domain part of the MUC to connect to for control.
                '';

                type = str;
              };

              control.muc.nickname = mkOption {
                default = "jibri";

                description = ''
                  The nickname for this Jibri instance in the MUC.
                '';

                type = str;
              };

              control.muc.roomName = mkOption {
                default = "JibriBrewery";

                description = ''
                  The room name of the MUC to connect to for control.
                '';

                type = str;
              };

              disableCertificateVerification = mkOption {
                default = false;

                description = ''
                  Whether to skip validation of the server's certificate.
                '';

                type = bool;
              };

              stripFromRoomDomain = mkOption {
                default = "0";

                description = ''
                  The prefix to strip from the room's JID domain to derive the call URL.
                '';

                example = "conference.";
                type = str;
              };

              usageTimeout = mkOption {
                default = "0";

                description = ''
                  The duration that the Jibri session can be.
                  A value of zero means indefinitely.
                '';

                example = "1 hour";
                type = str;
              };

              xmppDomain = mkOption {
                description = ''
                  The base XMPP domain.
                '';

                example = "xmpp.example.org";
                type = str;
              };

              xmppServerHosts = mkOption {
                description = ''
                  Hostnames of the XMPP servers to connect to.
                '';

                example = [ "xmpp.example.org" ];
                type = listOf str;
              };
            };

            config =
              let
                nick = mkDefault (
                  builtins.replaceStrings [ "." ] [ "-" ] (
                    config.networking.hostName
                    + optionalString (config.networking.domain != null) ".${config.networking.domain}"
                  )
                );
              in
              {
                call.login.username = nick;
                control.muc.nickname = nick;
              };
          }
        )
      );
    };
  };

  config = mkIf cfg.enable {
    boot = {
      extraModprobeConfig = ''
        options snd-aloop enable=1,1,1,1,1,1,1,1
      '';

      kernelModules = [ "snd-aloop" ];
    };

    # Configure Chromium to not show the "Chrome is being controlled by automatic test software" message.
    environment.etc."chromium/policies/managed/managed_policies.json".text = builtins.toJSON {
      CommandLineFlagSecurityWarningsEnabled = false;
    };

    systemd.services.jibri = {
      after = [ "network.target" ];
      description = "Jibri Process";
      environment.HOME = "/var/lib/jibri";

      path = with pkgs; [
        chromedriver
        chromium
        ffmpeg-full
      ];

      requires = [
        "jibri-icewm.service"
        "jibri-xorg.service"
      ];

      script =
        (concatStrings (
          mapAttrsToList (name: env: ''
            export ${toVarName "${name}_control"}=$(cat ${env.control.login.passwordFile})
            export ${toVarName "${name}_call"}=$(cat ${env.call.login.passwordFile})
          '') cfg.xmppEnvironments
        ))
        + ''
          ${pkgs.jdk11_headless}/bin/java -Djava.util.logging.config.file=${./logging.properties-journal} -Dconfig.file=${configFile} -jar ${pkgs.jibri}/opt/jitsi/jibri/jibri.jar --config /var/lib/jibri/jibri.json
        '';

      serviceConfig = {
        Group = "jibri";
        Restart = "always";
        RestartPreventExitStatus = 255;
        StateDirectory = "jibri";
        Type = "simple";
        User = "jibri";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.jibri-icewm = {
      after = [ "jibri-xorg.service" ];
      description = "Jitsi Window Manager";
      environment.DISPLAY = ":0";
      requires = [ "jibri-xorg.service" ];

      serviceConfig = {
        ExecStart = "${pkgs.icewm}/bin/icewm-session";
        Group = "jibri";
        Restart = "on-failure";
        RestartPreventExitStatus = 255;
        StateDirectory = "jibri";
        Type = "simple";
        User = "jibri";
      };

      wantedBy = [ "jibri.service" ];
    };

    systemd.services.jibri-xorg = {
      after = [ "network.target" ];
      description = "Jitsi Xorg Process";
      environment.DISPLAY = ":0";

      preStart = ''
        cp --no-preserve=mode,ownership ${pkgs.jibri}/etc/jitsi/jibri/* /var/lib/jibri
        mv /var/lib/jibri/{,.}asoundrc
      '';

      serviceConfig = {
        ExecStart = "${pkgs.xorg-server}/bin/Xorg -nocursor -noreset +extension RANDR +extension RENDER -config ${pkgs.jibri}/etc/jitsi/jibri/xorg-video-dummy.conf -logfile /dev/null :0";
        Group = "jibri";
        KillMode = "process";
        Restart = "on-failure";
        RestartPreventExitStatus = 255;
        StateDirectory = "jibri";
        Type = "simple";
        User = "jibri";
      };

      wantedBy = [
        "jibri.service"
        "jibri-icewm.service"
      ];
    };

    systemd.tmpfiles.settings."10-jibri"."/var/log/jitsi/jibri".d = {
      group = "jibri";
      mode = "755";
      user = "jibri";
    };

    users.groups.jibri = { };
    users.groups.plugdev = { };

    users.users.jibri = {
      extraGroups = [
        "jitsi-meet"
        "adm"
        "audio"
        "video"
        "plugdev"
      ];

      group = "jibri";
      home = "/var/lib/jibri";
      isSystemUser = true;
    };

    warnings = [
      "All security warnings for Chromium have been disabled. This is necessary for Jibri, but it also impacts all other uses of Chromium on this system."
    ];
  };

  meta.teams = [ lib.teams.jitsi ];
}
