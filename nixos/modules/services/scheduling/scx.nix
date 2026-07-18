{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.scx;
in
{
  options.services.scx = {
    enable = lib.mkEnableOption null // {
      description = ''
        Whether to enable SCX service, a daemon to run schedulers from userspace.

        ::: {.note}
        This service requires a kernel with the Sched-ext feature.
        Generally, kernel version 6.12 and later are supported.
        :::
      '';
    };

    package = lib.mkOption {
      default = pkgs.scx.full;
      defaultText = lib.literalExpression "pkgs.scx.full";

      description = ''
        `scx` package to use. `scx.full`, which includes all schedulers, is the default.
        You may choose a minimal package, such as `pkgs.scx.rustscheds`.

        ::: {.note}
        Overriding this does not change the default scheduler; you should set `services.scx.scheduler` for it.
        :::
      '';

      example = lib.literalExpression "pkgs.scx.rustscheds";
      type = lib.types.package;
    };

    extraArgs = lib.mkOption {
      default = [ ];

      description = ''
        Parameters passed to the chosen scheduler at runtime.

        ::: {.note}
        Run `chosen-scx-scheduler --help` to see the available options. Generally,
        each scheduler has its own set of options, and they are incompatible with each other.
        :::
      '';

      example = [
        "--verbose"
        "--slice-us 5000"
      ];

      type = lib.types.listOf lib.types.str;
    };

    scheduler = lib.mkOption {
      default = "scx_rustland";

      description = ''
        Which scheduler to use. See [SCX documentation](https://github.com/sched-ext/scx/tree/main/scheds)
        for details on each scheduler and guidance on selecting the most suitable one.
      '';

      example = "scx_bpfland";
      type = lib.types.enum cfg.package.schedulers;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.12";
        message = "SCX is only supported on kernel version >= 6.12.";
      }
    ];

    environment.systemPackages = [ cfg.package ];

    systemd.services.scx = {
      description = "SCX scheduler daemon";

      environment = {
        SCX_FLAGS = lib.concatStringsSep " " cfg.extraArgs;
        SCX_SCHEDULER = cfg.scheduler;
      };

      serviceConfig = {
        ExecStart = ''
          ${pkgs.runtimeShell} -c 'exec ${cfg.package}/bin/''${SCX_SCHEDULER_OVERRIDE:-$SCX_SCHEDULER} ''${SCX_FLAGS_OVERRIDE:-$SCX_FLAGS}'
        '';

        Restart = "on-failure";
        Type = "simple";
      };

      startLimitBurst = 2;
      startLimitIntervalSec = 30;
      # SCX service should be started only if the kernel supports sched-ext
      unitConfig.ConditionPathIsDirectory = "/sys/kernel/sched_ext";
      wantedBy = [ "multi-user.target" ];
    };
  };

  meta = {
    inherit (pkgs.scx.full.meta) maintainers;
    buildDocsInSandbox = false;
  };
}
