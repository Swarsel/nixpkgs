{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.thermald;
in
{
  ###### interface
  options = {
    services.thermald = {
      enable = lib.mkEnableOption "thermald, the temperature management daemon";
      package = lib.mkPackageOption pkgs "thermald" { };

      configFile = lib.mkOption {
        default = null;

        description = ''
          The thermald manual configuration file.

          Leave unspecified to run with the `--adaptive` flag instead which will have thermald use your computer's DPTF adaptive tables.

          See `man thermald` for more information.
        '';

        type = lib.types.nullOr lib.types.path;
      };

      debug = lib.mkOption {
        default = false;

        description = ''
          Whether to enable debug logging.
        '';

        type = lib.types.bool;
      };

      ignoreCpuidCheck = lib.mkOption {
        default = false;
        description = "Whether to ignore the cpuid check to allow running on unsupported platforms";
        type = lib.types.bool;
      };
    };
  };

  ###### implementation
  config = lib.mkIf cfg.enable {
    services.dbus.packages = [ cfg.package ];

    systemd.services.thermald = {
      description = "Thermal Daemon Service";
      documentation = [ "man:thermald(8)" ];

      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/sbin/thermald \
            --no-daemon \
            ${lib.optionalString cfg.debug "--loglevel=debug"} \
            ${lib.optionalString cfg.ignoreCpuidCheck "--ignore-cpuid-check"} \
            ${if cfg.configFile != null then "--config-file ${cfg.configFile}" else "--adaptive"} \
            --dbus-enable
        '';

        PrivateNetwork = true;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
