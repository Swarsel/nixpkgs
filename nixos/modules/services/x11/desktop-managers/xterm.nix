{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.xserver.desktopManager.xterm;
  xSessionEnabled = config.services.xserver.enable;

in

{
  options = {

    services.xserver.desktopManager.xterm.enable = mkOption {
      default = versionOlder config.system.stateVersion "19.09" && xSessionEnabled;
      defaultText = literalExpression ''versionOlder config.system.stateVersion "19.09" && config.services.xserver.enable;'';
      description = "Enable a xterm terminal as a desktop manager.";
      type = types.bool;
    };

  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.xterm ];

    services.xserver.desktopManager.session = singleton {
      name = "xterm";

      start = ''
        ${pkgs.xterm}/bin/xterm -ls &
        waitPID=$!
      '';
    };

  };

}
