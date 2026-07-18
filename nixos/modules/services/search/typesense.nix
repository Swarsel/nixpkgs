{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatMapStringsSep
    generators
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;

  cfg = config.services.typesense;
  settingsFormatIni = pkgs.formats.ini {
    listToValue = concatMapStringsSep " " (generators.mkValueStringDefault { });

    mkKeyValue = generators.mkKeyValueDefault {
      mkValueString = v: if v == null then "" else generators.mkValueStringDefault { } v;
    } "=";
  };
  configFile = settingsFormatIni.generate "typesense.ini" cfg.settings;
in
{
  options.services.typesense = {
    enable = mkEnableOption "typesense";
    package = mkPackageOption pkgs "typesense" { };

    apiKeyFile = mkOption {
      description = ''
        Sets the admin api key for typesense. Always use this option
        instead of {option}`settings.server.api-key` to prevent the key
        from being written to the world-readable nix store.
      '';

      type = types.path;
    };

    settings = mkOption {
      default = { };
      description = "Typesense configuration. Refer to [the documentation](https://typesense.org/docs/0.24.1/api/server-configuration.html) for supported values.";

      type = types.submodule {
        options.server = {
          api-address = mkOption {
            description = "Address to which Typesense API service binds.";
            type = types.str;
          };

          api-port = mkOption {
            default = 8108;
            description = "Port on which the Typesense API service listens.";
            type = types.port;
          };

          data-dir = mkOption {
            default = "/var/lib/typesense";
            description = "Path to the directory where data will be stored on disk.";
            type = types.str;
          };
        };

        freeformType = settingsFormatIni.type;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.typesense = {
      after = [ "network.target" ];
      description = "Typesense search engine";

      script = ''
        export TYPESENSE_API_KEY=$(cat ${cfg.apiKeyFile})
        exec ${cfg.package}/bin/typesense-server --config ${configFile}
      '';

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = "";
        DynamicUser = true;
        Group = "typesense";
        LockPersonality = true;
        # MemoryDenyWriteExecute = true; needed since 0.25.1
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
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

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "typesense";
        StateDirectoryMode = "0750";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];

        UMask = "0077";
        User = "typesense";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
