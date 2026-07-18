{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.logiops;
  configFormat = pkgs.formats.libconfig { };
  configFile = configFormat.generate "logid.cfg" cfg.config;
in
{
  options = {
    services.logiops = {
      config = lib.mkOption {
        default = { };

        description = ''
          The standard libconfig-style config for LogiOps.
        '';

        example = lib.literalExpression ''
          devices = [
          {
              name = "Wireless Mouse MX Master";
              dpi = 1000;
              smartshift =
              {
                  on = true;
                  threshold = 30;
                  torque = 50;
              };
          }
          ];
        '';

        type = configFormat.type;
      };

      enable = lib.mkEnableOption "LogiOps, a unofficial userspace driver for HID++ Logitech devices";
      package = lib.mkPackageOption pkgs "logiops" { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    services.dbus.packages = [ cfg.package ];

    systemd = {
      packages = [ cfg.package ];

      services.logid = {
        serviceConfig.ExecStart = [
          ""
          "${lib.getExe cfg.package} -c ${configFile}"
        ];

        wantedBy = [ "graphical.target" ];
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ bokicoder ];
}
