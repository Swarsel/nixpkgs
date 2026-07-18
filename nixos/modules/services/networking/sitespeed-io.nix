{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.sitespeed-io;
  format = pkgs.formats.json { };
in
{
  options.services.sitespeed-io = {
    enable = lib.mkEnableOption "Sitespeed.io";
    package = lib.mkPackageOption pkgs "sitespeed-io" { };

    dataDir = lib.mkOption {
      default = "/var/lib/sitespeed-io";
      description = "The base sitespeed-io data directory.";
      type = lib.types.str;
    };

    period = lib.mkOption {
      default = "hourly";

      description = ''
        Systemd calendar expression when to run. See {manpage}`systemd.time(7)`.
      '';

      type = lib.types.str;
    };

    runs = lib.mkOption {
      default = [ ];

      description = ''
        A list of run configurations. The service will call sitespeed-io once
        for every run listed here. This lets you examine different websites
        with different sitespeed-io settings.
      '';

      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            extraArgs = lib.mkOption {
              default = [ ];

              description = ''
                Extra command line arguments to pass to the program.
              '';

              type = with lib.types; listOf str;
            };

            settings = lib.mkOption {
              default = { };

              description = ''
                Configuration for sitespeed-io, see
                <https://www.sitespeed.io/documentation/sitespeed.io/configuration/>
                for available options. The value here will be directly transformed to
                JSON and passed as `--config` to the program.
              '';

              type = lib.types.submodule {
                options = { };
                freeformType = format.type;
              };
            };

            urls = lib.mkOption {
              default = [ ];

              description = ''
                URLs the service should monitor.
              '';

              type = with lib.types; listOf str;
            };
          };
        }
      );
    };

    user = lib.mkOption {
      default = "sitespeed-io";
      description = "User account under which sitespeed-io runs.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.runs != [ ];
        message = "At least one run must be configured.";
      }
      {
        assertion = lib.all (run: run.urls != [ ]) cfg.runs;
        message = "All runs must have at least one url configured.";
      }
    ];

    systemd.services.sitespeed-io = {
      description = "Check website status";
      preStart = "chmod u+w -R ${cfg.dataDir}"; # Make sure things are writable

      script =
        (lib.concatMapStrings (run: ''
          ${lib.getExe cfg.package} \
            --config ${format.generate "sitespeed.json" run.settings} \
            ${lib.escapeShellArgs run.extraArgs} \
            ${builtins.toFile "urls.txt" (lib.concatLines run.urls)} &
        '') cfg.runs)
        + ''
          wait
        '';

      serviceConfig = {
        User = cfg.user;
        WorkingDirectory = cfg.dataDir;
      };

      startAt = cfg.period;
    };

    users = {
      extraGroups.${cfg.user} = { };

      extraUsers.${cfg.user} = {
        createHome = true;
        group = cfg.user;
        home = cfg.dataDir;
        homeMode = "755";
        isSystemUser = true;
      };
    };
  };
}
