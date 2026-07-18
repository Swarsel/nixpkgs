{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkPackageOption
    mkOption
    attrNames
    types
    match
    optional
    optionals
    toInt
    last
    splitString
    allUnique
    concatStringsSep
    all
    filter
    mapAttrs
    any
    getExe
    maintainers
    ;
  inherit (cfg) settings;
  cfg = config.services.broadcast-box;

  addressToPort = address: toInt (last (splitString ":" address));
  httpPort = cfg.web.port;
  tcpMuxPort = addressToPort settings.TCP_MUX_ADDRESS;
  httpRedirect = settings.ENABLE_HTTP_REDIRECT or (settings.HTTPS_REDIRECT_PORT != null);

  udpPorts =
    optional (settings.UDP_MUX_PORT != null) settings.UDP_MUX_PORT
    ++ optional (settings.UDP_WHEP_PORT != null) settings.UDP_WHEP_PORT
    ++ optional (settings.UDP_WHIP_PORT != null) settings.UDP_WHIP_PORT;
  tcpPorts = optional (settings.TCP_MUX_ADDRESS != null) tcpMuxPort;
  webPorts = [ httpPort ] ++ optional httpRedirect settings.HTTPS_REDIRECT_PORT;
in
{
  options.services.broadcast-box = {
    enable = mkEnableOption "Broadcast Box";
    package = mkPackageOption pkgs "broadcast-box" { };

    openFirewall = mkEnableOption ''
      opening WebRTC traffic ports in the firewall. Randomly selected ports
      will not be opened.
    '';

    settings = mkOption {
      default = {
        DISABLE_STATUS = true;
      };

      description = ''
        Attribute set of environment variables.

        <https://github.com/Glimesh/broadcast-box#environment-variables>

        :::{.warning}
        The status API exposes stream keys so {env}`DISABLE_STATUS` is enabled
        by default.
        :::
      '';

      example = {
        DISABLE_STATUS = true;
        INCLUDE_PUBLIC_IP_IN_NAT_1_TO_1_IP = true;
        UDP_MUX_PORT = 3000;
      };

      type = types.submodule {
        options = {
          DISABLE_STATUS = mkOption {
            default = true;
            type = types.bool;
          };

          ENABLE_HTTP_REDIRECT = mkOption {
            default = false;
            type = types.bool;
          };

          HTTPS_REDIRECT_PORT = mkOption {
            default = if settings.ENABLE_HTTP_REDIRECT then 80 else null;
            type = with types; nullOr port;
          };

          TCP_MUX_ADDRESS = mkOption {
            default = null;
            type = with types; nullOr (strMatching ".*:[0-9]+");
          };

          UDP_MUX_PORT = mkOption {
            default = null;
            type = with types; nullOr port;
          };

          UDP_WHEP_PORT = mkOption {
            default = null;
            type = with types; nullOr port;
          };

          UDP_WHIP_PORT = mkOption {
            default = null;
            type = with types; nullOr port;
          };
        };

        freeformType =
          with types;
          attrsOf (
            nullOr (oneOf [
              bool
              int
              str
            ])
          );
      };

      visible = "shallow";
    };

    web = {
      host = mkOption {
        default = "";

        description = ''
          Host address the HTTP server listens on. By default the server
          listens on all interfaces.
        '';

        example = "127.0.0.1";
        type = types.str;
      };

      openFirewall = mkEnableOption ''
        opening the HTTP server port and, if enabled, the HTTPS redirect server
        port in the firewall.
      '';

      port = mkOption {
        default = 8080;

        description = ''
          Port the HTTP server listens on.
        '';

        type = types.port;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(settings ? HTTP_ADDRESS);

        message = ''
          The Broadcast Box `HTTP_ADDRESS` variable should not be used. Instead
          use the `host` and `port` options.
        '';
      }
      {
        assertion = httpRedirect -> settings ? SSL_CERT && settings ? SSL_KEY;

        message = ''
          The Broadcast Box `ENABLE_HTTP_REDIRECT` variable requires `SSL_CERT`
          and `SSL_KEY` to be configured.
        '';
      }
      {
        assertion = httpRedirect -> httpPort == 443;

        message = ''
          Broadcast Box HTTP redirect only works if the HTTP server listen port
          is 443.
        '';
      }
      {
        assertion = allUnique (tcpPorts ++ webPorts);

        message = ''
          Broadcast Box configuration contains duplicate TCP ports.
        '';
      }
      {
        assertion = all (name: (match "[A-Z0-9_]+" name) != null) (attrNames settings);

        message =
          let
            offenders = filter (name: (match "[A-Z0-9_]+" name) == null) (attrNames settings);
          in
          ''
            Broadcast Box `settings` attribute names must be in uppercase snake
            case. Invalid attribute name(s): `${concatStringsSep ", " offenders}`
          '';
      }
    ];

    networking.firewall = {
      allowedTCPPorts = optionals cfg.openFirewall tcpPorts ++ optionals cfg.web.openFirewall webPorts;
      allowedUDPPorts = optionals cfg.openFirewall udpPorts;
    };

    systemd.services.broadcast-box = {
      after = [ "network-online.target" ];
      description = "Broadcast Box";

      environment =
        (mapAttrs (
          _: value:
          if (builtins.typeOf value == "bool") then
            if !value then null else "true"
          else if (builtins.typeOf value == "int") then
            toString value
          else
            value
        ) cfg.settings)
        // {
          APP_ENV = "nixos";
          HTTP_ADDRESS = cfg.web.host + ":" + toString cfg.web.port;
        };

      serviceConfig =
        let
          priviledgedPort = any (p: p > 0 && p < 1024) (udpPorts ++ tcpPorts ++ webPorts);
        in
        {
          AmbientCapabilities = mkIf priviledgedPort [ "CAP_NET_BIND_SERVICE" ];
          CapabilityBoundingSet = if priviledgedPort then [ "CAP_NET_BIND_SERVICE" ] else "";
          DeviceAllow = "";
          DynamicUser = true;
          ExecStart = "${getExe cfg.package}";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          PrivateUsers = !priviledgedPort;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RemoveIPC = true;
          Restart = "always";
          RestartSec = "10s";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
            "AF_NETLINK"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
          ];

          UMask = "0077";
        };

      startLimitBurst = 3;
      startLimitIntervalSec = 180;
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with maintainers; [ JManch ];
}
