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
    types
    ;

  cfg = config.services.c2fmzq-server;

  argsFormat = {
    generate = lib.cli.toCommandLineShellGNU {
      explicitBool = true;
    };

    type =
      with lib.types;
      attrsOf (
        nullOr (oneOf [
          bool
          int
          str
        ])
      );
  };
in
{
  options.services.c2fmzq-server = {
    enable = mkEnableOption "c2fmzq-server";
    package = mkPackageOption pkgs "c2fmzq" { };

    bindIP = mkOption {
      default = "127.0.0.1";
      description = "The local address to use.";
      type = types.str;
    };

    passphraseFile = mkOption {
      description = "Path to file containing the database passphrase";
      example = "/run/secrets/c2fmzq/pwfile";
      type = types.str;
    };

    port = mkOption {
      default = 8080;
      description = "The local port to use.";
      type = types.port;
    };

    settings = mkOption {
      description = ''
        Configuration for c2FmZQ-server passed as CLI arguments.
        Run {command}`c2FmZQ-server help` for supported values.
      '';

      example = {
        allow-new-accounts = true;
        auto-approve-new-accounts = true;
        enable-webapp = true;
        encrypt-metadata = true;
        verbose = 3;
      };

      type = types.submodule {
        options = {
          address = mkOption {
            default = "${cfg.bindIP}:${toString cfg.port}";
            internal = true;
            type = types.str;
          };

          database = mkOption {
            default = "%S/c2fmzq-server/data";
            description = "Path of the database";
            type = types.str;
          };

          verbose = mkOption {
            default = 2;
            description = "The level of logging verbosity: 1:Error 2:Info 3:Debug";
            type = types.ints.between 1 3;
          };
        };

        freeformType = argsFormat.type;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.c2fmzq-server = {
      after = [
        "network.target"
        "network-online.target"
      ];

      description = "c2FmZQ-server";
      documentation = [ "https://github.com/c2FmZQ/c2FmZQ/blob/main/README.md" ];

      serviceConfig = {
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        DynamicUser = true;
        Environment = "C2FMZQ_PASSPHRASE_FILE=%d/passphrase-file";
        ExecStart = "${lib.getExe cfg.package} ${argsFormat.generate cfg.settings}";
        IPAccounting = true;
        IPAddressAllow = cfg.bindIP;
        IPAddressDeny = "any";
        LoadCredential = "passphrase-file:${cfg.passphraseFile}";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateIPC = true;
        PrivateTmp = true;
        PrivateUsers = true;
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
        SocketBindAllow = cfg.port;
        SocketBindDeny = "any";
        StateDirectory = "c2fmzq-server";
        SystemCallArchitectures = "native";

        SystemCallFilter = [
          "@system-service"
          "~@privileged @obsolete"
        ];
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
    };
  };

  meta = {
    doc = ./c2fmzq-server.md;
    maintainers = with lib.maintainers; [ hmenke ];
  };
}
