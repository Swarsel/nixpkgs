{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.vnstat;
in
{
  options.services.vnstat = {
    enable = lib.mkEnableOption "update of network usage statistics via vnstatd";
    package = lib.mkPackageOption pkgs "vnstat" { };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    systemd.services.vnstat = {
      after = [ "network.target" ];
      description = "vnStat network traffic monitor";

      documentation = [
        "man:vnstatd(1)"
        "man:vnstat(1)"
        "man:vnstat.conf(5)"
      ];

      path = [ pkgs.coreutils ];

      serviceConfig = {
        ExecReload = "${pkgs.procps}/bin/kill -HUP $MAINPID";
        ExecStart = "${cfg.package}/bin/vnstatd -n";
        Group = "vnstatd";
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        # Hardening (from upstream example service)
        ProtectSystem = "strict";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "vnstat";
        User = "vnstatd";
      };

      wantedBy = [ "multi-user.target" ];
    };

    users = {
      groups.vnstatd = { };

      users.vnstatd = {
        description = "vnstat daemon user";
        group = "vnstatd";
        isSystemUser = true;
      };
    };
  };
}
