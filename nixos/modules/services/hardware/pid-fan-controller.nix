{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.pid-fan-controller;
  settingsFormat = pkgs.formats.json { };
in
{
  options.services.pid-fan-controller = {
    enable = lib.mkEnableOption "the PID fan controller, which controls the configured fans by running a closed-loop PID control loop";
    package = lib.mkPackageOption pkgs "pid-fan-controller" { };

    settings = lib.mkOption {
      default = { };

      description = ''
        Configuration for pid-fan-controller, see
        <https://github.com/zimward/pid-fan-controller>
        for supported values.
      '';

      type = lib.types.submodule {
        freeformType = lib.types.either settingsFormat.type (lib.types.listOf settingsFormat.type);
      };
    };
  };

  config =
    let
      oldConfig = cfg.settings ? heatSources;
      configFile = settingsFormat.generate "pid-fan-settings.json" (
        if oldConfig then
          {
            fans = map (fan: {
              cutoff = fan.cutoff or false;
              heat_pressure_srcs = fan.heatPressureSrcs;
              max_pwm = fan.maxPwm;
              min_pwm = fan.minPwm;
              wildcard_path = fan.wildcardPath;
            }) cfg.settings.fans;

            heat_srcs = map (heatSrc: {
              PID_params = {
                D = heatSrc.pidParams.D;
                I = heatSrc.pidParams.I;
                P = heatSrc.pidParams.P;
                set_point = heatSrc.pidParams.setPoint;
              };

              name = heatSrc.name or "";
              wildcard_path = heatSrc.wildcardPath;
            }) cfg.settings.heatSources;

            interval = cfg.settings.interval or 500;
          }
        else
          cfg.settings
      );
    in
    lib.mkIf cfg.enable {
      systemd.packages = [ cfg.package ];
      systemd.services.pid-fan-controller.environment.PID_FAN_CONFIG = toString configFile;
      systemd.services.pid-fan-controller.wantedBy = [ "multi-user.target" ];
      systemd.services.pid-fan-controller-sleep.wantedBy = [ "sleep.target" ];

      warnings =
        if oldConfig then
          [
            ''
              The configuration of `pid-fan-controller` is no longer deeply configured and the rewriting will be removed in 26.11!
              Please switch to using underscore case as shown in the upstream documentation.
            ''
          ]
        else
          [ ];
    };

  meta.maintainers = with lib.maintainers; [ zimward ];
}
