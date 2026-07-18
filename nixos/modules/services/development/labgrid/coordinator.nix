{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.labgrid.coordinator;
in
{
  options = {
    services.labgrid.coordinator = {
      enable = lib.mkEnableOption "Labgrid Coordinator";
      package = lib.mkPackageOption pkgs [ "python3Packages" "labgrid" ] { };

      bindAddress = lib.mkOption {
        default = "0.0.0.0";
        description = "Bind address for the labgrid coordinator.";
        type = lib.types.str;
      };

      debug = lib.mkOption {
        default = false;

        description = ''
          Whether to enable debug mode.
        '';

        type = with lib.types; bool;
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Whether to automatically open the coordinator listen port in the firewall.
        '';

        type = with lib.types; bool;
      };

      port = lib.mkOption {
        default = 20408;
        description = "Coordinator port to bind to.";
        type = lib.types.port;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.labgrid-coordinator = {
      after = [ "network-online.target" ];
      description = "Labgrid Coordinator";

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = "yes";
        Environment = ''"PYTHONUNBUFFERED=1"'';
        ExecStart = "${lib.getBin cfg.package}/bin/labgrid-coordinator ${lib.optionalString cfg.debug "--debug"} --listen ${cfg.bindAddress}:${toString cfg.port}";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
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
        Restart = "on-failure";
        RestrictAddressFamilies = "AF_INET AF_INET6";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "labgrid-coordinator";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        WorkingDirectory = "/var/lib/labgrid-coordinator";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta = {
    maintainers = with lib.maintainers; [
      aiyion
      emantor
    ];
  };
}
