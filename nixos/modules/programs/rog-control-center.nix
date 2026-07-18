{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.rog-control-center;
in
{
  options = {
    programs.rog-control-center = {
      enable = lib.mkEnableOption "the rog-control-center application";

      autoStart = lib.mkOption {
        default = false;
        description = "Whether rog-control-center should be started automatically.";
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.asusctl
      (lib.mkIf cfg.autoStart (
        pkgs.makeAutostartItem {
          package = pkgs.asusctl;
          name = "rog-control-center";
        }
      ))
    ];

    services.asusd.enable = true;
  };

  meta.maintainers = pkgs.asusctl.meta.maintainers;
}
