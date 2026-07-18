{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.fractalart;
in
{
  options.services.fractalart = {
    enable = mkOption {
      default = false;
      description = "Enable FractalArt for generating colorful wallpapers on login";
      example = true;
      type = types.bool;
    };

    height = mkOption {
      default = null;
      description = "Screen height";
      example = 1080;
      type = types.nullOr types.int;
    };

    width = mkOption {
      default = null;
      description = "Screen width";
      example = 1920;
      type = types.nullOr types.int;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.haskellPackages.FractalArt ];

    services.xserver.displayManager.sessionCommands =
      "${pkgs.haskellPackages.FractalArt}/bin/FractalArt --no-bg -f .background-image"
      + optionalString (cfg.width != null) " -w ${toString cfg.width}"
      + optionalString (cfg.height != null) " -h ${toString cfg.height}";
  };
}
