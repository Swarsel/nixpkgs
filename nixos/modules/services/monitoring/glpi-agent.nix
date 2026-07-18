{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.glpiAgent;

  settingsType =
    with lib.types;
    attrsOf (oneOf [
      bool
      int
      str
      (listOf str)
    ]);

  formatValue =
    v:
    if lib.isBool v then
      if v then "1" else "0"
    else if lib.isList v then
      lib.concatStringsSep "," v
    else
      toString v;

  configContent = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (k: v: "${k} = ${formatValue v}") cfg.settings
  );

  configFile = pkgs.writeText "agent.cfg" configContent;

in
{
  options = {
    services.glpiAgent = {
      enable = lib.mkEnableOption "GLPI Agent";
      package = lib.mkPackageOption pkgs "glpi-agent" { };

      settings = lib.mkOption {
        default = { };

        description = ''
          GLPI Agent configuration options.
          See <https://glpi-agent.readthedocs.io/en/latest/configuration.html> for all available options.

          The 'server' option is mandatory and must point to your GLPI server.
        '';

        example = lib.literalExpression ''
          {
            server = [ "https://glpi.example.com/inventory" ];
            delaytime = 3600;
            tag = "production";
            logger = [ "stderr" "file" ];
            debug = 1;
            "no-category" = [ "printer" "software" ];
          }
        '';

        type = settingsType;
      };

      stateDir = lib.mkOption {
        default = "/var/lib/glpi-agent";
        description = "Directory where GLPI Agent stores its state.";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.settings ? server;
        message = "GLPI Agent requires a server to be configured in services.glpiAgent.settings.server";
      }
    ];

    systemd.services.glpi-agent = {
      after = [ "network.target" ];
      description = "GLPI Agent";

      serviceConfig = {
        AmbientCapabilities = [ "CAP_SYS_ADMIN" ];
        CapabilityBoundingSet = [ "CAP_SYS_ADMIN" ];
        DynamicUser = true;

        ExecStart = lib.escapeShellArgs [
          "${lib.getExe cfg.package}"
          "--conf-file"
          "${configFile}"
          "--vardir"
          "${cfg.stateDir}"
          "--daemon"
          "--no-fork"
        ];

        LimitCORE = 0;
        LimitNOFILE = 65535;
        LockPersonality = true;
        MemorySwapMax = 0;
        MemoryZSwapMax = 0;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        Restart = "on-failure";
        RestartSec = "10s";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
          "AF_NETLINK"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "glpi-agent";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "@resources"
          "~@privileged"
        ];

        UMask = "0077";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
