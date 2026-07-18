{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.jigasi;
  homeDirName = "jigasi-home";
  stateDir = "/tmp";
  sipCommunicatorPropertiesFile = "${stateDir}/${homeDirName}/sip-communicator.properties";
  sipCommunicatorPropertiesFileUnsubstituted = "${pkgs.jigasi}/etc/jitsi/jigasi/sip-communicator.properties";
in
{
  options.services.jigasi = with lib.types; {
    config = lib.mkOption {
      default = { };

      description = ''
        Contents of the <filename>sip-communicator.properties</filename> configuration file for jigasi.
      '';

      example = lib.literalExpression ''
        {
          "org.jitsi.jigasi.auth.URL" = "XMPP:jitsi-meet.example.com";
        }
      '';

      type = attrsOf str;
    };

    enable = lib.mkEnableOption "Jitsi Gateway to SIP - component of Jitsi Meet";

    bridgeMuc = lib.mkOption {
      description = ''
        JID of the internal MUC used to communicate with Videobridges.
      '';

      example = "jigasibrewery@internal.meet.example.org";
      type = str;
    };

    componentPasswordFile = lib.mkOption {
      description = ''
        Path to file containing component secret.
      '';

      example = "/run/keys/jigasi-component";
      type = str;
    };

    defaultJvbRoomName = lib.mkOption {
      default = "";

      description = ''
        Name of the default JVB room that will be joined if no special header is included in SIP invite.
      '';

      example = "siptest";
      type = str;
    };

    environmentFile = lib.mkOption {
      default = null;

      description = ''
        File containing environment variables to be passed to the jigasi service,
        in which secret tokens can be specified securely by defining values for
        <literal>JIGASI_SIPUSER</literal>,
        <literal>JIGASI_SIPPWD</literal>,
        <literal>JIGASI_SIPSERVER</literal> and
        <literal>JIGASI_SIPPORT</literal>.
      '';

      type = lib.types.nullOr lib.types.path;
    };

    userDomain = lib.mkOption {
      description = ''
        Domain part of the JID for XMPP user connection.
      '';

      example = "internal.meet.example.org";
      type = str;
    };

    userName = lib.mkOption {
      default = "callcontrol";

      description = ''
        User part of the JID for XMPP user connection.
      '';

      type = str;
    };

    userPasswordFile = lib.mkOption {
      description = ''
        Path to file containing password for XMPP user connection.
      '';

      example = "/run/keys/jigasi-user";
      type = str;
    };

    xmppDomain = lib.mkOption {
      description = ''
        Domain name of the XMMP server to which to connect as a component.

        If null, <option>xmppHost</option> is used.
      '';

      example = "meet.example.org";
      type = nullOr str;
    };

    xmppHost = lib.mkOption {
      description = ''
        Hostname of the XMPP server to connect to.
      '';

      example = "localhost";
      type = str;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."jitsi/jigasi/logging.properties".source =
      lib.mkDefault "${stateDir}/logging.properties-journal";

    environment.etc."jitsi/jigasi/sip-communicator.properties".source = lib.mkDefault "${
      sipCommunicatorPropertiesFile
    }";

    services.jicofo.config = {
      "org.jitsi.jicofo.jigasi.BREWERY" = "${cfg.bridgeMuc}";
    };

    services.jigasi.config = lib.mapAttrs (_: v: lib.mkDefault v) {
      "org.jitsi.jigasi.BRIDGE_MUC" = cfg.bridgeMuc;
    };

    systemd.services.jigasi =
      let
        jigasiProps = {
          "-Djava.util.logging.config.file" = "${pkgs.jigasi}/etc/jitsi/jigasi/logging.properties";
          "-Dnet.java.sip.communicator.SC_HOME_DIR_LOCATION" = "${stateDir}";
          "-Dnet.java.sip.communicator.SC_HOME_DIR_NAME" = "${homeDirName}";
        };
      in
      {
        after = [ "network.target" ];
        description = "Jitsi Gateway to SIP";

        environment.JAVA_SYS_PROPS = lib.concatStringsSep " " (
          lib.mapAttrsToList (k: v: "${k}=${toString v}") jigasiProps
        );

        preStart = ''
          [ -f "${sipCommunicatorPropertiesFile}" ] && rm -f "${sipCommunicatorPropertiesFile}"
          mkdir -p "$(dirname ${sipCommunicatorPropertiesFile})"
          temp="${sipCommunicatorPropertiesFile}.unsubstituted"

          export DOMAIN_BASE="${cfg.xmppDomain}"
          export JIGASI_XMPP_PASSWORD=$(cat "${cfg.userPasswordFile}")
          export JIGASI_DEFAULT_JVB_ROOM_NAME="${cfg.defaultJvbRoomName}"

          # encode the credentials to base64
          export JIGASI_SIPPWD=$(echo -n "$JIGASI_SIPPWD" | base64 -w 0)
          export JIGASI_XMPP_PASSWORD_BASE64=$(cat "${cfg.userPasswordFile}" | base64 -w 0)

          cp "${sipCommunicatorPropertiesFileUnsubstituted}" "$temp"
          chmod 644 "$temp"
          cat <<EOF >>"$temp"
          net.java.sip.communicator.impl.protocol.sip.acc1403273890647.SERVER_PORT=$JIGASI_SIPPORT
          net.java.sip.communicator.impl.protocol.sip.acc1403273890647.PREFERRED_TRANSPORT=udp
          EOF
          chmod 444 "$temp"

          # Replace <<$VAR_NAME>> from example config to $VAR_NAME for environment substitution
          sed -i -E \
            's/<<([^>]+)>>/\$\1/g' \
            "$temp"

          sed -i \
            's|\(net\.java\.sip\.communicator\.impl\.protocol\.jabber\.acc-xmpp-1\.PASSWORD=\).*|\1\$JIGASI_XMPP_PASSWORD_BASE64|g' \
            "$temp"

          sed -i \
            's|\(#\)\(org.jitsi.jigasi.DEFAULT_JVB_ROOM_NAME=\).*|\2\$JIGASI_DEFAULT_JVB_ROOM_NAME|g' \
            "$temp"

          ${pkgs.envsubst}/bin/envsubst \
            -o "${sipCommunicatorPropertiesFile}" \
            -i "$temp"

          # Set the brewery room name
          sed -i \
            's|\(net\.java\.sip\.communicator\.impl\.protocol\.jabber\.acc-xmpp-1\.BREWERY=\).*|\1${cfg.bridgeMuc}|g' \
            "${sipCommunicatorPropertiesFile}"
          sed -i \
            's|\(org\.jitsi\.jigasi\.ALLOWED_JID=\).*|\1${cfg.bridgeMuc}|g' \
            "${sipCommunicatorPropertiesFile}"


          # Disable certificate verification for self-signed certificates
          sed -i \
            's|\(# \)\(net.java.sip.communicator.service.gui.ALWAYS_TRUST_MODE_ENABLED=true\)|\2|g' \
            "${sipCommunicatorPropertiesFile}"
        '';

        restartTriggers = [
          config.environment.etc."jitsi/jigasi/sip-communicator.properties".source
        ];

        script = ''
          ${pkgs.jigasi}/bin/jigasi \
            --host="${cfg.xmppHost}" \
            --domain="${if cfg.xmppDomain == null then cfg.xmppHost else cfg.xmppDomain}" \
            --secret="$(cat ${cfg.componentPasswordFile})" \
            --user_name="${cfg.userName}" \
            --user_domain="${cfg.userDomain}" \
            --user_password="$(cat ${cfg.userPasswordFile})" \
            --configdir="${stateDir}" \
            --configdirname="${homeDirName}"
        '';

        serviceConfig = {
          CapabilityBoundingSet = "";
          DynamicUser = true;
          EnvironmentFile = cfg.environmentFile;
          Group = "jitsi-meet";
          LockPersonality = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_UNIX"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          StateDirectory = baseNameOf stateDir;
          Type = "exec";
          User = "jigasi";
        };

        wantedBy = [ "multi-user.target" ];
      };

    users.groups.jitsi-meet = { };
  };

  meta.teams = [ lib.teams.jitsi ];
}
