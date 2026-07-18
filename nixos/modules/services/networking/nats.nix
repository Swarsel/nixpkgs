{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.nats;

  format = pkgs.formats.json { };

  validateConfig =
    file:
    pkgs.callPackage (
      { nats-server, runCommand }:
      runCommand "validate-nats-conf"
        {
          nativeBuildInputs = [ nats-server ];
        }
        ''
          nats-server --config "${file}" -t
          ln -s "${file}" "$out"
        ''
    ) { };

  unvalidatedConfigFile = format.generate "nats.conf" cfg.settings;

  configFile =
    if cfg.validateConfig then validateConfig unvalidatedConfigFile else unvalidatedConfigFile;
in
{

  ### Interface

  options = {
    services.nats = {
      enable = mkEnableOption "NATS messaging system";

      dataDir = mkOption {
        default = "/var/lib/nats";

        description = ''
          The NATS data directory. Only used if JetStream is enabled, for
          storing stream metadata and messages.

          If left as the default value this directory will automatically be
          created before the NATS server starts, otherwise the sysadmin is
          responsible for ensuring the directory exists with appropriate
          ownership and permissions.
        '';

        type = types.path;
      };

      group = mkOption {
        default = "nats";
        description = "Group under which NATS runs.";
        type = types.str;
      };

      jetstream = mkEnableOption "JetStream";

      port = mkOption {
        default = 4222;

        description = ''
          Port on which to listen.
        '';

        type = types.port;
      };

      serverName = mkOption {
        default = "nats";

        description = ''
          Name of the NATS server, must be unique if clustered.
        '';

        example = "n1-c3";
        type = types.str;
      };

      settings = mkOption {
        default = { };

        description = ''
          Declarative NATS configuration. See the
          [
          NATS documentation](https://docs.nats.io/nats-server/configuration) for a list of options.
        '';

        example = literalExpression ''
          {
            jetstream = {
              max_mem = "1G";
              max_file = "10G";
            };
          };
        '';

        type = format.type;
      };

      user = mkOption {
        default = "nats";
        description = "User account under which NATS runs.";
        type = types.str;
      };

      validateConfig = mkOption {
        default = true;

        description = ''
          If true, validate nats config at build time. When the config can't
          be checked during build time, for example when it includes other
          files, disable this option.
        '';

        type = types.bool;
      };
    };
  };

  ### Implementation

  config = mkIf cfg.enable {
    services.nats.settings = {
      jetstream = optionalAttrs cfg.jetstream { store_dir = cfg.dataDir; };
      port = cfg.port;
      server_name = cfg.serverName;
    };

    systemd.services.nats = {
      after = [ "network.target" ];
      description = "NATS messaging system";

      serviceConfig = mkMerge [
        (mkIf (cfg.dataDir == "/var/lib/nats") {
          StateDirectory = "nats";
          StateDirectoryMode = "0750";
        })
        {
          # Hardening
          CapabilityBoundingSet = "";
          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          ExecStart = "${pkgs.nats-server}/bin/nats-server -c ${configFile}";
          Group = cfg.group;
          KillMode = "mixed";
          KillSignal = "SIGUSR2";
          LimitNOFILE = 800000; # JetStream requires 2 FDs open per stream.
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
          ReadOnlyPaths = [ ];
          ReadWritePaths = [ cfg.dataDir ];
          Restart = "on-failure";

          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];

          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;

          SuccessExitStatus = [
            0
            "SIGUSR2"
          ];

          SystemCallFilter = [
            "@system-service"
            "~@privileged"
          ];

          TimeoutStopSec = "150"; # must exceed lame_duck_duration, which defaults to 2min
          Type = "simple";
          UMask = "0077";
          User = cfg.user;
        }
      ];

      wantedBy = [ "multi-user.target" ];
    };

    users.groups = mkIf (cfg.group == "nats") { nats = { }; };

    users.users = mkIf (cfg.user == "nats") {
      nats = {
        description = "NATS daemon user";
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };
  };

}
