{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.blocky;

  format = pkgs.formats.yaml { };
  configFile = format.generate "config.yaml" cfg.settings;
in
{
  options.services.blocky = {
    enable = lib.mkEnableOption "blocky, a fast and lightweight DNS proxy as ad-blocker for local network with many features";
    package = lib.mkPackageOption pkgs "blocky" { };

    enableConfigCheck = lib.mkEnableOption "checking the config during build time" // {
      default = true;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Blocky configuration. Refer to
        <https://0xerr0r.github.io/blocky/configuration/>
        for details on supported values.
      '';

      type = format.type;
    };
  };

  config = lib.mkIf cfg.enable {
    system.checks = lib.mkIf cfg.enableConfigCheck [
      (pkgs.runCommand "check-blocky-config" { } ''
        ${lib.getExe cfg.package} --config ${configFile} validate && touch $out
      '')
    ];

    systemd.services.blocky = {
      before = [
        "nss-lookup.target"
      ];

      description = "A DNS proxy and ad-blocker for the local network";

      serviceConfig = {
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        DynamicUser = true;
        ExecStart = "${lib.getExe cfg.package} --config ${configFile}";
        LockPersonality = true;
        LogsDirectory = "blocky";
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        NonBlocking = true;
        PrivateDevices = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        Restart = "on-failure";

        RestrictAddressFamilies =
          let
            logType = lib.attrByPath [ "settings" "queryLog" "type" ] "" cfg;
          in
          (lib.optional (lib.elem logType [
            "mysql"
            "postgresql"
            "timescale"
          ]) "AF_UNIX")
          ++ [
            "AF_INET"
            "AF_INET6"
          ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RuntimeDirectory = "blocky";
        StateDirectory = "blocky";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "@chown"
          "~@aio"
          "~@keyring"
          "~@memlock"
          "~@setuid"
          "~@timer"
        ];
      };

      wantedBy = [
        "multi-user.target"
      ];

      wants = [
        "network-online.target"
        "nss-lookup.target"
      ];
    };
  };

  meta.maintainers = with lib.maintainers; [
    paepcke
    kuflierl
  ];
}
