{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.streamdeck-ui;
in
{
  options.programs.streamdeck-ui = {
    enable = lib.mkEnableOption "streamdeck-ui";

    package = lib.mkPackageOption pkgs "streamdeck-ui" {
      default = [ "streamdeck-ui" ];
    };

    autoStart = lib.mkOption {
      default = true;
      description = "Whether streamdeck-ui should be started automatically.";
      type = lib.types.bool;
    };

  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
      (lib.mkIf cfg.autoStart (
        pkgs.makeAutostartItem {
          package = cfg.package;
          name = "streamdeck-ui-noui";
        }
      ))
    ];

    services.udev.packages = [ cfg.package ];
  };

  meta.maintainers = with lib.maintainers; [ majiir ];
}
