{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.pdudaemon;
  configFile = pkgs.writeText "pdudaemon.conf" (
    lib.generators.toJSON { } {
      daemon = {
        hostname = cfg.bindAddress;
        listener = cfg.listener;
        logging_level = cfg.logLevel;
        port = cfg.port;
      };

      pdus = cfg.pdus;
    }
  );
in
{
  options = {
    services.pdudaemon = {
      enable = lib.mkEnableOption "PDUDaemon";
      package = lib.mkPackageOption pkgs "pdudaemon" { };

      bindAddress = lib.mkOption {
        default = "0.0.0.0";
        description = "Bind address for the PDUDaemon.";
        type = lib.types.str;
      };

      listener = lib.mkOption {
        default = "http";
        description = "Which kind of listener to provide.";

        type = lib.types.enum [
          "http"
          "tcp"
        ];
      };

      logLevel = lib.mkOption {
        default = "error";
        description = "PDUDaemon log level.";

        type = lib.types.enum [
          "debug"
          "info"
          "warning"
          "error"
        ];
      };

      openFirewall = lib.mkOption {
        default = false;

        description = ''
          Whether to automatically open the PDUDaemon listen port in the firewall.
        '';

        type = lib.types.bool;
      };

      pdus = lib.mkOption {
        default = { };

        description = ''
          Structural pdus section of PDUDaemon's pdudaemon.conf.
          Refer to <https://github.com/pdudaemon/pdudaemon/blob/main/share/pdudaemon.conf>
          for more examples.
        '';

        example = lib.literalExpression ''
          {
            cbs350-poe-switch = {
              driver = "snmpv1";
              community = "private";
              oid = ".1.3.6.1.2.1.105.1.1.1.3.1.*;
              onsetting = 1;
              offsetting = 2;
            };
            energenie = {
              driver = "EG-PMS";
              device = "aa:bb:cc:xx:yy";
            };
            local = {
              driver = "localcmdline";
            };
          };
        '';

        type = with lib.types; attrsOf anything;
      };

      port = lib.mkOption {
        default = 16421;
        description = "Port to bind to.";
        type = lib.types.port;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.pdudaemon = {
      after = [ "network-online.target" ];
      description = "Control and Queueing daemon for PDUs";

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = "yes";
        ExecStart = "${lib.getExe cfg.package} --conf ${configFile}";
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
        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "pdudaemon";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];

        Type = "simple";
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
