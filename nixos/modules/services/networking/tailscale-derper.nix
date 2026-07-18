{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.tailscale.derper;
in
{
  options = {
    services.tailscale.derper = {
      enable = lib.mkEnableOption "Tailscale Derper. See upstream doc <https://tailscale.com/kb/1118/custom-derp-servers> how to configure it on clients";

      package = lib.mkPackageOption pkgs [
        "tailscale"
        "derper"
      ] { };

      configureNginx = lib.mkOption {
        default = true;

        description = ''
          Whether to enable nginx reverse proxy for derper.
          When enabled, nginx will proxy requests to the derper service.
        '';

        type = lib.types.bool;
      };

      domain = lib.mkOption {
        description = "Domain name under which the derper server is reachable.";
        type = lib.types.str;
      };

      openFirewall = lib.mkOption {
        default = true;

        description = ''
          Whether to open the firewall for the specified port.
          Derper requires the used ports to be opened, otherwise it doesn't work as expected.
        '';

        type = lib.types.bool;
      };

      port = lib.mkOption {
        default = 8010;
        description = "The port the derper process will listen on. This is not the port tailscale will connect to.";
        type = lib.types.port;
      };

      stunPort = lib.mkOption {
        default = 3478;

        description = ''
          STUN port to listen on.
          See online docs <https://tailscale.com/kb/1118/custom-derp-servers#prerequisites> on how to configure a different external port.
        '';

        type = lib.types.port;
      };

      verifyClients = lib.mkOption {
        default = false;

        description = ''
          Whether to verify clients against a locally running tailscale daemon if they are allowed to connect to this node or not.
        '';

        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall {
      # port 80 and 443 are opened by nginx already when configureNginx is true
      allowedUDPPorts = [ cfg.stunPort ];
    };

    services = {
      nginx = lib.mkIf cfg.configureNginx {
        enable = true;

        virtualHosts."${cfg.domain}" = {
          addSSL = true; # this cannot be forceSSL as derper sends some information over port 80, too.

          locations."/" = {
            extraConfig = # nginx
              ''
                proxy_buffering off;
                proxy_read_timeout 3600s;
              '';

            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            proxyWebsockets = true;
          };
        };
      };

      tailscale.enable = lib.mkIf cfg.verifyClients true;
    };

    systemd.services.tailscale-derper = {
      serviceConfig = {
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = null;
        DynamicUser = true;

        ExecStart =
          "${lib.getExe' cfg.package "derper"} -a :${toString cfg.port} -c /var/lib/derper/derper.key -hostname=${cfg.domain} -stun-port ${toString cfg.stunPort}"
          + lib.optionalString cfg.verifyClients " -verify-clients";

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        Restart = "always";
        RestartSec = "5sec"; # don't crash loop immediately

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "derper";
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" ];
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ SuperSandro2000 ];
}
