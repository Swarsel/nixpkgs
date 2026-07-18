{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (config.boot.kernelPackages) tt-kmd;

  cfg = config.hardware.tenstorrent;
in
{
  options.hardware.tenstorrent.enable = mkEnableOption "Tenstorrent driver & utilities";

  config = mkIf cfg.enable {
    boot = {
      extraModulePackages = [ tt-kmd ];
      kernelModules = [ "tenstorrent" ];
    };

    environment.systemPackages = with pkgs; [
      tt-smi
      tt-system-tools
    ];

    services.udev.packages = [
      tt-kmd
    ];
  };

  meta.maintainers = with lib.maintainers; [ RossComputerGuy ];
}
