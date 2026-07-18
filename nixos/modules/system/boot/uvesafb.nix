{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.boot.uvesafb;
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
in
{
  options = {
    boot.uvesafb = {
      enable = mkEnableOption "uvesafb";

      gfx-mode = mkOption {
        default = "1024x768-32";
        description = "Screen resolution in modedb format. See [uvesafb](https://docs.kernel.org/fb/uvesafb.html) and [modedb](https://docs.kernel.org/fb/modedb.html) documentation for more details. The default value is a sensible default but may be not ideal for all setups.";
        type = types.str;
      };

      v86d.package = mkOption {
        default = config.boot.kernelPackages.v86d.overrideAttrs (old: {
          hardeningDisable = [ "all" ];
        });

        defaultText = ''
          config.boot.kernelPackages.v86d.overrideAttrs (old: {
                    hardeningDisable = [ "all" ];
                  })'';

        description = "Which v86d package to use with uvesafb";
        type = types.package;
      };
    };
  };

  config = mkIf cfg.enable {
    boot.initrd = {
      extraFiles."/usr/v86d".source = cfg.v86d.package;
      kernelModules = [ "uvesafb" ];
    };

    boot.kernelParams = [
      "video=uvesafb:mode:${cfg.gfx-mode},mtrr:3,ywrap"
      ''uvesafb.v86d="${cfg.v86d.package}/bin/v86d"''
    ];
  };
}
