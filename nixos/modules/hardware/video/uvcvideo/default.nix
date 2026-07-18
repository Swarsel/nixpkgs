{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.uvcvideo;

  uvcdynctrl-udev-rules =
    packages:
    pkgs.callPackage ./uvcdynctrl-udev-rules.nix {
      drivers = packages;
      udevDebug = false;
    };

in

{

  options = {
    services.uvcvideo.dynctrl = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable {command}`uvcvideo` dynamic controls.

          Note that enabling this brings the {command}`uvcdynctrl` tool
          into your environment and register all dynamic controls from
          specified {command}`packages` to the {command}`uvcvideo` driver.
        '';

        type = lib.types.bool;
      };

      packages = lib.mkOption {
        apply = map lib.getBin;

        description = ''
          List of packages containing {command}`uvcvideo` dynamic controls
          rules. All files found in
          {file}`«pkg»/share/uvcdynctrl/data`
          will be included.

          Note that these will serve as input to the {command}`libwebcam`
          package which through its own {command}`udev` rule will register
          the dynamic controls from specified packages to the {command}`uvcvideo`
          driver.
        '';

        example = lib.literalExpression "[ pkgs.tiscamera ]";
        type = lib.types.listOf lib.types.path;
      };
    };
  };

  config = lib.mkIf cfg.dynctrl.enable {

    environment.systemPackages = [
      pkgs.libwebcam
    ];

    services.udev.packages = [
      (uvcdynctrl-udev-rules cfg.dynctrl.packages)
    ];

  };
}
