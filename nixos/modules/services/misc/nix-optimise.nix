{ config, lib, ... }:

let
  cfg = config.nix.optimise;
in

{
  options = {
    nix.optimise = {
      automatic = lib.mkOption {
        default = false;
        description = "Automatically run the nix store optimiser at a specific time.";
        type = lib.types.bool;
      };

      dates = lib.mkOption {
        apply = lib.toList;
        default = [ "03:45" ];

        description = ''
          Specification (in the format described by
          {manpage}`systemd.time(7)`) of the time at
          which the optimiser will run.
        '';

        type = with lib.types; either singleLineStr (listOf str);
      };

      persistent = lib.mkOption {
        default = true;

        description = ''
          Takes a boolean argument. If true, the time when the service
          unit was last triggered is stored on disk. When the timer is
          activated, the service unit is triggered immediately if it
          would have been triggered at least once during the time when
          the timer was inactive. Such triggering is nonetheless
          subject to the delay imposed by RandomizedDelaySec=. This is
          useful to catch up on missed runs of the service when the
          system was powered down.
        '';

        example = false;
        type = lib.types.bool;
      };

      randomizedDelaySec = lib.mkOption {
        default = "1800";

        description = ''
          Add a randomized delay before the optimizer will run.
          The delay will be chosen between zero and this value.
          This value must be a time span in the format specified by
          {manpage}`systemd.time(7)`
        '';

        example = "45min";
        type = lib.types.singleLineStr;
      };
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.automatic -> config.nix.enable;
        message = "nix.optimise.automatic requires nix.enable";
      }
    ];

    systemd = lib.mkIf config.nix.enable {
      services.nix-optimise = {
        description = "Nix Store Optimiser";
        # do not start and delay when switching
        restartIfChanged = false;

        serviceConfig = {
          CPUSchedulingPolicy = "idle";
          ExecStart = "${lib.getExe' config.nix.package "nix-store"} --optimise";
          IOSchedulingClass = "idle";
          Nice = 19;
        };

        startAt = lib.optionals cfg.automatic cfg.dates;

        unitConfig = {
          ConditionACPower = true;
          # No point this if the nix daemon (and thus the nix store) is outside
          ConditionPathIsReadWrite = "/nix/var/nix/daemon-socket";
        };
      };

      timers.nix-optimise = lib.mkIf cfg.automatic {
        timerConfig = {
          Persistent = cfg.persistent;
          RandomizedDelaySec = cfg.randomizedDelaySec;
        };
      };
    };
  };
}
