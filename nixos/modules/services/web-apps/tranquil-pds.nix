{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.tranquil-pds;

  inherit (lib) types mkPackageOption mkOption;

  settingsFormat = pkgs.formats.toml { };
in
{
  options.services.tranquil-pds = {
    enable = lib.mkEnableOption "tranquil-pds AT Protocol personal data server";
    package = mkPackageOption pkgs "tranquil-pds" { };

    dataDir = mkOption {
      default = "/var/lib/tranquil-pds";
      description = "Working directory for tranquil-pds. Also expected to be used for data (blobs)";
      type = types.str;
    };

    database.createLocally = mkOption {
      default = false;

      description = ''
        Create the postgres database and user on the local host.
      '';

      type = types.bool;
    };

    environmentFiles = mkOption {
      default = [ ];

      description = ''
        File to load environment variables from. Loaded variables override
        values set in {option}`environment`.

        Use it to set values of `JWT_SECRET`, `DPOP_SECRET` and `MASTER_KEY`.

        Generate these with:
        ```
        openssl rand -base64 48
        ```
      '';

      type = types.listOf types.path;
    };

    group = mkOption {
      default = "tranquil-pds";
      description = "Group under which tranquil-pds runs";
      type = types.str;
    };

    settings = mkOption {
      description = ''
        Configuration options to set for the service. Secrets should be
        specified using {option}`environmentFile`.

        Refer to <https://tangled.org/tranquil.farm/tranquil-pds/blob/main/example.toml>
        for available configuration options.
      '';

      type = types.submodule {
        options = {
          frontend = {
            dir = mkPackageOption pkgs "tranquil-pds-frontend" { };

            enabled =
              lib.mkEnableOption "serving the frontend from the backend. Disable to serve the frontend manually"
              // {
                default = true;
              };
          };

          server = {
            host = mkOption {
              default = "127.0.0.1";
              description = "Host for tranquil-pds to listen on";
              type = types.str;
            };

            hostname = mkOption {
              default = "";
              description = "The public-facing hostname of the PDS";
              example = "pds.example.com";
              type = types.str;
            };

            max_blob_size = mkOption {
              default = 10737418240; # 10 GiB
              description = "Maximum allowed blob size in bytes.";
              type = types.int;
            };

            port = mkOption {
              default = 3000;
              description = "Port for tranquil-pds to listen on";
              type = types.int;
            };
          };

          storage = {
            path = mkOption {
              default = "${cfg.dataDir}/blobs";
              defaultText = "\${cfg.dataDir}/blobs";
              description = "Directory for storing blobs";
              type = types.path;
            };
          };

          tranquil_store = {
            data_dir = mkOption {
              default = "${cfg.dataDir}/store";
              defaultText = "\${cfg.dataDir}/store";
              description = "Directory for tranquil-store files";
              type = types.path;
            };
          };
        };

        freeformType = settingsFormat.type;
      };
    };

    user = mkOption {
      default = "tranquil-pds";
      description = "User under which tranquil-pds runs";
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.database.createLocally {
        services.postgresql = {
          enable = true;
          ensureDatabases = [ cfg.user ];

          ensureUsers = [
            {
              ensureDBOwnership = true;
              name = cfg.user;
            }
          ];
        };

        services.tranquil-pds.settings.database.url =
          lib.mkDefault "postgresql:///${cfg.user}?host=/run/postgresql";

        systemd.services.tranquil-pds = {
          after = [ "postgresql.service" ];
          requires = [ "postgresql.service" ];
        };
      })

      {
        environment.etc = {
          "tranquil-pds/config.toml".source =
            let
              conf = settingsFormat.generate "tranquil-pds.toml" cfg.settings;
            in
            pkgs.runCommandLocal "validated-tranquil-config" { nativeBuildInputs = [ cfg.package ]; } ''
              tranquil-server --config ${conf} validate --ignore-secrets
              ln -s ${conf} $out
            '';
        };

        systemd.services.tranquil-pds = {
          after = [ "network-online.target" ];
          description = "Tranquil PDS - ATProtocol Personal Data Server";

          serviceConfig = {
            CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
            EnvironmentFile = cfg.environmentFiles;
            ExecStart = lib.getExe cfg.package;
            Group = cfg.group;
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
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

            ReadWritePaths = [
              cfg.settings.storage.path
            ];

            RemoveIPC = true;
            Restart = "on-failure";
            RestartSec = 5;

            RestrictAddressFamilies = [
              "AF_INET"
              "AF_INET6"
              "AF_UNIX"
            ];

            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            StateDirectory = "tranquil-pds";
            SystemCallArchitectures = "native";

            SystemCallFilter = [
              "@system-service"
              "~@privileged @resources"
            ];

            UMask = "0077";
            User = cfg.user;
            WorkingDirectory = cfg.dataDir;
          };

          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
        };

        systemd.tmpfiles.settings."tranquil-pds" =
          lib.genAttrs
            [
              cfg.dataDir
              cfg.settings.storage.path
              cfg.settings.tranquil_store.data_dir
            ]
            (_: {
              d = {
                inherit (cfg) user group;
                mode = "0750";
              };
            });

        users.groups.${cfg.group} = { };

        users.users.${cfg.user} = {
          inherit (cfg) group;
          home = cfg.dataDir;
          isSystemUser = true;
        };
      }
    ]
  );

  meta.maintainers = with lib.maintainers; [ nelind ];
}
