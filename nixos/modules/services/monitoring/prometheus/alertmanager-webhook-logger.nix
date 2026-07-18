{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.prometheus.alertmanagerWebhookLogger;
in
{
  options.services.prometheus.alertmanagerWebhookLogger = {
    enable = lib.mkEnableOption "Alertmanager Webhook Logger";
    package = lib.mkPackageOption pkgs "alertmanager-webhook-logger" { };

    extraFlags = lib.mkOption {
      default = [ ];
      description = "Extra command line options to pass to alertmanager-webhook-logger.";
      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.alertmanager-webhook-logger = {
      after = [ "network-online.target" ];
      description = "Alertmanager Webhook Logger";

      serviceConfig = {
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        DynamicUser = true;

        ExecStart = ''
          ${cfg.package}/bin/alertmanager-webhook-logger \
          ${lib.escapeShellArgs cfg.extraFlags}
        '';

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateIPC = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = "tmpfs";
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        SystemCallFilter = [
          "@system-service"
          "~@cpu-emulation"
          "~@privileged"
          "~@reboot"
          "~@setuid"
          "~@swap"
        ];
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.jpds ];
}
