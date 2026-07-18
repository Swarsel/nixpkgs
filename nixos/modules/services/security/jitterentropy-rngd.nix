{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.jitterentropy-rngd;
in
{
  options.services.jitterentropy-rngd = {
    enable = lib.mkEnableOption "jitterentropy-rngd service configuration";
    package = lib.mkPackageOption pkgs "jitterentropy-rngd" { };

    flags = lib.mkOption {
      default = 0;
      description = "Additional flags to pass to jitterentropy";
      type = lib.types.int;
    };

    forceSP800-90B = lib.mkOption {
      default = false;
      description = "Force SP800-90B mode for entropy reading";
      type = lib.types.bool;
    };

    memlockLimit = lib.mkOption {
      default = "2M";
      description = "Set limit for lockable memory with mlock";
      type = lib.types.str;
    };

    osr = lib.mkOption {
      default = 3;
      description = "Oversampling rate for jitterentropy (3 to 20)";
      type = lib.types.ints.between 3 20;
    };

    verbose = lib.mkOption {
      default = false;
      description = "Enable verbose log messages";
      type = lib.types.bool;
    };
  };

  config =
    let
      # use identical arguments for status and service execution,
      # in order to get meaningful output
      args =
        "--osr ${builtins.toString cfg.osr} --flags ${builtins.toString cfg.flags}"
        + lib.optionalString cfg.forceSP800-90B " --sp800-90b"
        + lib.optionalString cfg.verbose " -vvv";
    in
    lib.mkIf cfg.enable {
      systemd.packages = [ cfg.package ];

      systemd.services."jitterentropy".serviceConfig = {
        ExecStart = [
          # clear old setting from built-in service file
          ""
          # use service from package with our configured args
          "${cfg.package}/bin/jitterentropy-rngd ${args}"
        ];

        # logs used configuration for comparison
        ExecStartPre = [
          "-${cfg.package}/bin/jitterentropy-rngd --status ${args}"
        ];

        LimitMEMLOCK = [
          # clear old setting from built-in service file
          ""
          # use service from package with our configured limit
          "${cfg.memlockLimit}"
        ];
      };

      systemd.services."jitterentropy".wantedBy = [ "basic.target" ];
    };

  meta.maintainers = with lib.maintainers; [ thillux ];
}
