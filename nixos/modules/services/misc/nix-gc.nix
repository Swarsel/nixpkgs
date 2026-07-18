{ config, lib, ... }:

let
  cfg = config.nix.gc;
in

{

  ###### interface

  options = {

    nix.gc = {

      options = lib.mkOption {
        default = "";

        description = ''
          Options given to [`nix-collect-garbage`](https://nixos.org/manual/nix/stable/command-ref/nix-collect-garbage) when the garbage collector is run automatically.
        '';

        example = "--max-freed $((64 * 1024**3))";
        type = lib.types.singleLineStr;
      };

      automatic = lib.mkOption {
        default = false;
        description = "Automatically run the garbage collector at a specific time.";
        type = lib.types.bool;
      };

      dates = lib.mkOption {
        apply = lib.toList;
        default = [ "03:15" ];

        description = ''
          How often or when garbage collection is performed. For most desktop and server systems
          a sufficient garbage collection is once a week.

          This value must be a calendar event in the format specified by
          {manpage}`systemd.time(7)`.
        '';

        example = "weekly";
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
        default = "0";

        description = ''
          Add a randomized delay before each garbage collection.
          The delay will be chosen between zero and this value.
          This value must be a time span in the format specified by
          {manpage}`systemd.time(7)`
        '';

        example = "45min";
        type = lib.types.singleLineStr;
      };

    };

  };

  ###### implementation

  config = {
    assertions = [
      {
        assertion = cfg.automatic -> config.nix.enable;
        message = "nix.gc.automatic requires nix.enable";
      }
    ];

    systemd.services.nix-gc = lib.mkIf config.nix.enable {
      description = "Nix Garbage Collector";
      # do not start and delay when switching
      restartIfChanged = false;
      script = "exec ${config.nix.package.out}/bin/nix-collect-garbage ${cfg.options}";
      serviceConfig.Type = "oneshot";
      startAt = lib.optionals cfg.automatic cfg.dates;
    };

    systemd.timers.nix-gc = lib.mkIf cfg.automatic {
      timerConfig = {
        Persistent = cfg.persistent;
        RandomizedDelaySec = cfg.randomizedDelaySec;
      };
    };

  };

}
