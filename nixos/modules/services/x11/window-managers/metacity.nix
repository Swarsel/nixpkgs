{
  config,
  lib,
  pkgs,
  ...
}:

let

  cfg = config.services.xserver.windowManager.metacity;
  inherit (pkgs) metacity;
in

{
  options = {
    services.xserver.windowManager.metacity.enable = lib.mkEnableOption "metacity";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ metacity ];

    services.xserver.windowManager.session = lib.singleton {
      name = "metacity";

      start = ''
        ${metacity}/bin/metacity &
        waitPID=$!
      '';
    };

  };

}
