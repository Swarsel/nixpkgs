{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.soft-serve;
  configFile = format.generate "config.yaml" cfg.settings;
  format = pkgs.formats.yaml { };
  docUrl = "https://charm.sh/blog/self-hosted-soft-serve/";
  stateDir = "/var/lib/soft-serve";
in
{
  options = {
    services.soft-serve = {
      enable = lib.mkEnableOption "soft-serve";
      package = lib.mkPackageOption pkgs "soft-serve" { };

      settings = lib.mkOption {
        default = { };

        description = ''
          The contents of the configuration file for soft-serve.

          See <${docUrl}>.
        '';

        example = lib.literalExpression ''
          {
            name = "user's repos";
            log_format = "text";
            ssh = {
              listen_addr = ":23231";
              public_url = "ssh://localhost:23231";
              max_timeout = 30;
              idle_timeout = 120;
            };
            stats.listen_addr = ":23233";
          }
        '';

        type = format.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.soft-serve = {
      after = [ "network-online.target" ];
      description = "Soft Serve git server";
      documentation = [ docUrl ];
      environment.SOFT_SERVE_CONFIG_LOCATION = configFile;
      environment.SOFT_SERVE_DATA_PATH = stateDir;
      requires = [ "network-online.target" ];

      serviceConfig = {
        CapabilityBoundingSet = "";
        DynamicUser = true;
        # Hooks must be executable, but DynamicUser mounts /var/lib/private as noexec
        ExecPaths = "${stateDir}/repos";
        ExecStart = "${lib.getExe cfg.package} serve";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateMounts = true;
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
        Restart = "always";

        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "soft-serve";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@cpu-emulation @debug @keyring @module @mount @obsolete @privileged @raw-io @reboot @setuid @swap"
        ];

        Type = "simple";
        UMask = "0027";
        WorkingDirectory = stateDir;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [ lib.maintainers.dadada ];
}
