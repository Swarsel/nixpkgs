{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.undervolt;

  mkPLimit =
    limit: window:
    if (limit == null && window == null) then
      null
    else
      assert lib.asserts.assertMsg (
        limit != null && window != null
      ) "Both power limit and window must be set";
      "${toString limit} ${toString window}";
  cliArgs =
    let
      optionFormat = optionName: {
        explicitBool = false;
        option = "--${optionName}";
        sep = null;
      };
    in
    lib.cli.toCommandLine optionFormat {
      inherit (cfg)
        verbose
        temp
        turbo
        ;

      analogio = cfg.analogioOffset;
      cache = cfg.coreOffset;
      # `core` and `cache` are both intentionally set to `cfg.coreOffset` as according to the undervolt docs:
      #
      #     Core or Cache offsets have no effect. It is not possible to set different offsets for
      #     CPU Core and Cache. The CPU will take the smaller of the two offsets, and apply that to
      #     both CPU and Cache. A warning message will be displayed if you attempt to set different offsets.
      core = cfg.coreOffset;
      gpu = cfg.gpuOffset;
      power-limit-long = mkPLimit cfg.p1.limit cfg.p1.window;
      power-limit-short = mkPLimit cfg.p2.limit cfg.p2.window;
      temp-ac = cfg.tempAc;
      temp-bat = cfg.tempBat;
      uncore = cfg.uncoreOffset;
    };
in
{
  options.services.undervolt = {
    enable = lib.mkEnableOption ''
      Undervolting service for Intel CPUs.

      Warning: This service is not endorsed by Intel and may permanently damage your hardware. Use at your own risk
    '';

    package = lib.mkPackageOption pkgs "undervolt" { };

    analogioOffset = lib.mkOption {
      default = null;

      description = ''
        The amount of voltage in mV to offset analogio by.
      '';

      type = lib.types.nullOr lib.types.int;
    };

    coreOffset = lib.mkOption {
      default = null;

      description = ''
        The amount of voltage in mV to offset the CPU cores by.
      '';

      type = lib.types.nullOr lib.types.int;
    };

    gpuOffset = lib.mkOption {
      default = null;

      description = ''
        The amount of voltage in mV to offset the GPU by.
      '';

      type = lib.types.nullOr lib.types.int;
    };

    p1.limit = lib.mkOption {
      default = null;

      description = ''
        The P1 Power Limit in Watts.
        Both limit and window must be set.
      '';

      type = with lib.types; nullOr int;
    };

    p1.window = lib.mkOption {
      default = null;

      description = ''
        The P1 Time Window in seconds.
        Both limit and window must be set.
      '';

      type =
        with lib.types;
        nullOr (oneOf [
          float
          int
        ]);
    };

    p2.limit = lib.mkOption {
      default = null;

      description = ''
        The P2 Power Limit in Watts.
        Both limit and window must be set.
      '';

      type = with lib.types; nullOr int;
    };

    p2.window = lib.mkOption {
      default = null;

      description = ''
        The P2 Time Window in seconds.
        Both limit and window must be set.
      '';

      type =
        with lib.types;
        nullOr (oneOf [
          float
          int
        ]);
    };

    temp = lib.mkOption {
      default = null;

      description = ''
        The temperature target in Celsius degrees.
      '';

      type = lib.types.nullOr lib.types.int;
    };

    tempAc = lib.mkOption {
      default = null;

      description = ''
        The temperature target on AC power in Celsius degrees.
      '';

      type = lib.types.nullOr lib.types.int;
    };

    tempBat = lib.mkOption {
      default = null;

      description = ''
        The temperature target on battery power in Celsius degrees.
      '';

      type = lib.types.nullOr lib.types.int;
    };

    turbo = lib.mkOption {
      default = null;

      description = ''
        Changes the Intel Turbo feature status (1 is disabled and 0 is enabled).
      '';

      type = lib.types.nullOr lib.types.int;
    };

    uncoreOffset = lib.mkOption {
      default = null;

      description = ''
        The amount of voltage in mV to offset uncore by.
      '';

      type = lib.types.nullOr lib.types.int;
    };

    useTimer = lib.mkOption {
      default = false;

      description = ''
        Whether to set a timer that applies the undervolt settings every 30s.
        This will cause spam in the journal but might be required for some
        hardware under specific conditions.
        Enable this if your undervolt settings don't hold.
      '';

      type = lib.types.bool;
    };

    verbose = lib.mkOption {
      default = false;

      description = ''
        Whether to enable verbose logging.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    hardware.cpu.x86.msr.enable = true;

    systemd.services.undervolt = {
      description = "Intel Undervolting Service";

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/undervolt ${toString cliArgs}";
        Restart = "no";
        Type = "oneshot";
      };

      wantedBy = [ "multi-user.target" ];
    };

    systemd.services.undervolt-sleep = {
      before = [ "sleep.target" ];
      description = "Preserve Intel Undervolting After Sleep";

      serviceConfig = {
        ExecStop = "${cfg.package}/bin/undervolt ${toString cliArgs}";
        RemainAfterExit = true;
        Restart = "no";
        Type = "oneshot";
      };

      unitConfig.StopWhenUnneeded = true;
      wantedBy = [ "sleep.target" ];
    };

    systemd.timers.undervolt = lib.mkIf cfg.useTimer {
      description = "Undervolt timer to ensure voltage settings are always applied";
      partOf = [ "undervolt.service" ];

      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = "30";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
