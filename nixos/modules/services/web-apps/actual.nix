{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;

  cfg = config.services.actual;

  formatType = pkgs.formats.json { };
in
{
  options.services.actual = {
    enable = mkEnableOption "actual, a privacy focused app for managing your finances";
    package = mkPackageOption pkgs "actual-server" { };

    group = lib.mkOption {
      default = null;

      description = ''
        Group account under which Actual runs.

        If null is specified (default), a temporary user will be created by systemd. Otherwise won't be automatically created by the service.
      '';

      type = lib.types.nullOr lib.types.str;
    };

    openFirewall = mkOption {
      default = false;
      description = "Whether to open the firewall for the specified port.";
      type = types.bool;
    };

    settings = mkOption {
      default = { };

      description = ''
        Server settings, refer to [the documentation](https://actualbudget.org/docs/config/) for available options.
        You can specify secret values in this configuration by setting `somevalue._secret = "/path/to/file"` instead of setting `somevalue` directly.
      '';

      type = types.submodule {
        options = {
          dataDir = lib.mkOption {
            default = "/var/lib/actual";

            description = ''
              Directory under which Actual runs and saves its data.

              Changing this after you already have a working instance may make Actual fail to start, even if you move all files in the data dir. If migration is needed, refer to [this comment](https://github.com/actualbudget/actual/issues/3957#issuecomment-2567076794) for a fix.
            '';

            type = lib.types.str;
          };

          hostname = mkOption {
            default = "::";
            description = "The address to listen on";
            type = types.str;
          };

          port = mkOption {
            default = 3000;
            description = "The port to listen on";
            type = types.port;
          };

          serverFiles = lib.mkOption {
            default = "${cfg.settings.dataDir}/server-files";
            defaultText = "\${cfg.settings.dataDir}/server-files";

            description = ''
              The server will put an account.sqlite file in this directory, which will contain the (hashed) server password, a list of all the budget files the server knows about, and the active session token (along with anything else the server may want to store in the future).
            '';

            type = lib.types.str;
          };

          userFiles = lib.mkOption {
            default = "${cfg.settings.dataDir}/user-files";
            defaultText = "\${cfg.settings.dataDir}/user-files";

            description = ''
              The server will put all the budget files in this directory as binary blobs.
            '';

            type = lib.types.str;
          };
        };

        freeformType = formatType.type;
      };
    };

    user = lib.mkOption {
      default = null;

      description = ''
        User account under which Actual runs.

        If null is specified (default), a temporary user will be created by systemd. Otherwise won't be automatically created by the service.
      '';

      type = lib.types.nullOr lib.types.str;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.settings.port ];

    systemd.services.actual = {
      after = [ "network.target" ];
      description = "Actual server, a local-first personal finance app";
      environment.ACTUAL_CONFIG_PATH = "/run/actual/config.json";

      preStart = ''
        # Generate config including secret values.
        ${utils.genJqSecretsReplacementSnippet cfg.settings "/run/actual/config.json"}
      '';

      serviceConfig = {
        # Hardening
        CapabilityBoundingSet = "";
        ExecStart = getExe cfg.package;
        LimitNOFILE = "1048576";
        LockPersonality = true;
        PrivateDevices = true;
        PrivateTmp = true;
        #MemoryDenyWriteExecute = true; # Leads to coredump because V8 does JIT
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

        ReadWritePaths = [
          cfg.settings.dataDir
          cfg.settings.serverFiles
          cfg.settings.userFiles
        ];

        Restart = "always";

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];

        RestrictNamespaces = true;
        RestrictRealtime = true;
        RuntimeDirectory = "actual";
        StateDirectory = "actual";
        StateDirectoryMode = "0700";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "@pkey"
        ];

        UMask = "0077";
        WorkingDirectory = cfg.settings.dataDir;
      }
      // (
        if cfg.user != null then
          {
            DynamicUser = false;
            Group = cfg.group;
            User = cfg.user;
          }
        else
          {
            DynamicUser = true;
            Group = "actual";
            User = "actual";
          }
      );

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = [
    lib.maintainers.oddlama
    lib.maintainers.patrickdag
  ];
}
