{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    mkIf
    getExe
    escapeShellArgs
    mkDefault
    ;
  cfg = config.services.iio-niri;
in
{
  options.services.iio-niri = {
    enable = mkEnableOption "IIO-Niri";
    package = mkPackageOption pkgs "iio-niri" { };

    extraArgs = mkOption {
      default = [ ];
      description = "Extra arguments to pass to `iio-niri listen`.";
      type = types.listOf types.str;
    };

    niriUnit = mkOption {
      default = "niri.service";
      description = "The Niri **user** service unit to bind IIO-Niri's **user** service unit to.";
      type = types.nonEmptyStr;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    hardware.sensor.iio.enable = mkDefault true;

    systemd.user.services.iio-niri = {
      after = [ cfg.niriUnit ];
      bindsTo = [ cfg.niriUnit ];
      description = "IIO-Niri";
      partOf = [ cfg.niriUnit ];

      serviceConfig = {
        ExecStart = "${getExe cfg.package} listen ${escapeShellArgs cfg.extraArgs}";
        Restart = "on-failure";
        Type = "simple";
      };

      wantedBy = [ cfg.niriUnit ];
    };
  };

  meta.maintainers = with lib.maintainers; [ zhaithizaliel ];
}
