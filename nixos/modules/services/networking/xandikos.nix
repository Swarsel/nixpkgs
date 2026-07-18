{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.xandikos;
in
{

  options = {
    services.xandikos = {
      enable = mkEnableOption "Xandikos CalDAV and CardDAV server";
      package = mkPackageOption pkgs "xandikos" { };

      address = mkOption {
        default = "localhost";

        description = ''
          The IP address on which Xandikos will listen.
          By default listens on localhost.
        '';

        type = types.str;
      };

      extraOptions = mkOption {
        default = [ ];

        description = ''
          Extra command line arguments to pass to xandikos.
        '';

        example = literalExpression ''
          [ "--autocreate"
            "--defaults"
            "--current-user-principal user"
            "--dump-dav-xml"
          ]
        '';

        type = types.listOf types.str;
      };

      nginx = mkOption {
        default = { };

        description = ''
          Configuration for nginx reverse proxy.
        '';

        type = types.submodule {
          options = {
            enable = mkOption {
              default = false;

              description = ''
                Configure the nginx reverse proxy settings.
              '';

              type = types.bool;
            };

            hostName = mkOption {
              description = ''
                The hostname use to setup the virtualhost configuration
              '';

              type = types.str;
            };
          };
        };
      };

      port = mkOption {
        default = 8080;
        description = "The port of the Xandikos web application";
        type = types.port;
      };

      routePrefix = mkOption {
        default = "/";

        description = ''
          Path to Xandikos.
          Useful when Xandikos is behind a reverse proxy.
        '';

        type = types.str;
      };

    };

  };

  config = mkIf cfg.enable (mkMerge [
    {

      systemd.services.xandikos = {
        after = [ "network.target" ];
        description = "A Simple Calendar and Contact Server";

        serviceConfig = {
          # Sandboxing
          CapabilityBoundingSet = "CAP_NET_RAW CAP_NET_ADMIN";
          DynamicUser = "yes";

          ExecStart = ''
            ${cfg.package}/bin/xandikos \
              --directory /var/lib/xandikos \
              --listen-address ${cfg.address} \
              --port ${toString cfg.port} \
              --route-prefix ${cfg.routePrefix} \
              ${lib.concatStringsSep " " cfg.extraOptions}
          '';

          Group = "xandikos";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectSystem = "strict";
          RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX AF_PACKET AF_NETLINK";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RuntimeDirectory = "xandikos";
          StateDirectory = "xandikos";
          StateDirectoryMode = "0700";
          User = "xandikos";
        };

        wantedBy = [ "multi-user.target" ];
      };
    }

    (mkIf cfg.nginx.enable {
      services.nginx = {
        enable = true;

        virtualHosts."${cfg.nginx.hostName}" = {
          locations."/" = {
            proxyPass = "http://${cfg.address}:${toString cfg.port}/";
          };
        };
      };
    })
  ]);

  meta.maintainers = with lib.maintainers; [ _0x4A6F ];
}
