{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.system76-scheduler;

  inherit (builtins)
    concatStringsSep
    map
    toString
    attrNames
    ;
  inherit (lib)
    boolToString
    types
    mkOption
    literalExpression
    optional
    mkIf
    mkMerge
    ;
  inherit (types)
    nullOr
    listOf
    bool
    int
    ints
    float
    str
    enum
    ;

  withDefaults =
    optionSpecs: defaults:
    lib.genAttrs (attrNames optionSpecs) (
      name:
      mkOption (
        optionSpecs.${name}
        // {
          default = optionSpecs.${name}.default or defaults.${name} or null;
        }
      )
    );

  latencyProfile = withDefaults {
    bandwidth-size = {
      description = "`sched_cfs_bandwidth_slice_us`.";
      type = int;
    };

    latency = {
      description = "`sched_latency_ns`.";
      type = int;
    };

    nr-latency = {
      description = "`sched_nr_latency`.";
      type = int;
    };

    preempt = {
      description = "Preemption mode.";

      type = enum [
        "none"
        "voluntary"
        "full"
      ];
    };

    wakeup-granularity = {
      description = "`sched_wakeup_granularity_ns`.";
      type = float;
    };
  };
  schedulerProfile = withDefaults {
    class = {
      description = "CPU scheduler class.";
      example = literalExpression "\"batch\"";

      type = nullOr (enum [
        "idle"
        "batch"
        "other"
        "rr"
        "fifo"
      ]);
    };

    ioClass = {
      description = "IO scheduler class.";
      example = literalExpression "\"best-effort\"";

      type = nullOr (enum [
        "idle"
        "best-effort"
        "realtime"
      ]);
    };

    ioPrio = {
      description = "IO scheduler priority.";
      example = literalExpression "4";
      type = nullOr (ints.between 0 7);
    };

    matchers = {
      default = [ ];
      description = "Process matchers.";

      example = literalExpression ''
        [
          "include cgroup=\"/user.slice/*.service\" parent=\"systemd\""
          "emacs"
        ]
      '';

      type = nullOr (listOf str);
    };

    nice = {
      description = "Niceness.";
      type = nullOr (ints.between (-20) 19);
    };

    prio = {
      description = "CPU scheduler priority.";
      example = literalExpression "49";
      type = nullOr (ints.between 1 99);
    };
  };

  cfsProfileToString =
    name:
    let
      p = cfg.settings.cfsProfiles.${name};
    in
    "${name} latency=${toString p.latency} nr-latency=${toString p.nr-latency} wakeup-granularity=${toString p.wakeup-granularity} bandwidth-size=${toString p.bandwidth-size} preempt=\"${p.preempt}\"";

  prioToString = class: prio: if prio == null then "\"${class}\"" else "(${class})${toString prio}";

  schedulerProfileToString =
    name: a: indent:
    concatStringsSep " " (
      [ "${indent}${name}" ]
      ++ (optional (a.nice != null) "nice=${toString a.nice}")
      ++ (optional (a.class != null) "sched=${prioToString a.class a.prio}")
      ++ (optional (a.ioClass != null) "io=${prioToString a.ioClass a.ioPrio}")
      ++ (optional ((builtins.length a.matchers) != 0)
        "{\n${concatStringsSep "\n" (map (m: "  ${indent}${m}") a.matchers)}\n${indent}}"
      )
    );

