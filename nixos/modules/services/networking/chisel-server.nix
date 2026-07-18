{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.chisel-server;

in
{
  options = {
    services.chisel-server = {
      enable = lib.mkEnableOption "Chisel Tunnel Server";

      authfile = lib.mkOption {
        default = null;
        description = "Path to auth.json file";
        type = with lib.types; nullOr path;
      };

      backend = lib.mkOption {
        default = null;
        description = "HTTP server to proxy normal requests to";
        example = "http://127.0.0.1:8888";
        type = with lib.types; nullOr str;
      };

      host = lib.mkOption {
        default = null;
        description = "Address to listen on, falls back to 0.0.0.0";
        example = "[::1]";
        type = with lib.types; nullOr str;
      };

      keepalive = lib.mkOption {
        default = null;
        description = "Keepalive interval, falls back to 25s";
        example = "5s";
        type = with lib.types; nullOr str;
      };

      port = lib.mkOption {
        default = null;
        description = "Port to listen on, falls back to 8080";
        type = with lib.types; nullOr port;
      };

      reverse = lib.mkOption {
        default = false;
        description = "Allow clients reverse port forwarding";
        type = lib.types.bool;
      };

      socks5 = lib.mkOption {
        default = false;
        description = "Allow clients access to internal SOCKS5 proxy";
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.chisel-server = {
      description = "Chisel Tunnel Server";

      serviceConfig = {
        # Security Hardening
        # Refer to systemd.exec(5) for option descriptions.
        CapabilityBoundingSet = "";
        # implies RemoveIPC=, PrivateTmp=, NoNewPrivileges=, RestrictSUIDSGID=,
        # ProtectSystem=strict, ProtectHome=read-only
        DynamicUser = true;

        ExecStart =
          "${pkgs.chisel}/bin/chisel server "
          + lib.concatStringsSep " " (
            lib.optional (cfg.host != null) "--host ${cfg.host}"
            ++ lib.optional (cfg.port != null) "--port ${toString cfg.port}"
            ++ lib.optional (cfg.authfile != null) "--authfile ${cfg.authfile}"
            ++ lib.optional (cfg.keepalive != null) "--keepalive ${cfg.keepalive}"
            ++ lib.optional (cfg.backend != null) "--backend ${cfg.backend}"
            ++ lib.optional cfg.socks5 "--socks5"
            ++ lib.optional cfg.reverse "--reverse"
          );

        LockPersonality = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = "~@clock @cpu-emulation @debug @mount @obsolete @reboot @swap @privileged @resources";
        UMask = "0077";
      };

      wantedBy = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ clerie ];
}
