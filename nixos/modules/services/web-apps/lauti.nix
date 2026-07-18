{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.lauti;
  useLegacyDefault = lib.versionOlder config.system.stateVersion "26.05";
  default = if useLegacyDefault then "eintopf" else "lauti";

in
{

  imports = [
    (lib.mkRenamedOptionModule [ "services" "eintopf" ] [ "services" "lauti" ])
  ];

  options.services.lauti = {

    enable = mkEnableOption "Lauti community event calendar web app";

    dataDir = lib.mkOption {
      default = if useLegacyDefault then "/var/lib/eintopf" else "/var/lib/lauti";

      description = ''
        Data directory for Lauti
      '';

      type = lib.types.path;
    };

    secrets = lib.mkOption {
      default = [ ];

      description = ''
        A list of files containing the various secrets. Should be in the
        format expected by systemd's `EnvironmentFile` directory.
      '';

      type = with types; listOf path;
    };

    settings = mkOption {
      default = { };

      description = ''
        Settings to configure web service. See
        <https://codeberg.org/Klasse-Methode/lauti/src/branch/main/DEPLOYMENT.md>
        for available options.
      '';

      example = literalExpression ''
        {
          LAUTI_ADDR = ":1234";
          LAUTI_ADMIN_EMAIL = "admin@example.org";
          LAUTI_TIMEZONE = "Europe/Berlin";
        }
      '';

      type = types.attrsOf types.str;
    };

  };

  config = mkIf cfg.enable {

    systemd.services.lauti = {
      after = [ "network-online.target" ];
      description = "Community event calendar web app";
      environment = cfg.settings;

      serviceConfig = {
        # hardening
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        DevicePolicy = "closed";
        DynamicUser = true;
        EnvironmentFile = cfg.secrets;
        ExecStart = lib.getExe pkgs.lauti;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
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
        ProtectSystem = "strict";
        RemoveIPC = true;

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = default;
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        UMask = "0077";
        WorkingDirectory = cfg.dataDir;
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };

  };

  meta.maintainers = with lib.maintainers; [ onny ];

}
