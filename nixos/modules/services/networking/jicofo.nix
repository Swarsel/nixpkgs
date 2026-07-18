{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.jicofo;

  format = pkgs.formats.hocon { };

  configFile = format.generate "jicofo.conf" cfg.config;
in
{
  options.services.jicofo = with lib.types; {
    config = lib.mkOption {
      default = { };

      description = ''
        Contents of the {file}`jicofo.conf` configuration file.
      '';

      example = lib.literalExpression ''
        {
          jicofo.bridge.max-bridge-participants = 42;
        }
      '';

      type = format.type;
    };

    enable = lib.mkEnableOption "Jitsi Conference Focus - component of Jitsi Meet";

    bridgeMuc = lib.mkOption {
      description = ''
        JID of the internal MUC used to communicate with Videobridges.
      '';

      example = "jvbbrewery@internal.meet.example.org";
      type = str;
    };

    componentPasswordFile = lib.mkOption {
      description = ''
        Path to file containing component secret.
      '';

      example = "/run/keys/jicofo-component";
      type = str;
    };

    userDomain = lib.mkOption {
      description = ''
        Domain part of the JID for XMPP user connection.
      '';

      example = "auth.meet.example.org";
      type = str;
    };

    userName = lib.mkOption {
      default = "focus";

      description = ''
        User part of the JID for XMPP user connection.
      '';

      type = str;
    };

    userPasswordFile = lib.mkOption {
      description = ''
        Path to file containing password for XMPP user connection.
      '';

      example = "/run/keys/jicofo-user";
      type = str;
    };

    xmppDomain = lib.mkOption {
      description = ''
        Domain name of the XMMP server to which to connect as a component.

        If null, {option}`xmppHost` is used.
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
    environment.etc."jitsi/jicofo/logging.properties".source =
      lib.mkDefault "${pkgs.jicofo}/etc/jitsi/jicofo/logging.properties-journal";

    environment.etc."jitsi/jicofo/sip-communicator.properties".text = "";

    services.jicofo.config = {
      jicofo = {
        bridge.brewery-jid = cfg.bridgeMuc;

        xmpp = rec {
          client = {
            domain = cfg.userDomain;
            hostname = cfg.xmppHost;
            password = format.lib.mkSubstitution "JICOFO_AUTH_PASS";
            username = cfg.userName;
            xmpp-domain = if cfg.xmppDomain == null then cfg.xmppHost else cfg.xmppDomain;
          };

          service = client;
        };
      };
    };

    systemd.services.jicofo =
      let
        jicofoProps = {
          "-Dconfig.file" = configFile;
          "-Djava.util.logging.config.file" = "/etc/jitsi/jicofo/logging.properties";
          "-Dnet.java.sip.communicator.SC_HOME_DIR_LOCATION" = "/etc/jitsi";
          "-Dnet.java.sip.communicator.SC_HOME_DIR_NAME" = "jicofo";
        };
      in
      {
        after = [ "network.target" ];
        description = "JItsi COnference FOcus";

        environment.JAVA_SYS_PROPS = lib.concatStringsSep " " (
          lib.mapAttrsToList (k: v: "${k}=${toString v}") jicofoProps
        );

        restartTriggers = [
          configFile
        ];

        script = ''
          export JICOFO_AUTH_PASS="$(<${cfg.userPasswordFile})"
          exec "${pkgs.jicofo}/bin/jicofo"
        '';

        serviceConfig = {
          CapabilityBoundingSet = "";
          DynamicUser = true;
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
          Type = "exec";
          User = "jicofo";
        };

        wantedBy = [ "multi-user.target" ];
      };

    users.groups.jitsi-meet = { };
  };

  meta.teams = [ lib.teams.jitsi ];
}
