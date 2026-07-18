{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.rust-federation-tester;

  configFile = "/run/rust-federation-tester/config.yaml";
  commonServiceConfig = {
    CapabilityBoundingSet = [ "" ];
    DevicePolicy = "closed";
    DynamicUser = true;
    LockPersonality = true;
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

    RestrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
      "AF_UNIX"
    ];

    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    RuntimeDirectory = "rust-federation-tester";
    RuntimeDirectoryPreserve = true;
    StateDirectory = "rust-federation-tester";
    SystemCallArchitectures = "native";

    SystemCallFilter = [
      "@system-service"
    ];

    # Hardening
    UMask = "0077";
    User = "rust-federation-tester";
    WorkingDirectory = "%t/rust-federation-tester";
  };

  secretsInjection = utils.genJqSecretsReplacement {
    loadCredential = true;
  } cfg.settings configFile;
in
{
  options.services.rust-federation-tester = {
    enable = lib.mkEnableOption "rust-federation-tester";

    settings = lib.mkOption {
      description = ''
        Settings representing the values in {file}`config.yaml` of the service.

        Refer to [`config.yaml.example`] for supported values.

        [`config.yaml.example`]: https://github.com/MTRNord/rust-federation-tester/blob/main/config.yaml.example
      '';

      type = lib.types.submodule {
        options = {
          database_url = lib.mkOption {
            default = "sqlite:///var/lib/rust-federation-tester/db?mode=rwc";

            description = ''
              The database to store accounts and statistics.
            '';

            example = "postgres://localhost/db?currentSchema=schema";
            type = lib.types.str;
          };

          frontend_url = lib.mkOption {
            description = ''
              URL of the service's frontend.
            '';

            example = "federation-tester.example.org";
            type = lib.types.str;
          };

          listen_addr = lib.mkOption {
            default = "[::]:8080";

            description = ''
              Address the API server should listen on.
            '';

            example = "unix:/run/rust-federation-tester/rust-federation-tester.sock";
            type = lib.types.str;
          };

          smtp = {
            enabled = lib.mkEnableOption "mail delivery for configured alerts";
          };
        };

        freeformType = lib.types.json;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.rust-federation-tester = {
      after = [ "rust-federation-tester-setup.service" ];
      description = "Matrix-Federation-Tester in Rust";
      documentation = [ "https://github.com/MTRNord/rust-federation-tester" ];
      requires = [ "rust-federation-tester-setup.service" ];

      serviceConfig = lib.mkMerge [
        commonServiceConfig
        {
          ExecSearchPath = lib.makeBinPath [ pkgs.rust-federation-tester ];
          ExecStart = "rust-federation-tester";
          Restart = "on-failure";
        }
      ];

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.rust-federation-tester-setup = {
      description = "Matrix-Federation-Tester in Rust";
      path = [ pkgs.rust-federation-tester ];

      serviceConfig = lib.mkMerge [
        commonServiceConfig
        {
          ExecStart = "${pkgs.writeShellScript "rust-federation-tester-setup" ''
            ${secretsInjection.script}

            migration up
          ''}";

          LoadCredential = secretsInjection.credentials;
          RemainAfterExit = true;
          Type = "oneshot";
        }
      ];
    };

    systemd.sockets.rust-federation-tester = {
      description = "Matrix-Federation-Tester in Rust socket";
      listenStreams = [ (lib.removePrefix "unix:" cfg.settings.listen_addr) ];
      wantedBy = [ "sockets.target" ];
    };
  };
}
