{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.chromadb;
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    mkIf
    types
    ;
in
{

  imports = [
    (lib.mkRemovedOptionModule [ "services" "chromadb" "logFile" ] ''
      ChromaDB has removed the --log-path parameter that logFile relied on.
    '')
  ];

  options = {
    services.chromadb = {
      enable = mkEnableOption "ChromaDB, an open-source AI application database.";
      package = mkPackageOption pkgs [ "python3Packages" "chromadb" ] { };

      dbpath = mkOption {
        default = "/var/lib/chromadb";
        description = "Location where ChromaDB stores its files";
        type = types.str;
      };

      host = mkOption {
        default = "127.0.0.1";

        description = ''
          Defines the IP address by which ChromaDB will be accessible.
        '';

        type = types.str;
      };

      openFirewall = mkOption {
        default = false;

        description = ''
          Whether to automatically open the specified TCP port in the firewall.
        '';

        type = types.bool;
      };

      port = mkOption {
        default = 8000;

        description = ''
          Defined the port number to listen.
        '';

        type = types.port;
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [ cfg.port ];

    systemd.services.chromadb = {
      after = [ "network.target" ];
      description = "ChromaDB";

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${lib.getExe cfg.package} run --path ${cfg.dbpath} --host ${cfg.host} --port ${toString cfg.port}";
        LogsDirectory = "chromadb";
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RemoveIPC = true;
        Restart = "on-failure";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "chromadb";
        Type = "simple";
        WorkingDirectory = "/var/lib/chromadb";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ ];
}
