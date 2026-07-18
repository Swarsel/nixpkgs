{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Load default values from package. See https://github.com/bitvora/haven/blob/master/.env.example
  defaultSettings = fromTOML (builtins.readFile "${cfg.package}/share/haven/.env.example");

  import_relays_file = "${pkgs.writeText "import_relays.json" (builtins.toJSON cfg.importRelays)}";
  blastr_relays_file = "${pkgs.writeText "blastr_relays.json" (builtins.toJSON cfg.blastrRelays)}";

  mergedSettings = cfg.settings // {
    BLASTR_RELAYS_FILE = blastr_relays_file;
    IMPORT_SEED_RELAYS_FILE = import_relays_file;
  };

  cfg = config.services.haven;
in
{
  options.services.haven = {
    enable = lib.mkEnableOption "haven";
    package = lib.mkPackageOption pkgs "haven" { };

    blastrRelays = lib.mkOption {
      default = [ ];
      description = "List of relay configurations for blastr";

      example = lib.literalExpression ''
        [
          "relay.example.com"
        ]
      '';

      type = lib.types.listOf lib.types.str;
    };

    environmentFile = lib.mkOption {
      default = null;

      description = ''
        Path to a file containing sensitive environment variables. See <https://github.com/bitvora/haven> for documentation.
        The file should contain environment-variable assignments like:
        S3_SECRET_KEY=mysecretkey
        S3_ACCESS_KEY_ID=myaccesskey
      '';

      example = "/var/lib/haven/secrets.env";
      type = lib.types.nullOr lib.types.path;
    };

    importRelays = lib.mkOption {
      default = [ ];
      description = "List of relay configurations for importing historical events";

      example = lib.literalExpression ''
        [
          "relay.example.com"
        ]
      '';

      type = lib.types.listOf lib.types.str;
    };

    settings = lib.mkOption {
      apply = lib.recursiveUpdate defaultSettings;
      default = defaultSettings;
      defaultText = "See <https://github.com/bitvora/haven/blob/master/.env.example>";
      description = "See <https://github.com/bitvora/haven> for documentation.";

      example = lib.literalExpression ''
        {
          RELAY_URL = "relay.example.com";
          OWNER_NPUB = "npub1...";
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.haven = {
      description = "haven";

      environment = lib.attrsets.mapAttrs (
        name: value: if builtins.isBool value then if value then "true" else "false" else toString value
      ) mergedSettings;

      serviceConfig = {
        CapabilityBoundingSet = "";
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = "${cfg.package}/bin/haven";
        # Create symlink to templates in the working directory
        ExecStartPre = "+${pkgs.coreutils}/bin/ln -sfT ${cfg.package}/share/haven/templates /var/lib/haven/templates";
        Group = "haven";
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
        Restart = "on-failure";
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectory = "haven";
        StateDirectory = "haven";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
        ];

        User = "haven";
        WorkingDirectory = "/var/lib/haven";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
    };

    users.groups.haven = { };

    users.users.haven = {
      description = "Haven daemon user";
      group = "haven";
      isSystemUser = true;
    };
  };

  meta.maintainers = with lib.maintainers; [
    felixzieger
  ];
}
