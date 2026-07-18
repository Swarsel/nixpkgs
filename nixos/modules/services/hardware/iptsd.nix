{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.iptsd;
  format = pkgs.formats.ini { };
  configFile = format.generate "iptsd.conf" cfg.config;
in
{
  options.services.iptsd = {
    config = lib.mkOption {
      default = { };

      description = ''
        Configuration for IPTSD. See the
        [reference configuration](https://github.com/linux-surface/iptsd/blob/master/etc/iptsd.conf)
        for available options and defaults.
      '';

      type = lib.types.submodule {
        options = {
          Stylus = {
            Disable = lib.mkOption {
              default = false;
              description = "Disables the stylus. No stylus data will be processed.";
              type = lib.types.bool;
            };
          };

          Touchscreen = {
            DisableOnPalm = lib.mkOption {
              default = false;
              description = "Ignore all touchscreen inputs if a palm was registered on the display.";
              type = lib.types.bool;
            };

            DisableOnStylus = lib.mkOption {
              default = false;
              description = "Ignore all touchscreen inputs if a stylus is in proximity.";
              type = lib.types.bool;
            };
          };
        };

        freeformType = format.type;
      };
    };

    enable = lib.mkEnableOption "the userspace daemon for Intel Precise Touch & Stylus";
  };

  config = lib.mkIf cfg.enable {
    environment.etc."iptsd.conf".source = configFile;
    services.udev.packages = [ pkgs.iptsd ];
    systemd.packages = [ pkgs.iptsd ];
    systemd.services."iptsd@".restartTriggers = [ configFile ];

    warnings = lib.optional (lib.hasAttr "Touch" cfg.config) ''
      The option `services.iptsd.config.Touch` has been renamed to `services.iptsd.config.Touchscreen`.
    '';
  };

  meta.maintainers = with lib.maintainers; [ dotlambda ];
}
