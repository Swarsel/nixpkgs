{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.radicle.ci.broker;

  settingsFormat = pkgs.formats.json { };
  configFile = pkgs.runCommand "ci-broker.json" { } (
    ''
      cp ${settingsFormat.generate "ci-broker.json" cfg.settings} $out
    ''
    + lib.optionalString cfg.checkConfig ''
      ${lib.getExe' cfg.package "cib"} --config $out config
    ''
  );

  RAD_HOME = "/var/lib/radicle";

  # Convenient wrapper to run `cibtool` in the namespaces of `radicle-ci-broker.service`
  cibtool-system = pkgs.writeShellScriptBin "cibtool-system" ''
    set -o allexport
    ${lib.toShellVars {
      inherit RAD_HOME;
      HOME = RAD_HOME;
    }}
    # Note that --env is not used to preserve host's envvars like $TERM
    exec ${lib.getExe' pkgs.util-linux "nsenter"} -a \
      -t "$(${lib.getExe' config.systemd.package "systemctl"} show -P MainPID radicle-ci-broker.service)" \
      -S "$(${lib.getExe' config.systemd.package "systemctl"} show -P UID radicle-ci-broker.service)" \
      -G "$(${lib.getExe' config.systemd.package "systemctl"} show -P GID radicle-ci-broker.service)" \
      ${lib.getExe' cfg.package "cibtool"} --db ${lib.escapeShellArg cfg.settings.db} "$@"
  '';
in

{
  options.services.radicle.ci.broker = {
    enable = lib.mkEnableOption "radicle-ci-broker";
    package = lib.mkPackageOption pkgs "radicle-ci-broker" { };

    checkConfig =
      lib.mkEnableOption "checking the {file}`ci-broker.yaml` file resulting from [](#opt-services.radicle.ci.broker.settings)"
      // {
        default = true;
        example = false;
      };

    enableHardening = lib.mkEnableOption "systemd hardening" // {
      default = true;
      example = false;
    };

    logDir = lib.mkOption {
      default = "/var/log/radicle-ci";
      description = "Log directory of radicle-ci-broker.";
      type = lib.types.path;
    };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration of radicle-ci-broker.
        See <https://radicle.network/nodes/seed.radicle.dev/rad:zwTxygwuz5LDGBq255RA2CbNGrz8/tree/doc/userguide.md#configuration> for more information.
      '';

      example = lib.literalExpression ''
        {
          adapters.native = {
            command = lib.getExe pkgs.radicle-native-ci;
            config = { };
            config_env = "RADICLE_NATIVE_CI";
            env.PATH = lib.makeBinPath (with pkgs; [ bash coreutils ]);
          };

          triggers = [
            {
              adapter = "native";
              filters = [
                {
                  And = [
                    { HasFile = ".radicle/native.yaml"; }
                    { Node = "z6MkgEMYod7Hxfy9qCvDv5hYHkZ4ciWmLFgfvm3Wn1b2w2FV"; }
                    {
                      Or = [
                        "DefaultBranch"
                        "PatchCreated"
                        "PatchUpdated"
                      ];
                    }
                  ];
                }
              ];
            }
          ];
        }
      '';

      type = lib.types.submodule {
        options = {
          adapters = lib.mkOption {
            default = { };

            description = ''
              CI adapters.
              See also the options under [services.radicle.ci.adapters](#opt-services.radicle.ci.adapters.native.instances).
            '';

            type = lib.types.attrsOf (
              lib.types.submodule {
                options = {
                  command = lib.mkOption {
                    description = "Adapter command to run.";
                    type = lib.types.str;
                  };

                  env = lib.mkOption {
                    default = { };
                    description = "Environment variables to add when running the adapter.";
                    type = lib.types.attrsOf settingsFormat.type;
                  };
                };

                freeformType = settingsFormat.type;
              }
            );
          };

          db = lib.mkOption {
            defaultText = lib.literalExpression ''"''${config.services.radicle.ci.broker.stateDir}/ci-broker.db"'';
            description = "Database file path.";
            type = lib.types.path;
          };

          report_dir = lib.mkOption {
            defaultText = lib.literalExpression ''"''${config.services.radicle.ci.broker.stateDir}/reports"'';
            description = "Directory where HTML and JSON report pages are written.";
            type = lib.types.nullOr lib.types.path;
          };

          triggers = lib.mkOption {
            default = [ ];
            description = "CI triggers.";

            type = lib.types.listOf (
              lib.types.submodule {
                options = {
                  adapter = lib.mkOption {
                    description = "Adapter name.";
                    type = lib.types.str;
                  };

                  filters = lib.mkOption {
                    description = "Trigger filter.";
                    type = lib.types.listOf settingsFormat.type;
                  };
                };

                freeformType = settingsFormat.type;
              }
            );
          };
        };

        freeformType = settingsFormat.type;
      };
    };

    stateDir = lib.mkOption {
      default = "/var/lib/radicle-ci";
      description = "State directory of radicle-ci-broker.";
      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.radicle.enable;
        message = "radicle-ci-broker requires a local radicle node to be running.";
      }
    ];

    environment.systemPackages = [ cibtool-system ];

    services.radicle.ci.broker.settings = {
      db = lib.mkDefault "${cfg.stateDir}/ci-broker.db";
      report_dir = lib.mkDefault "${cfg.stateDir}/reports";
    };

    systemd.services.radicle-ci-broker = {
      after = [ "radicle-node.service" ];
      bindsTo = [ "radicle-node.service" ];
      environment = { inherit RAD_HOME; };

      serviceConfig = lib.mkMerge [
        {
          BindReadOnlyPaths = config.systemd.services.radicle-node.serviceConfig.BindReadOnlyPaths ++ [
            "/run/credentials/radicle-ci-broker.service/dev.radicle.node.secret:/var/lib/radicle/keys/radicle"
          ];

          ExecStart = "${lib.getExe' cfg.package "cib"} --config ${configFile} process-events";
          Group = config.users.groups.radicle.name;
          ImportCredential = config.systemd.services.radicle-node.serviceConfig.ImportCredential or [ ];
          LoadCredential = config.systemd.services.radicle-node.serviceConfig.LoadCredential or [ ];
          LogsDirectory = lib.mkIf (cfg.logDir == "/var/log/radicle-ci") "radicle-ci";
          ReadWritePaths = [ RAD_HOME ];
          Restart = "always";
          RuntimeDirectory = "radicle-ci-broker";
          StateDirectory = lib.mkIf (cfg.stateDir == "/var/lib/radicle-ci") "radicle-ci";
          User = config.users.users.radicle.name;
          WorkingDirectory = "/run/radicle-ci-broker";
        }

        (lib.mkIf cfg.enableHardening {
          AmbientCapabilities = "";
          CapabilityBoundingSet = [ "" ];
          DevicePolicy = "closed";
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
          RestrictAddressFamilies = [ "AF_INET AF_INET6 AF_UNIX" ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
            "~@resources"
          ];

          UMask = "0066";
        })
      ];

      wantedBy = [ "multi-user.target" ];
    };

    systemd.tmpfiles.settings.radicle-ci-broker.${cfg.settings.report_dir}.d = {
      group = config.users.groups.radicle.name;
      user = config.users.users.radicle.name;
    };
  };

  meta.teams = [ lib.teams.radicle ];
}
