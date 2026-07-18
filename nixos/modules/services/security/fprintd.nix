{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.fprintd;
  fprintdPkg = if cfg.tod.enable then pkgs.fprintd-tod else pkgs.fprintd;

in

{

  ###### interface

  options = {

    services.fprintd = {

      enable = lib.mkEnableOption "fprintd daemon and PAM module for fingerprint readers handling";

      package = lib.mkOption {
        default = fprintdPkg;
        defaultText = lib.literalExpression "if config.services.fprintd.tod.enable then pkgs.fprintd-tod else pkgs.fprintd";

        description = ''
          fprintd package to use.
        '';

        type = lib.types.package;
      };

      tod = {

        enable = lib.mkEnableOption "Touch OEM Drivers library support";

        driver = lib.mkOption {
          description = ''
            Touch OEM Drivers (TOD) package to use.
          '';

          example = lib.literalExpression "pkgs.libfprint-2-tod1-goodix";
          type = lib.types.package;
        };
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];
    services.dbus.packages = [ cfg.package ];
    systemd.packages = [ cfg.package ];

    systemd.services.fprintd.environment = lib.mkIf cfg.tod.enable {
      FP_TOD_DRIVERS_DIR = "${cfg.tod.driver}${cfg.tod.driver.driverPath}";
    };

  };

}
