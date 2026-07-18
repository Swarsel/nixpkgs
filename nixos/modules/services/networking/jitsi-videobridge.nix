{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.jitsi-videobridge;
  attrsToArgs = a: lib.concatStringsSep " " (lib.mapAttrsToList (k: v: "${k}=${toString v}") a);

  format = pkgs.formats.hocon { };

  # We're passing passwords in environment variables that have names generated
  # from an attribute name, which may not be a valid bash identifier.
  toVarName =
    s:
    "XMPP_PASSWORD_"
    + lib.stringAsChars (c: if builtins.match "[A-Za-z0-9]" c != null then c else "_") s;

  defaultJvbConfig = {
    videobridge = {
      apis.rest.enabled = cfg.colibriRestApi;

      apis.xmpp-client.configs = lib.flip lib.mapAttrs cfg.xmppConfigs (
        name: xmppConfig: {
          disable_certificate_verification = xmppConfig.disableCertificateVerification;
          domain = xmppConfig.domain;
          hostname = xmppConfig.hostName;
          muc_jids = xmppConfig.mucJids;
          muc_nickname = xmppConfig.mucNickname;
          password = format.lib.mkSubstitution (toVarName name);
          username = xmppConfig.userName;
        }
      );

      ice = {
        tcp = {
          enabled = true;
          port = 4443;
        };

        udp.port = 10000;
      };

      stats = {
        enabled = true;
        transports = [ { type = "muc"; } ];
      };
    };
  };

  # Allow overriding leaves of the default config despite types.attrs not doing any merging.
  jvbConfig = lib.recursiveUpdate defaultJvbConfig cfg.config;
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "jitsi-videobridge" "apis" ]
      "services.jitsi-videobridge.apis was broken and has been migrated into the boolean option services.jitsi-videobridge.colibriRestApi. It is set to false by default, setting it to true will correctly enable the private /colibri rest API."
    )
  ];

  options.services.jitsi-videobridge = with lib.types; {
    config = lib.mkOption {
      default = { };

      description = ''
        Videobridge configuration.

        See <https://github.com/jitsi/jitsi-videobridge/blob/master/jvb/src/main/resources/reference.conf>
        for default configuration with comments.
      '';

      example = lib.literalExpression ''
        {
          videobridge = {
            ice.udp.port = 5000;
            websockets = {
              enabled = true;
              server-id = "jvb1";
            };
          };
        }
      '';

      type = attrs;
    };

    enable = lib.mkEnableOption "Jitsi Videobridge, a WebRTC compatible video router";

    colibriRestApi = lib.mkOption {
      default = false;

      description = ''
        Whether to enable the private rest API for the COLIBRI control interface.
        Needed for monitoring jitsi, enabling scraping of the /colibri/stats endpoint.
      '';

      type = bool;
    };

    extraProperties = lib.mkOption {
      default = { };

      description = ''
        Additional Java properties passed to jitsi-videobridge.
      '';

      type = attrsOf str;
    };

    nat = {
      harvesterAddresses = lib.mkOption {
        default = [
          "stunserver.stunprotocol.org:3478"
          "stun.framasoft.org:3478"
          "meet-jit-si-turnrelay.jitsi.net:443"
        ];

        description = ''
          Addresses of public STUN services to use to automatically find
          the public and local addresses of this Jitsi-Videobridge instance
          without the need for manual configuration.

          This option is ignored if {option}`services.jitsi-videobridge.nat.localAddress`
          and {option}`services.jitsi-videobridge.nat.publicAddress` are set.
        '';

        example = [ ];
        type = listOf str;
      };

      localAddress = lib.mkOption {
        default = null;

        description = ''
          Local address to assume when running behind NAT.
        '';

        example = "192.168.1.42";
        type = nullOr str;
      };

      publicAddress = lib.mkOption {
        default = null;

        description = ''
          Public address to assume when running behind NAT.
        '';

        example = "1.2.3.4";
        type = nullOr str;
      };
    };

    openFirewall = lib.mkOption {
      default = false;

      description = ''
        Whether to open ports in the firewall for the videobridge.
      '';

      type = bool;
    };

    xmppConfigs = lib.mkOption {
      default = { };

      description = ''
        XMPP servers to connect to.

        See <https://github.com/jitsi/jitsi-videobridge/blob/master/doc/muc.md> for more information.
      '';

      example = lib.literalExpression ''
        {
          "localhost" = {
            hostName = "localhost";
            userName = "jvb";
            domain = "auth.xmpp.example.org";
            passwordFile = "/var/lib/jitsi-meet/videobridge-secret";
            mucJids = "jvbbrewery@internal.xmpp.example.org";
          };
        }
      '';

      type = attrsOf (
        submodule (
          { name, ... }:
          {
            options = {
              disableCertificateVerification = lib.mkOption {
                default = false;

                description = ''
                  Whether to skip validation of the server's certificate.
                '';

                type = bool;
              };

              domain = lib.mkOption {
                default = null;

                description = ''
                  Domain part of JID of the XMPP user, if it is different from hostName.
                '';

                example = "auth.xmpp.example.org";
                type = nullOr str;
              };

              hostName = lib.mkOption {
                description = ''
                  Hostname of the XMPP server to connect to. Name of the attribute set is used by default.
                '';

                example = "xmpp.example.org";
                type = str;
              };

              mucJids = lib.mkOption {
                description = ''
                  JID of the MUC to join. JiCoFo needs to be configured to join the same MUC.
                '';

                example = "jvbbrewery@internal.xmpp.example.org";
                type = str;
              };

              mucNickname = lib.mkOption {
                description = ''
                  Videobridges use the same XMPP account and need to be distinguished by the
                  nickname (aka resource part of the JID). By default, system hostname is used.
                '';

                # Upstream DEBs use UUID, let's use hostname instead.
                type = str;
              };

              passwordFile = lib.mkOption {
                description = ''
                  File containing the password for the user.
                '';

                example = "/run/keys/jitsi-videobridge-xmpp1";
                type = str;
              };

              userName = lib.mkOption {
                default = "jvb";

                description = ''
                  User part of the JID.
                '';

                type = str;
              };
            };

            config = {
              hostName = lib.mkDefault name;

              mucNickname = lib.mkDefault (
                builtins.replaceStrings [ "." ] [ "-" ] (config.networking.fqdnOrHostName)
              );
            };
          }
        )
      );
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.nat.publicAddress == null) == (cfg.nat.localAddress == null);
        message = "publicAddress must be set if and only if localAddress is set";
      }
    ];

    boot.kernel.sysctl."net.core.netdev_max_backlog" = lib.mkDefault 100000;
    # (from videobridge2 .deb)
    # this sets the max, so that we can bump the JVB UDP single port buffer size.
    boot.kernel.sysctl."net.core.rmem_max" = lib.mkDefault 10485760;

    environment.etc."jitsi/videobridge/logging.properties".source =
      lib.mkDefault "${pkgs.jitsi-videobridge}/etc/jitsi/videobridge/logging.properties-journal";

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      jvbConfig.videobridge.ice.tcp.port
    ];

    networking.firewall.allowedUDPPorts = lib.mkIf cfg.openFirewall [
      jvbConfig.videobridge.ice.udp.port
    ];

    services.jitsi-videobridge.extraProperties =
      if (cfg.nat.localAddress != null) then
        {
          "org.ice4j.ice.harvest.NAT_HARVESTER_LOCAL_ADDRESS" = cfg.nat.localAddress;
          "org.ice4j.ice.harvest.NAT_HARVESTER_PUBLIC_ADDRESS" = cfg.nat.publicAddress;
        }
      else
        {
          "org.ice4j.ice.harvest.STUN_MAPPING_HARVESTER_ADDRESSES" =
            lib.concatStringsSep "," cfg.nat.harvesterAddresses;
        };

    systemd.services.jitsi-videobridge2 =
      let
        jvbProps = {
          "-Dconfig.file" = format.generate "jvb.conf" jvbConfig;
          "-Djava.util.logging.config.file" = "/etc/jitsi/videobridge/logging.properties";
          # Mitigate CVE-2021-44228
          "-Dlog4j2.formatMsgNoLookups" = true;
          "-Dnet.java.sip.communicator.SC_HOME_DIR_LOCATION" = "/etc/jitsi";
          "-Dnet.java.sip.communicator.SC_HOME_DIR_NAME" = "videobridge";
        }
        // (lib.mapAttrs' (k: v: lib.nameValuePair "-D${k}" v) cfg.extraProperties);
      in
      {
        after = [ "network.target" ];
        aliases = [ "jitsi-videobridge.service" ];
        description = "Jitsi Videobridge";
        environment.JAVA_SYS_PROPS = attrsToArgs jvbProps;

        script =
          (lib.concatStrings (
            lib.mapAttrsToList (
              name: xmppConfig: "export ${toVarName name}=$(cat ${xmppConfig.passwordFile})\n"
            ) cfg.xmppConfigs
          ))
          + ''
            ${pkgs.jitsi-videobridge}/bin/jitsi-videobridge
          '';

        serviceConfig = {
          AmbientCapabilities = "CAP_NET_BIND_SERVICE";
          CapabilityBoundingSet = "";
          DynamicUser = true;
          Group = "jitsi-meet";
          LimitNOFILE = 65000;
          LimitNPROC = 65000;
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
          TasksMax = 65000;
          Type = "exec";
          User = "jitsi-videobridge";
        };

        wantedBy = [ "multi-user.target" ];
      };

    users.groups.jitsi-meet = { };
  };

  meta.teams = [ lib.teams.jitsi ];
}
