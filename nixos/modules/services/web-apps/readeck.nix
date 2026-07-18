{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    mkIf
    types
    ;
  cfg = config.services.readeck;
  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate "readeck.toml" cfg.settings;

in
{

  options = {
    services.readeck = {
      enable = mkEnableOption "Readeck";
      package = mkPackageOption pkgs "readeck" { };

      environmentFile = mkOption {
        default = null;

        description = ''
          File containing environment variables to be passed to Readeck.
          May be used to provide the Readeck secret key by setting the READECK_SECRET_KEY variable.
        '';

        type = types.nullOr types.path;
      };

      settings = mkOption {
        default = { };

        description = ''
          Additional configuration for Readeck, see
          <https://readeck.org/en/docs/configuration>
          for supported values.
        '';

        example = {
          main.log_level = "debug";
          server.port = 9000;
        };

        type = settingsFormat.type;
      };

    };
  };

  config = mkIf cfg.enable {
    systemd.services.readeck = {
      after = [ "network-online.target" ];
      description = "Readeck";

      serviceConfig = {
        DevicePolicy = "closed";
        DynamicUser = true;
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = "${lib.getExe cfg.package} serve -config ${configFile}";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "full";
        Restart = "on-failure";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
          "AF_NETLINK"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "readeck";
        SystemCallArchitectures = "native";
        Type = "simple";
        WorkingDirectory = "/var/lib/readeck";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.julienmalka ];
}
