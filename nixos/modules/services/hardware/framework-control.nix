{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.framework-control;
in
{
  options.services.framework-control = {
    enable = lib.mkEnableOption "Framework Control device hardware service";
    package = lib.mkPackageOption pkgs "framework-control" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.framework-control = {
      after = [ "network.target" ];
      description = "Framework Control Service";
      # framework-control shells out to framework_tool at runtime for hardware access
      path = [ pkgs.framework-tool ];

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        Restart = "on-failure";
        RestartSec = "5s";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.ozturkkl ];
}
