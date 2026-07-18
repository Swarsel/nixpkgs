{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    types
    mkIf
    mkOption
    mkEnableOption
    mkPackageOption
    optionalString
    ;

  cfg = config.services.yarr;
in
{
  options.services.yarr = {
    enable = mkEnableOption "Yet another rss reader";
    package = mkPackageOption pkgs "yarr" { };

    address = mkOption {
      default = "localhost";
      description = "Address to run server on.";
      type = types.str;
    };

    authFilePath = mkOption {
      default = null;
      description = "Path to a file containing username:password. `null` means no authentication required to use the service.";
      type = types.nullOr types.path;
    };

    baseUrl = mkOption {
      default = null;
      description = "Base path of the service url.";
      type = types.nullOr types.str;
    };

    environmentFile = mkOption {
      default = null;

      description = ''
        Environment file for specifying additional settings such as secrets.

        See `yarr -help` for all available options.
      '';

      type = types.nullOr types.path;
    };

    port = mkOption {
      default = 7070;
      description = "Port to run server on.";
      type = types.port;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.yarr = {
      after = [ "network-online.target" ];
      description = "Yet another rss reader";
      environment.XDG_CONFIG_HOME = "/var/lib/yarr/.config";

      serviceConfig = {
        DevicePolicy = "closed";
        DynamicUser = true;
        EnvironmentFile = cfg.environmentFile;

        ExecStart = ''
          ${lib.getExe cfg.package} \
            -db storage.db \
            -addr "${cfg.address}:${toString cfg.port}" \
            ${optionalString (cfg.baseUrl != null) "-base ${cfg.baseUrl}"} \
            ${optionalString (cfg.authFilePath != null) "-auth-file /run/credentials/yarr.service/authfile"}
        '';

        LoadCredential = mkIf (cfg.authFilePath != null) "authfile:${cfg.authFilePath}";
        LockPersonality = "yes";
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
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
        RemoveIPC = true;
        Restart = "on-failure";
        RestrictAddressFamilies = "AF_INET AF_INET6";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        StateDirectory = "yarr";
        StateDirectoryMode = "0700";
        Type = "simple";
        UMask = "0077";
        WorkingDirectory = "/var/lib/yarr";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta.maintainers = with lib.maintainers; [ christoph-heiss ];
}
