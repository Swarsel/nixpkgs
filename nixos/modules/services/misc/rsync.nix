{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.rsync;
  inherit (lib) types;
  inherit (utils.systemdUtils.unitOptions) unitOption;
in
{
  options.services.rsync = {
    enable = lib.mkEnableOption "periodic directory syncing via rsync";
    package = lib.mkPackageOption pkgs "rsync" { };

    jobs = lib.mkOption {
      default = { };

      description = ''
        Synchronization jobs to run.
      '';

      type = types.attrsOf (
        types.submodule {
          options = {
            destination = lib.mkOption {
              description = ''
                Destination directory.
              '';

              example = "/srv/dst";
              type = types.str;
            };

            group = lib.mkOption {
              default = "root";

              description = ''
                The name of an existing user group under which the rsync process should run.
              '';

              type = types.str;
            };

            inhibit = lib.mkOption {
              default = [ ];

              description = ''
                Run the rsync process with an inhibition lock taken;
                see {manpage}`systemd-inhibit(1)` for a list of possible operations.
              '';

              example = [
                "sleep"
              ];

              type = types.listOf (types.strMatching "^[^:]+$");
            };

            settings = lib.mkOption {
              default = { };

              description = ''
                Settings that should be passed to rsync via long options.
                See {manpage}`rsync(1)` for available options.
              '';

              example = {
                archive = true;
                delete = true;
                mkpath = true;
                verbose = true;
              };

              type =
                let
                  simples = [
                    types.bool
                    types.str
                    types.int
                    types.float
                  ];
                in
                types.attrsOf (
                  types.oneOf (
                    simples
                    ++ [
                      (types.listOf (types.oneOf simples))
                    ]
                  )
                );
            };

            sources = lib.mkOption {
              description = ''
                Source directories.
              '';

              example = [
                "/srv/src1/"
                "/srv/src2/"
              ];

              type = types.nonEmptyListOf types.str;
            };

            timerConfig = lib.mkOption {
              default = {
                OnCalendar = "daily";
                Persistent = true;
              };

              description = ''
                When to run the job.
              '';

              type = types.nullOr (types.attrsOf unitOption);
            };

            user = lib.mkOption {
              default = "root";

              description = ''
                The name of an existing user account under which the rsync process should run.
              '';

              type = types.str;
            };
          };
        }
      );
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = lib.mkMerge (
      lib.mapAttrsToList (
        jobName: job:
        let
          systemdName = "rsync-job-${jobName}";
          description = "Directory syncing via rsync job ${jobName}";
        in
        {
          services.${systemdName} = {
            inherit description;

            serviceConfig = {
              ExecStart =
                let
                  settingsToCommandLine = lib.cli.toCommandLineGNU {
                    isLong = _: true;
                  };

                  inhibitArgs = [
                    (lib.getExe' config.systemd.package "systemd-inhibit")
                    "--mode"
                    "block"
                    "--who"
                    description
                    "--what"
                    (lib.concatStringsSep ":" job.inhibit)
                    "--why"
                    "Scheduled rsync job ${jobName}"
                    "--"
                  ];

                  args =
                    (lib.optionals (job.inhibit != [ ]) inhibitArgs)
                    ++ [ (lib.getExe cfg.package) ]
                    ++ (settingsToCommandLine job.settings)
                    ++ [ "--" ]
                    ++ job.sources
                    ++ [ job.destination ];
                in
                utils.escapeSystemdExecArgs args;

              Group = job.group;
              LockPersonality = true;
              MemoryDenyWriteExecute = true;
              NoNewPrivileges = true;
              PrivateDevices = true;
              ProtectControlGroups = true;
              ProtectKernelModules = true;
              ProtectKernelTunables = true;
              ProtectSystem = "full";
              Type = "oneshot";
              User = job.user;
            };
          };

          timers.${systemdName} = {
            inherit description;
            inherit (job) timerConfig;

            wantedBy = [
              "timers.target"
            ];
          };
        }
      ) cfg.jobs
    );
  };

  meta.maintainers = [
    lib.maintainers.lukaswrz
  ];
}
