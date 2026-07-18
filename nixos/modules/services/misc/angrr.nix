{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.angrr;
  direnvCfg = config.programs.direnv.angrr;
  toml = pkgs.formats.toml { };
  exampleSettings = {
    profile-policies = {
      system = {
        keep-booted-system = true;
        keep-current-system = true;
        keep-latest-n = 5;

        keep-n-per-bucket = [
          {
            bucket-amount = 7;
            bucket-window = "1 day";
          }
          {
            bucket-amount = 4;
            bucket-window = "1 week";
          }
        ];

        keep-since = "14d";
        profile-paths = [ "/nix/var/nix/profiles/system" ];
      };

      user = {
        enable = false;
        keep-booted-system = false;
        keep-current-system = false;
        keep-latest-n = 1;
        keep-since = "1d";

        profile-paths = [
          "~/.local/state/nix/profiles/profile"
          "/nix/var/nix/profiles/per-user/root/profile"
        ];
      };
    };

    temporary-root-policies = {
      direnv = {
        path-regex = "/\\.direnv/";
        period = "14d";
      };

      result = {
        path-regex = "/result[^/]*$";
        period = "3d";
      };
    };
  };
  settingsOptions = {
    options = {
      owned-only = lib.mkOption {
        default = "auto";

        description = ''
          Only monitors owned symbolic link target of GC roots.

          - "auto": behaves like true for normal users, false for root.
          - "true": only monitor GC roots owned by the current user.
          - "false": monitor all GC roots.
        '';

        type =
          with lib.types;
          enum [
            "auto"
            "true"
            "false"
          ];
      };

      profile-policies = lib.mkOption {
        default = { };

        description = ''
          Profile GC root policies.
        '';

        type = with lib.types; attrsOf (submodule profilePolicyOptions);
      };

      temporary-root-policies = lib.mkOption {
        default = { };

        description = ''
          Policies for temporary GC roots(e.g. result and direnv).
        '';

        type = with lib.types; attrsOf (submodule temporaryRootPolicyOptions);
      };

      touch = {
        project-globs = lib.mkOption {
          default = [
            "!.git"
          ];

          description = ''
            List of glob patterns to include or exclude files when touching GC roots.

            Only applied when `angrr touch` is invoked with the `--project` flag.
            Patterns use an inverted gitignore-style semantics.
            See <https://docs.rs/ignore/latest/ignore/overrides/struct.OverrideBuilder.html#method.add>.
          '';

          type = with lib.types; listOf str;
        };
      };
    };

    freeformType = toml.type;
  };
  commonPolicyOptions = {
    options = {
      enable = lib.mkEnableOption "this angrr policy" // {
        default = true;
        example = false;
      };
    };
  };
  temporaryRootPolicyOptions = {
    imports = [ commonPolicyOptions ];

    options = {
      filter = lib.mkOption {
        default = null;

        description = ''
          External filter program to further filter GC roots matched by this policy.
        '';

        type = with lib.types; nullOr (submodule filterOptions);
      };

      ignore-prefixes = lib.mkOption {
        default = null;

        description = ''
          List of path prefixes to ignore.

          If null is specified, angrr builtin settings will be used.
        '';

        type = with lib.types; nullOr (listOf str);
      };

      ignore-prefixes-in-home = lib.mkOption {
        default = null;

        description = ''
          Path prefixes to ignore under home directory.

          If null is specified, angrr builtin settings will be used.
        '';

        type = with lib.types; nullOr (listOf str);
      };

      path-regex = lib.mkOption {
        description = ''
          Regex pattern to match the GC root path.
        '';

        type = lib.types.str;
      };

      period = lib.mkOption {
        default = null;

        description = ''
          Retention period for the GC roots matched by this policy.
        '';

        type = with lib.types; nullOr str;
      };

      priority = lib.mkOption {
        default = 100;

        description = ''
          Priority of this policy.

          Lower number means higher priority, if multiple policies monitor the
          same path, the one with higher priority will be applied.
        '';

        type = lib.types.int;
      };
    };

    freeformType = toml.type;
  };
  profilePolicyOptions = {
    imports = [ commonPolicyOptions ];

    options = {
      keep-booted-system = lib.mkOption {
        default = false;

        description = ''
          Whether to keep the last booted system generation. Only useful for system profiles.
        '';

        type = lib.types.bool;
      };

      keep-current-system = lib.mkOption {
        default = false;

        description = ''
          Whether to keep the current system generation. Only useful for system profiles.
        '';

        type = lib.types.bool;
      };

      keep-latest-n = lib.mkOption {
        default = null;

        description = ''
          Keep the latest N GC roots in this profile.
        '';

        type = with lib.types; nullOr int;
      };

      keep-n-per-bucket = lib.mkOption {
        default = [ ];

        description = ''
          Specify a list of rules having n, bucket-window, and bucket-amount attributes.
        '';

        type = with lib.types; listOf (submodule keepNPerBucketOptions);
      };

      keep-since = lib.mkOption {
        default = null;

        description = ''
          Retention period for the GC roots in this profile.
        '';

        type = with lib.types; nullOr str;
      };

      profile-paths = lib.mkOption {
        description = ''
          Paths to the Nix profile.

          When angrr runs in owned-only mode, and the option begins with `~`,
          it will be expanded to the home directory of the current user.

          When angrr does not run in owned-only mode, and the option begins with `~`,
          it will be expanded to the home of all users discovered respectively.
        '';

        type = with lib.types; listOf str;
      };
    };

    freeformType = toml.type;
  };
  filterOptions = {
    options = {
      arguments = lib.mkOption {
        default = [ ];

        description = ''
          Extra command-line arguments pass to the external filter program.
        '';

        type = with lib.types; listOf str;
      };

      program = lib.mkOption {
        description = ''
          Path to the external filter program.
        '';

        type = lib.types.str;
      };
    };

    freeformType = toml.type;
  };
  keepNPerBucketOptions = {
    options = {
      bucket-amount = lib.mkOption {
        default = 1;

        description = ''
          The number of buckets to keep.
        '';

        type = lib.types.int;
      };

      bucket-window = lib.mkOption {
        description = ''
          The duration of the bucket window.
        '';

        type = lib.types.str;
      };

      n = lib.mkOption {
        default = 1;

        description = ''
          Retain n generations every bucket-window duration for bucket-amount buckets.
        '';

        type = lib.types.int;
      };
    };

    freeformType = toml.type;
  };

  # toml.generate does not support null values, we need to filter them out first
  filteredSettings = lib.filterAttrsRecursive (name: value: value != null) cfg.settings;
  originalConfigFile = toml.generate "angrr.toml" filteredSettings;
  validatedConfigFile = pkgs.runCommand "angrr-config.toml" { } ''
    ${lib.getExe cfg.package} validate --config "${originalConfigFile}" > $out
  '';

  configFileMigrationMsg = ''
    This option has been removed since angrr 0.2.0.
    Please use `services.angrr.settings` to configure retention policies through configuration file.

    See <https://github.com/linyinfeng/angrr/tree/main?tab=readme-ov-file#nixos-module-usage> for a configuration example.
  '';
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "angrr" "removeRoot" ] configFileMigrationMsg)
    (lib.mkRemovedOptionModule [ "services" "angrr" "ownedOnly" ] configFileMigrationMsg)
  ];

  options = {
    programs.direnv.angrr = {
      enable = lib.mkEnableOption "angrr direnv integration" // {
        default = true;
        example = false;
      };

      autoUse = lib.mkOption {
        default = true;

        description = ''
          Whether to automatically use angrr before loading .envrc.
        '';

        example = false;
        type = lib.types.bool;
      };
    };

    services.angrr = {
      enable = lib.mkEnableOption "angrr";
      package = lib.mkPackageOption pkgs "angrr" { };

      configFile = lib.mkOption {
        default = validatedConfigFile;
        defaultText = "TOML file generated from {option}`services.angrr.settings`";

        description = ''
          Path to the angrr configuration file in TOML format.

          If not set, the configuration generated from {option}`services.angrr.settings` will be used.
          If specified, {option}`services.angrr.settings` will be ignored.
        '';

        type = with lib.types; nullOr path;
      };

      enableNixGcIntegration = lib.mkOption {
        description = ''
          Whether to enable nix-gc.service integration.
        '';

        type = lib.types.bool;
      };

      extraArgs = lib.mkOption {
        default = [ ];

        description = ''
          Extra command-line arguments pass to angrr.
        '';

        type = with lib.types; listOf str;
      };

      logLevel = lib.mkOption {
        default = "info";

        description = ''
          Set the log level of angrr.
        '';

        type =
          with lib.types;
          enum [
            "off"
            "error"
            "warn"
            "info"
            "debug"
            "trace"
          ];
      };

      period = lib.mkOption {
        default = null;

        description = ''
          If set, it configures {option}`services.angrr.settings` to a preset that
          monitor .direnv, results, system, and user profiles,
          retaining GC roots that are younger than the specified period.
        '';

        type = with lib.types; nullOr str;
      };

      settings = lib.mkOption {
        description = ''
          Global configuration for angrr in TOML format.
        '';

        example = exampleSettings;
        type = lib.types.submodule settingsOptions;
      };

      timer = {
        enable = lib.mkEnableOption "angrr timer";

        dates = lib.mkOption {
          default = "03:00";

          description = ''
            How often or when the retention policy is performed.
          '';

          type = lib.types.str;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = cfg.enableNixGcIntegration -> config.nix.gc.automatic;
            message = "angrr nix-gc.service integration requires `nix.gc.automatic = true`";
          }
        ];

        services.angrr.enableNixGcIntegration = lib.mkDefault config.nix.gc.automatic;
      }

      {
        environment.etc."angrr/config.toml".source = cfg.configFile;
        environment.systemPackages = [ cfg.package ];

        systemd.services.angrr = {
          description = "Auto Nix GC Roots Retention";
          environment.ANGRR_LOG_STYLE = "systemd";

          script = ''
            ${lib.getExe cfg.package} run \
              --log-level "${cfg.logLevel}" \
              --no-prompt \
              ${lib.escapeShellArgs cfg.extraArgs}
          '';

          serviceConfig = {
            Type = "oneshot";
          };
        };
      }

      (lib.mkIf cfg.timer.enable {
        systemd.timers.angrr = {
          timerConfig = {
            OnCalendar = cfg.timer.dates;
          };

          wantedBy = [ "timers.target" ];
        };
      })

      (lib.mkIf cfg.enableNixGcIntegration {
        systemd.services.angrr = {
          before = [ "nix-gc.service" ];
          wantedBy = [ "nix-gc.service" ];
        };
      })

      (lib.mkIf (config.programs.direnv.enable && direnvCfg.enable) {
        environment.etc."direnv/lib/angrr.sh".source = "${cfg.package}/share/direnv/lib/angrr.sh";

        programs.direnv.direnvrcExtra = lib.mkIf direnvCfg.autoUse ''
          _angrr_auto_use "$@"
        '';
      })

      # When period is set, configure a preset retention policy
      # Users can still override settings via services.angrr.settings
      (lib.mkIf (cfg.period != null) {
        services.angrr.settings = {
          profile-policies = {
            system = {
              keep-booted-system = true;
              keep-current-system = true;
              keep-since = cfg.period;
              profile-paths = [ "/nix/var/nix/profiles/system" ];
            };

            user = {
              keep-since = cfg.period;

              profile-paths = [
                "~/.local/state/nix/profiles/profile"
                "/nix/var/nix/profiles/per-user/root/profile"
              ];
            };
          };

          temporary-root-policies = {
            direnv = {
              path-regex = "/\\.direnv/";
              period = cfg.period;
            };

            result = {
              path-regex = "/result[^/]*$";
              period = cfg.period;
            };
          };
        };
      })
    ]
  );

  meta.maintainers = pkgs.angrr.meta.maintainers;
}