in
{
  options = {
    services.system76-scheduler = {
      enable = lib.mkEnableOption "system76-scheduler";

      package = mkOption {
        default = pkgs.system76-scheduler;
        defaultText = literalExpression "pkgs.system76-scheduler";
        description = "Which System76-Scheduler package to use.";
        type = types.package;
      };

      assignments = mkOption {
        default = { };
        description = "Process profile assignments.";

        example = literalExpression ''
          {
            nix-builds = {
              nice = 15;
              class = "batch";
              ioClass = "idle";
              matchers = [
                "nix-daemon"
              ];
            };
          }
        '';

        type = types.attrsOf (
          types.submodule {
            options = schedulerProfile { };
          }
        );
      };

      exceptions = mkOption {
        default = [ ];
        description = "Processes that are left alone.";

        example = literalExpression ''
          [
            "include descends=\"schedtool\""
            "schedtool"
          ]
        '';

        type = types.listOf str;
      };

      settings = {
        cfsProfiles = {
          enable = mkOption {
            default = true;
            description = "Tweak CFS latency parameters when going on/off battery";
            type = bool;
          };

          default = latencyProfile {
            bandwidth-size = 5;
            latency = 6;
            nr-latency = 8;
            preempt = "voluntary";
            wakeup-granularity = 1.0;
          };

          responsive = latencyProfile {
            bandwidth-size = 3;
            latency = 4;
            nr-latency = 10;
            preempt = "full";
            wakeup-granularity = 0.5;
          };
        };

        processScheduler = {
          enable = mkOption {
            default = true;
            description = "Tweak scheduling of individual processes in real time.";
            type = bool;
          };

          foregroundBoost = {
            enable = mkOption {
              default = true;

              description = ''
                Boost foreground process priorities.

                (And de-boost background ones).  Note that this option needs cooperation
                from the desktop environment to work.  On Gnome the client side is
                implemented by the "System76 Scheduler" shell extension.
              '';

              type = bool;
            };

            background = schedulerProfile {
              ioClass = "idle";
              nice = 6;
            };

            foreground = schedulerProfile {
              ioClass = "best-effort";
              ioPrio = 0;
              nice = 0;
            };
          };

          pipewireBoost = {
            enable = mkOption {
              default = true;
              description = "Boost Pipewire client priorities.";
              type = bool;
            };

            profile = schedulerProfile {
              ioClass = "best-effort";
              ioPrio = 0;
              nice = -6;
            };
          };

          refreshInterval = mkOption {
            default = 60;
            description = "Process list poll interval, in seconds";
            type = int;
          };

          useExecsnoop = mkOption {
            default = true;
            description = "Use execsnoop (otherwise poll the precess list periodically).";
            type = bool;
          };
        };
      };

      useStockConfig = mkOption {
        default = true;

        description = ''
          Use the (reasonable and featureful) stock configuration.

          When this option is `true`, `services.system76-scheduler.settings`
          are ignored.
        '';

        type = bool;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.etc = mkMerge [
      (mkIf cfg.useStockConfig {
        # No custom settings: just use stock configuration with a fix for Pipewire
        "system76-scheduler/config.kdl".source = "${cfg.package}/data/config.kdl";
        "system76-scheduler/process-scheduler/00-dist.kdl".source = "${cfg.package}/data/pop_os.kdl";

        "system76-scheduler/process-scheduler/01-fix-pipewire-paths.kdl".source =
          ../../../../pkgs/by-name/sy/system76-scheduler/01-fix-pipewire-paths.kdl;
      })

      (
        let
          settings = cfg.settings;
          cfsp = settings.cfsProfiles;
          ps = settings.processScheduler;
        in
        mkIf (!cfg.useStockConfig) {
          "system76-scheduler/config.kdl".text = ''
            version "2.0"
            autogroup-enabled false
            cfs-profiles enable=${boolToString cfsp.enable} {
              ${cfsProfileToString "default"}
              ${cfsProfileToString "responsive"}
            }
            process-scheduler enable=${boolToString ps.enable} {
              execsnoop ${boolToString ps.useExecsnoop}
              refresh-rate ${toString ps.refreshInterval}
              assignments {
                ${
                  if ps.foregroundBoost.enable then
                    (schedulerProfileToString "foreground" ps.foregroundBoost.foreground "    ")
                  else
                    ""
                }
                ${
                  if ps.foregroundBoost.enable then
                    (schedulerProfileToString "background" ps.foregroundBoost.background "    ")
                  else
                    ""
                }
                ${
                  if ps.pipewireBoost.enable then
                    (schedulerProfileToString "pipewire" ps.pipewireBoost.profile "    ")
                  else
                    ""
                }
              }
            }
          '';
        }
      )

      {
        "system76-scheduler/process-scheduler/02-config.kdl".text =
          "exceptions {\n${concatStringsSep "\n" (map (e: "  ${e}") cfg.exceptions)}\n}\n"
          + "assignments {\n"
          + (concatStringsSep "\n" (
            map (name: schedulerProfileToString name cfg.assignments.${name} "  ") (attrNames cfg.assignments)
          ))
          + "\n}\n";
      }
    ];

    environment.systemPackages = [ cfg.package ];
    services.dbus.packages = [ cfg.package ];

    systemd.services.system76-scheduler = {
      description = "Manage process priorities and CFS scheduler latencies for improved responsiveness on the desktop";

      path = [
        # execsnoop needs those to extract kernel headers:
        pkgs.kmod
        pkgs.gnutar
        pkgs.xz
      ];

      serviceConfig = {
        BusName = "com.system76.Scheduler";
        ExecReload = "${cfg.package}/bin/system76-scheduler daemon reload";
        ExecStart = "${cfg.package}/bin/system76-scheduler daemon";
        Type = "dbus";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    maintainers = [ lib.maintainers.cmm ];
  };
}
